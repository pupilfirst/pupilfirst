type id = string

type t = {
  id: id,
  name: string,
}

let id = t => t.id

module Decode = {
  open Json.Decode

  let course = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
  })
}
