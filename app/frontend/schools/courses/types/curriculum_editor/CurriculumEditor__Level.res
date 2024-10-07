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
    unlockAt: option(field("unlockAt", DateFns.decodeISO), json),
  }
}

let selectLevel = (levels, level_id) =>
  ArrayUtils.unsafeFind(
    q => q.id == level_id,
    `Unable to find level with ID: ${level_id}, in CurriculumEditor`,
    levels,
  )

let create = (id, name, number, unlockAt) => {
  id,
  name,
  number,
  unlockAt,
}

let updateArray = (level, levels) => {
  let oldLevels = levels->Js.Array2.filter(l => l.id !== level.id)
  oldLevels->Js.Array2.concat([level])
}

let sort = levels => ArrayUtils.copyAndSort((x, y) => x.number - y.number, levels)

let unsafeFind = (levels, componentName, levelId) =>
  ArrayUtils.unsafeFind(
    l => l.id == levelId,
    "Unable to find level with id: " ++ (levelId ++ (" in CurriculumEditor__" ++ componentName)),
    levels,
  )

let levelNumberWithName = t => LevelLabel.format(~name=t.name, string_of_int(t.number))
