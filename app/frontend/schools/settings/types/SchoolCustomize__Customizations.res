exception UnknownKindOfLink(string)

type schoolStrings = {
  address: option<string>,
  emailAddress: option<string>,
  privacyPolicy: option<string>,
  termsAndConditions: option<string>,
  codeOfConduct: option<string>,
}

type file = {
  url: string,
  filename: string,
}

type schoolImages = {
  logoOnLightBg: option<file>,
  logoOnDarkBg: option<file>,
  coverImage: option<file>,
  iconOnLightBg: file,
  iconOnDarkBg: file,
}

type linkId = string
type title = string
type url = string
type sortIndex = int

type link =
  | HeaderLink(linkId, title, url, sortIndex)
  | FooterLink(linkId, title, url, sortIndex)
  | SocialLink(linkId, url, sortIndex)

type t = {
  schoolStrings: schoolStrings,
  schoolImages: schoolImages,
  links: array<link>,
}

let logoOnLightBg = t => t.schoolImages.logoOnLightBg
let logoOnDarkBg = t => t.schoolImages.logoOnDarkBg
let iconOnLightBg = t => t.schoolImages.iconOnLightBg
let iconOnDarkBg = t => t.schoolImages.iconOnDarkBg
let coverImage = t => t.schoolImages.coverImage

let url = file => file.url
let filename = file => file.filename

let address = t => t.schoolStrings.address
let emailAddress = t => t.schoolStrings.emailAddress
let privacyPolicy = t => t.schoolStrings.privacyPolicy
let termsAndConditions = t => t.schoolStrings.termsAndConditions
let codeOfConduct = t => t.schoolStrings.codeOfConduct

let filterLinks = (~header=false, ~footer=false, ~social=false, t) =>
  t.links->Js.Array2.filter(l =>
    switch l {
    | HeaderLink(_, _, _, _) => header
    | FooterLink(_, _, _, _) => footer
    | SocialLink(_, _, _) => social
    }
  )

let unpackLinks = links =>
  links->Js.Array2.map(l =>
    switch l {
    | HeaderLink(id, title, url, sortIndex)
    | FooterLink(id, title, url, sortIndex) => (id, title, url, sortIndex)
    | SocialLink(id, url, sortIndex) => (id, "", url, sortIndex)
    }
  )

let addLink = (t, link) => {...t, links: t.links->Js.Array2.concat([link])}

let removeLink = (t, linkId) => {
  ...t,
  links: t.links->Js.Array2.filter(l =>
    switch l {
    | HeaderLink(id, _, _, _)
    | FooterLink(id, _, _, _) =>
      id != linkId
    | SocialLink(id, _, _) => id != linkId
    }
  ),
}

let updateLink = (t, linkId, newTitle, newUrl) => {
  ...t,
  links: t.links->Js.Array2.map(l =>
    switch l {
    | HeaderLink(id, title, url, sortIndex) =>
      id == linkId
        ? HeaderLink(id, newTitle, newUrl, sortIndex)
        : HeaderLink(id, title, url, sortIndex)
    | FooterLink(id, title, url, sortIndex) =>
      id == linkId
        ? FooterLink(id, newTitle, newUrl, sortIndex)
        : FooterLink(id, title, url, sortIndex)
    | SocialLink(id, url, sortIndex) =>
      id == linkId ? SocialLink(id, newUrl, sortIndex) : SocialLink(id, url, sortIndex)
    }
  ),
}

type direction = Up | Down

let sortIndexOfLink = link =>
  switch link {
  | HeaderLink(_, _, _, sortIndex)
  | FooterLink(_, _, _, sortIndex)
  | SocialLink(_, _, sortIndex) => sortIndex
  }

let optionalString = s =>
  switch s->String.trim {
  | "" => None
  | nonEmptyString => Some(nonEmptyString)
  }

let updatePrivacyPolicy = (t, privacyPolicy) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    privacyPolicy: privacyPolicy->optionalString,
  },
}

let updateTermsAndConditions = (t, termsAndConditions) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    termsAndConditions: termsAndConditions->optionalString,
  },
}

let updateCodeOfConduct = (t, codeOfConduct) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    codeOfConduct: codeOfConduct->optionalString,
  },
}

let updateAddress = (t, address) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    address: address->optionalString,
  },
}

let updateEmailAddress = (t, emailAddress) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    emailAddress: emailAddress->optionalString,
  },
}

let decodeFile = json => {
  open Json.Decode
  {
    url: json |> field("url", string),
    filename: json |> field("filename", string),
  }
}

let decodeImages = json => {
  open Json.Decode
  {
    logoOnLightBg: field("logoOnLightBg", optional(decodeFile), json),
    logoOnDarkBg: field("logoOnDarkBg", optional(decodeFile), json),
    coverImage: field("coverImage", optional(decodeFile), json),
    iconOnLightBg: field("iconOnLightBg", decodeFile, json),
    iconOnDarkBg: field("iconOnDarkBg", decodeFile, json),
  }
}

let updateImages = (t, json) => {...t, schoolImages: json->decodeImages}

let decodeStrings = json => {
  open Json.Decode
  {
    address: field("address", optional(string), json),
    emailAddress: field("emailAddress", optional(string), json),
    privacyPolicy: field("privacyPolicy", optional(string), json),
    termsAndConditions: field("termsAndConditions", optional(string), json),
    codeOfConduct: field("codeOfConduct", optional(string), json),
  }
}

let decodeLink = json => {
  let (kind, id, url, sortIndex) = {
    open Json.Decode
    (
      field("kind", string, json),
      field("id", string, json),
      field("url", string, json),
      field("sortIndex", int, json),
    )
  }

  let title = switch kind {
  | "header"
  | "footer" =>
    open Json.Decode
    field("title", string, json)
  | _ => ""
  }

  switch kind {
  | "header" => HeaderLink(id, title, url, sortIndex)
  | "footer" => FooterLink(id, title, url, sortIndex)
  | "social" => SocialLink(id, url, sortIndex)
  | unknownKind => raise(UnknownKindOfLink(unknownKind))
  }
}

let decode = json => {
  open Json.Decode
  {
    schoolStrings: json |> field("strings", decodeStrings),
    schoolImages: json |> field("images", decodeImages),
    links: json
    |> field("links", array(decodeLink))
    |> Js.Array.sortInPlaceWith((l1, l2) => sortIndexOfLink(l1) - sortIndexOfLink(l2)),
  }
}
