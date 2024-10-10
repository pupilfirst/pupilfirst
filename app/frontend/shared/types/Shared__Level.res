type t = {
  id: string,
  name: string,
  number: int,
}

module Decode = {
  open Json.Decode

  let t = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    number: field.required("number", int),
  })
}

let id = t => t.id
let name = t => t.name
let number = t => t.number

let sort = levels => ArrayUtils.copyAndSort((x, y) => x.number - y.number, levels)

let unsafeLevelNumber = (levels, componentName, levelId) =>
  LevelLabel.format(
    string_of_int(
      number(
        ArrayUtils.unsafeFind(
          l => l.id == levelId,
          "Unable to find level with id: " ++ (levelId ++ componentName),
          levels,
        ),
      ),
    ),
  )

let make = (~id, ~name, ~number) => {
  id,
  name,
  number,
}

let makeFromJs = level => {
  make(~id=level["id"], ~name=level["name"], ~number=level["number"])
}

let shortName = t => "Level " ++ string_of_int(t.number)

let filterValue = t => t.id ++ ";" ++ t.number->string_of_int ++ ", " ++ t.name

module Fragment = %graphql(`
  fragment LevelFragment on Level {
    id
    name
    number
  }
`)

let makeFromFragment = (level: Fragment.t) =>
  make(~id=level.id, ~name=level.name, ~number=level.number)
