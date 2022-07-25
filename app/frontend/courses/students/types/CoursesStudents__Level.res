type t = {
  id: string,
  name: string,
  number: int,
}

let id = t => t.id
let name = t => t.name
let number = t => t.number

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
  }
}

let shortName = t => LevelLabel.format(~short=true, t.number |> string_of_int)

let sort = levels => levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number)

let unsafeLevelNumber = (levels, componentName, levelId) =>
  LevelLabel.format(
    (levels
    |> ArrayUtils.unsafeFind(
      l => l.id == levelId,
      "Unable to find level with id: " ++ (levelId ++ (" in CoursesStudents__" ++ componentName)),
    )
    |> number
    |> string_of_int)
  )
