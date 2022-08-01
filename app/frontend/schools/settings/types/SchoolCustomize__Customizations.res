exception UnknownKindOfLink(string)

type schoolStrings = {
  address: option<string>,
  emailAddress: option<string>,
  privacyPolicy: option<string>,
  termsAndConditions: option<string>,
}

type file = {
  url: string,
  filename: string,
}

type schoolImages = {
  logoOnLightBg: option<file>,
  coverImage: option<file>,
  icon: file,
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
let icon = t => t.schoolImages.icon
let coverImage = t => t.schoolImages.coverImage

let url = file => file.url
let filename = file => file.filename

let address = t => t.schoolStrings.address
let emailAddress = t => t.schoolStrings.emailAddress
let privacyPolicy = t => t.schoolStrings.privacyPolicy
let termsAndConditions = t => t.schoolStrings.termsAndConditions

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

let addLink = (link, t) => {...t, links: t.links->Js.Array2.concat([link])}

let removeLink = (linkId, t) => {
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

let updateLink = (linkId, newTitle, newUrl, t) => {
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

let updatePrivacyPolicy = (privacyPolicy, t) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    privacyPolicy: privacyPolicy->optionalString,
  },
}

let updateTermsAndConditions = (termsAndConditions, t) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    termsAndConditions: termsAndConditions->optionalString,
  },
}

let updateAddress = (address, t) => {
  ...t,
  schoolStrings: {
    ...t.schoolStrings,
    address: address->optionalString,
  },
}

let updateEmailAddress = (emailAddress, t) => {
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
    logoOnLightBg: json |> field("logoOnLightBg", optional(decodeFile)),
    coverImage: json |> field("coverImage", optional(decodeFile)),
    icon: json |> field("icon", decodeFile),
  }
}

let updateImages = (json, t) => {...t, schoolImages: json |> decodeImages}

let decodeStrings = json => {
  open Json.Decode
  {
    address: json |> field("address", optional(string)),
    emailAddress: json |> field("emailAddress", optional(string)),
    privacyPolicy: json |> field("privacyPolicy", optional(string)),
    termsAndConditions: json |> field("termsAndConditions", optional(string)),
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
