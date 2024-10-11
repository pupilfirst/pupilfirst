type t = {
  id: string,
  name: string,
  topicsCount: int,
}

module Decode = {
  open Json.Decode

  let category = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    topicsCount: field.required("topicsCount", int),
  })
}

let id = t => t.id

let name = t => t.name

let topicsCount = t => t.topicsCount

let updateName = (name, t) => {
  ...t,
  name,
}

let make = (~id, ~name, ~topicsCount) => {id, name, topicsCount}

let color = t => StringUtils.toColor(t.name)
