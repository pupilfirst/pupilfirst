type t = {
  id: string,
  taggings: array<string>,
  user: Admin__User.t,
  level: Shared__Level.t,
  cohort: Cohort.t,
}

let id = t => t.id
let taggings = t => t.taggings
let level = t => t.level
let cohort = t => t.cohort
let user = t => t.user

let make = (~id, ~taggings, ~user, ~level, ~cohort) => {
  id: id,
  taggings: taggings,
  user: user,
  level: level,
  cohort: cohort,
}

let makeFromJS = studentDetails =>
  make(
    ~id=studentDetails["id"],
    ~taggings=studentDetails["taggings"],
    ~user=Admin__User.makeFromJs(studentDetails["user"]),
    ~level=Shared__Level.makeFromJs(studentDetails["level"]),
    ~cohort=Cohort.makeFromJs(studentDetails["cohort"]),
  )
