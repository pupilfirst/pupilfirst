type t = {
  id: string,
  name: string,
}

module Decode = {
  open Json.Decode

  let course = object(field => {
    id: field.required("id", string),
    name: field.require("name", string),
  })
}

let id = t => t.id

let name = t => t.name
