type id = string

type t = {id: id}

let id = t => t.id

module Decode = {
  open Json.Decode

  let course = field => {
    id: field.required("id", string),
  }
}
