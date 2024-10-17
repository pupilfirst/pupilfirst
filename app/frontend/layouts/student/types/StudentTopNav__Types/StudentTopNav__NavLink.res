type t = {
  title: string,
  url: string,
  local: bool,
}

let title = t => t.title

let url = t => t.url

let local = t => t.local

module Decode = {
  open Json.Decode

  let navLink = object(field => {
    title: field.required("title", string),
    url: field.required("url", string),
    local: field.required("local", bool),
  })
}
