type t = {
  id: string,
  name: string,
  active: bool,
}

let id = t => t.id

let name = t => t.name

let active = t => t.active

module Decode = {
  open Json.Decode

  let certificate = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    active: field.required("active", bool),
  })
}
