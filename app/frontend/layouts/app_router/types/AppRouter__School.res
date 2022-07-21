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
  logoUrl: option<string>,
  coverImageUrl: option<string>,
  links: array<link>,
  iconUrl: string,
}

let name = t => t.name
let logoUrl = t => t.logoUrl
let links = t => t.links
let iconUrl = t => t.iconUrl
let coverImageUrl = t => t.coverImageUrl

let decode = json => {
  open Json.Decode
  {
    name: field("name", string, json),
    logoUrl: field("logoUrl", nullable(string), json)->Js.Null.toOption,
    links: field("links", array(decodeLink), json),
    iconUrl: field("iconUrl", string, json),
    coverImageUrl: field("coverImageUrl", nullable(string), json)->Js.Null.toOption,
  }
}
