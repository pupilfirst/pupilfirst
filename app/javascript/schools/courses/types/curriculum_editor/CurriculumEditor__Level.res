type t = {
  id: string,
  name: string,
  number: int,
  unlockAt: option<Js.Date.t>,
}

let id = t => t.id

let name = t => t.name

let number = t => t.number

let unlockAt = t => t.unlockAt

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
    unlockAt: json |> optional(field("unlockAt", DateFns.decodeISO)),
  }
}

let selectLevel = (levels, level_name) =>
  levels |> ArrayUtils.unsafeFind(
    q => q.name == level_name,
    "Unable to find level with name: " ++ (level_name ++ "in CurriculumEditor"),
  )

let create = (id, name, number, unlockAt) => {
  id: id,
  name: name,
  number: number,
  unlockAt: unlockAt,
}

let updateArray = (levels, level) => {
  let oldLevels = levels |> Js.Array.filter(l => l.id !== level.id)
  oldLevels |> Array.append([level])
}

let sort = levels => levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number)

let unsafeFind = (levels, componentName, levelId) =>
  levels |> ArrayUtils.unsafeFind(
    l => l.id == levelId,
    "Unable to find level with id: " ++ (levelId ++ (" in CurriculumEditor__" ++ componentName)),
  )

let levelNumberWithName = t => LevelLabel.format(~name=t.name, (t.number |> string_of_int))
