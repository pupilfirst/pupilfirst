type t = {
  id: string,
  name: string,
  number: int,
  unlockAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
    unlockAt: json |> optional(field("unlockAt", DateFns.decodeISO)),
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

let isLocked = t => !(t |> isUnlocked)

let sort = levels => levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number)

let first = levels => levels->sort->Js.Array.unsafe_get(0)

let unlockDateString = t =>
  switch t.unlockAt {
  | None =>
    Rollbar.error("unlockDateString was called for a CoursesCurriculum__Level without unlockAt")
    ""
  | Some(unlockAt) => DateFns.format(unlockAt, "MMM d")
  }

let findByLevelNumber = (levels, levelNumber) =>
  levels |> Js.Array.find(l => l.number == levelNumber)

let next = (levels, t) => t.number + 1 |> findByLevelNumber(levels)

let previous = (levels, t) => {
  let previousLevelNumber = t.number - 1

  if previousLevelNumber == 0 {
    None
  } else {
    previousLevelNumber |> findByLevelNumber(levels)
  }
}
