type t = {
  id: string,
  name: string,
}

let name = t => t.name

let id = t => t.id

module Decode = {
  open Json.Decode

  let evaluationCriterion = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
  })
}
