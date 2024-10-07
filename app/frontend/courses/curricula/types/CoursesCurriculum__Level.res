type t = {
  id: string,
  name: string,
  number: int,
  unlockAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
    number: field("number", int, json),
    unlockAt: option(field("unlockAt", DateFns.decodeISO), json),
  }
}

let id = t => t.id
let name = t => t.name
let number = t => t.number
let unlockAt = t => t.unlockAt

let isUnlocked = t =>
  switch t.unlockAt {
  | Some(date) => DateFns.isPast(date)
  | None => true
  }

let isLocked = t => !isUnlocked(t)

let sort = levels => ArrayUtils.copyAndSort((x, y) => x.number - y.number, levels)

let first = levels =>
  ArrayUtils.unsafeFind(
    level => level.number == 1,
    "Unable to find level one at CoursesCurriculum__Level",
    levels,
  )

let unlockDateString = t =>
  switch t.unlockAt {
  | None =>
    Rollbar.error("unlockDateString was called for a CoursesCurriculum__Level without unlockAt")
    ""
  | Some(unlockAt) => DateFns.format(unlockAt, "MMM d")
  }

let findByLevelNumber = (levels, levelNumber) => Js.Array.find(l => l.number == levelNumber, levels)

let next = (levels, t) => findByLevelNumber(levels, t.number + 1)

let previous = (levels, t) => {
  let previousLevelNumber = t.number - 1

  if previousLevelNumber == 0 {
    None
  } else {
    findByLevelNumber(levels, previousLevelNumber)
  }
}
