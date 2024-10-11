type link = {
  title: string,
  url: string,
}

type t = {
  name: string,
  logoOnLightBgUrl: option<string>,
  logoOnDarkBgUrl: option<string>,
  coverImageUrl: option<string>,
  links: array<link>,
  iconOnLightBgUrl: string,
  iconOnDarkBgUrl: string,
}

let linkTitle = link => link.title

let linkUrl = link => link.url

module Decode = {
  open Json.Decode

  let link = object(field => {
    title: field.required("title", string),
    url: field.required("url", string),
  })

  let school = object(field => {
    name: field.required("name", string),
    logoOnLightBgUrl: field.optional("logoOnLightBgUrl", option(string))->OptionUtils.flat,
    logoOnDarkBgUrl: field.optional("logoOnDarkBgUrl", option(string))->OptionUtils.flat,
    links: field.required("links", array(link)),
    iconOnLightBgUrl: field.required("iconOnLightBgUrl", string),
    iconOnDarkBgUrl: field.required("iconOnDarkBgUrl", string),
    coverImageUrl: field.optional("coverImageUrl", option(string))->OptionUtils.flat,
  })
}

let localLinks = t => Js.Array.includes(t.title, ["Admin", "Dashboard", "Coaches"])

let name = t => t.name
let logoOnLightBgUrl = t => t.logoOnLightBgUrl
let logoOnDarkBgUrl = t => t.logoOnDarkBgUrl
let links = t => t.links
let iconOnLightBgUrl = t => t.iconOnLightBgUrl
let iconOnDarkBgUrl = t => t.iconOnDarkBgUrl
let coverImageUrl = t => t.coverImageUrl
