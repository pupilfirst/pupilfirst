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
    id: field("id", string, json),
    name: field("name", string, json),
    number: field("number", int, json),
    unlockAt: optional(field("unlockAt", DateFns.decodeISO), json),
  }
}

let selectLevel = (levels, level_id) =>
  levels |> ArrayUtils.unsafeFind(
    q => q.id == level_id,
    `Unable to find level with ID: ${level_id}, in CurriculumEditor`,
  )

let create = (id, name, number, unlockAt) => {
  id: id,
  name: name,
  number: number,
  unlockAt: unlockAt,
}

let updateArray = (level, levels) => {
  let oldLevels = levels->Js.Array2.filter(l => l.id !== level.id)
  oldLevels->Js.Array2.concat([level])
}

let sort = levels => levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number)

let unsafeFind = (levels, componentName, levelId) =>
  levels |> ArrayUtils.unsafeFind(
    l => l.id == levelId,
    "Unable to find level with id: " ++ (levelId ++ (" in CurriculumEditor__" ++ componentName)),
  )

let levelNumberWithName = t => LevelLabel.format(~name=t.name, string_of_int(t.number))
