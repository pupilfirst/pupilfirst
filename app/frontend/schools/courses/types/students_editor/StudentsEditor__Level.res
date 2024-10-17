type t = {
  name: string,
  number: int,
  id: string,
}

let name = t => t.name

let number = t => t.number

let id = t => t.id

module Decode = {
  open Json.Decode

  let level = field => {
    id: field.required("id", string),
    name: field.required("name", string),
    number: field.required("number", int),
  }
}

let unsafeFind = (levels, componentName, levelId) =>
  ArrayUtils.unsafeFind(
    l => l.id == levelId,
    "Unable to find level with id: " ++ (levelId ++ ("in StudentdEditor__" ++ componentName)),
    levels,
  )

let title = t => LevelLabel.format(~name=t.name, string_of_int(t.number))
