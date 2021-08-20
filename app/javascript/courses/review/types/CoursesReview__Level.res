type t = {
  id: string,
  name: string,
  number: int,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
  }
}

let id = t => t.id
let name = t => t.name
let number = t => t.number

let sort = levels => levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number)

let unsafeLevelNumber = (levels, componentName, levelId) =>
  LevelLabel.format(
    levels
    |> ArrayUtils.unsafeFind(
      l => l.id == levelId,
      "Unable to find level with id: " ++ (levelId ++ ("in CoursesRevew__" ++ componentName)),
    )
    |> number
    |> string_of_int,
  )

let make = (~id, ~name, ~number) => {
  id: id,
  name: name,
  number: number,
}

let makeFromJs = level => {
  make(~id=level["id"], ~name=level["name"], ~number=level["number"])
}
