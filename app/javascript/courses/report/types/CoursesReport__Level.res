type t = {
  id: string,
  name: string,
  number: int,
  unlocked: bool,
}

let t = I18n.t(~scope="components.CoursesReport__Level")

let id = t => t.id
let name = t => t.name

let number = t => t.number

let unlocked = t => t.unlocked

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
    unlocked: json |> field("unlocked", bool),
  }
}

let shortName = t => LevelLabel.format(~short=true, t.number |> string_of_int)

let levelLabel = (levels, id) =>
  LevelLabel.format(
    (levels
    |> ArrayUtils.unsafeFind(
      level => level.id == id,
      "Unable to find level with ID: " ++ (id ++ " in CoursesReport"),
    )
    |> number
    |> string_of_int)
  )

let sort = levels => levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number)
