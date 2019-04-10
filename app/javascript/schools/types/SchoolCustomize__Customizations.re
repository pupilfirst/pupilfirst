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

type t = {
  schoolStrings,
  schoolImages,
  headerLinks: list((string, string)),
  footerLinks: list((string, string)),
  socialLinks: list(string),
};

let logoOnLightBg = t => t.schoolImages.logoOnLightBg;
let logoOnDarkBg = t => t.schoolImages.logoOnDarkBg;
let icon = t => t.schoolImages.icon;

let address = t => t.schoolStrings.address;
let emailAddress = t => t.schoolStrings.emailAddress;
let privacyPolicy = t => t.schoolStrings.privacyPolicy;
let termsOfUse = t => t.schoolStrings.termsOfUse;

let headerLinks = t => t.headerLinks;
let footerLinks = t => t.footerLinks;
let socialLinks = t => t.socialLinks;

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

let decodeLink = json =>
  Json.Decode.(field("title", string, json), field("url", string, json));

let decode = json =>
  Json.Decode.{
    schoolStrings: json |> field("strings", decodeStrings),
    schoolImages: json |> field("images", decodeImages),
    headerLinks: json |> field("headerLinks", list(decodeLink)),
    footerLinks: json |> field("footerLinks", list(decodeLink)),
    socialLinks: json |> field("socialLinks", list(string)),
  };