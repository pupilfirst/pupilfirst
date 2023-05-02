type t = {
  id: string,
  taggings: array<string>,
  user: Admin__User.t,
  cohort: Cohort.t,
}

let id = t => t.id
let taggings = t => t.taggings
let cohort = t => t.cohort
let user = t => t.user

let make = (~id, ~taggings, ~user, ~cohort) => {
  id: id,
  taggings: taggings,
  user: user,
  cohort: cohort,
}
