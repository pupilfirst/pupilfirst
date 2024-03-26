type link = {
  title: string,
  url: string,
}

let linkTitle = link => link.title

let linkUrl = link => link.url

let decodeLink = json => {
  open Json.Decode
  {
    title: field("title", string, json),
    url: field("url", string, json),
  }
}

let localLinks = t => Js.Array.includes(t.title, ["Admin", "Dashboard", "Coaches"])

type t = {
  name: string,
  logoOnLightBgUrl: option<string>,
  logoOnDarkBgUrl: option<string>,
  coverImageUrl: option<string>,
  links: array<link>,
  iconOnLightBgUrl: string,
  iconOnDarkBgUrl: string,
}

let name = t => t.name
let logoOnLightBgUrl = t => t.logoOnLightBgUrl
let logoOnDarkBgUrl = t => t.logoOnDarkBgUrl
let links = t => t.links
let iconOnLightBgUrl = t => t.iconOnLightBgUrl
let iconOnDarkBgUrl = t => t.iconOnDarkBgUrl
let coverImageUrl = t => t.coverImageUrl

let decode = json => {
  open Json.Decode
  {
    name: field("name", string, json),
    logoOnLightBgUrl: field("logoOnLightBgUrl", nullable(string), json)->Js.Null.toOption,
    logoOnDarkBgUrl: field("logoOnDarkBgUrl", nullable(string), json)->Js.Null.toOption,
    links: field("links", array(decodeLink), json),
    iconOnLightBgUrl: field("iconOnLightBgUrl", string, json),
    iconOnDarkBgUrl: field("iconOnDarkBgUrl", string, json),
    coverImageUrl: field("coverImageUrl", nullable(string), json)->Js.Null.toOption,
  }
}
