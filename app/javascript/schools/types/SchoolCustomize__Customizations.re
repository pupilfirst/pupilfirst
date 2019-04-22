exception UnknownKindOfLink(string);

type schoolStrings = {
  address: option(string),
  emailAddress: option(string),
  privacyPolicy: option(string),
  termsOfUse: option(string),
};

type schoolImages = {
  logoOnLightBg: option(string),
  logoOnDarkBg: option(string),
  icon: string,
};

type linkId = string;
type title = string;
type url = string;

type link =
  | HeaderLink(linkId, title, url)
  | FooterLink(linkId, title, url)
  | SocialLink(linkId, url);

type t = {
  schoolStrings,
  schoolImages,
  links: list(link),
};

let logoOnLightBg = t => t.schoolImages.logoOnLightBg;
let logoOnDarkBg = t => t.schoolImages.logoOnDarkBg;
let icon = t => t.schoolImages.icon;

let address = t => t.schoolStrings.address;
let emailAddress = t => t.schoolStrings.emailAddress;
let privacyPolicy = t => t.schoolStrings.privacyPolicy;
let termsOfUse = t => t.schoolStrings.termsOfUse;

let links = t => t.links;

let headerLinks = t =>
  t.links
  |> List.filter(l =>
       switch (l) {
       | HeaderLink(_, _, _) => true
       | FooterLink(_, _, _) => false
       | SocialLink(_, _) => false
       }
     );

let footerLinks = t =>
  t.links
  |> List.filter(l =>
       switch (l) {
       | HeaderLink(_, _, _) => false
       | FooterLink(_, _, _) => true
       | SocialLink(_, _) => false
       }
     );

let socialLinks = t =>
  t.links
  |> List.filter(l =>
       switch (l) {
       | HeaderLink(_, _, _) => false
       | FooterLink(_, _, _) => false
       | SocialLink(_, _) => true
       }
     );

let unpackLinks = links =>
  links
  |> List.map(l =>
       switch (l) {
       | HeaderLink(id, title, url)
       | FooterLink(id, title, url) => (id, title, url)
       | SocialLink(id, url) => (id, "", url)
       }
     );

let addLink = (link, t) => {...t, links: [link, ...t.links]};

let removeLink = (linkId, t) => {
  ...t,
  links:
    t.links
    |> List.filter(l =>
         switch (l) {
         | HeaderLink(id, _, _)
         | FooterLink(id, _, _) => id != linkId
         | SocialLink(id, _) => id != linkId
         }
       ),
};

let updatePrivacyPolicy = (privacyPolicy, t) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    privacyPolicy: Some(privacyPolicy),
  },
};

let updateTermsOfUse = (termsOfUse, t) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    termsOfUse: Some(termsOfUse),
  },
};

let decodeStrings = json =>
  Json.Decode.{
    address: json |> field("address", nullable(string)) |> Js.Null.toOption,
    emailAddress:
      json |> field("emailAddress", nullable(string)) |> Js.Null.toOption,
    privacyPolicy:
      json |> field("privacyPolicy", nullable(string)) |> Js.Null.toOption,
    termsOfUse:
      json |> field("termsOfUse", nullable(string)) |> Js.Null.toOption,
  };

let decodeImages = json =>
  Json.Decode.{
    logoOnLightBg:
      json |> field("logoOnLightBg", nullable(string)) |> Js.Null.toOption,
    logoOnDarkBg:
      json |> field("logoOnDarkBg", nullable(string)) |> Js.Null.toOption,
    icon: json |> field("icon", string),
  };

let decodeLink = json => {
  let (kind, id, url) =
    Json.Decode.(
      field("kind", string, json),
      field("id", string, json),
      field("url", string, json),
    );

  let title =
    switch (kind) {
    | "header"
    | "footer" => Json.Decode.(field("title", string, json))
    | _ => ""
    };

  switch (kind) {
  | "header" => HeaderLink(id, title, url)
  | "footer" => FooterLink(id, title, url)
  | "social" => SocialLink(id, url)
  | unknownKind => raise(UnknownKindOfLink(unknownKind))
  };
};

let decode = json =>
  Json.Decode.{
    schoolStrings: json |> field("strings", decodeStrings),
    schoolImages: json |> field("images", decodeImages),
    links: json |> field("links", list(decodeLink)),
  };