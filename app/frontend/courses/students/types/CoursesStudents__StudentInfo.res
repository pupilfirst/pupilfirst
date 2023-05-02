type t = {
  id: string,
  user: UserDetails.t,
  taggings: array<string>,
  cohort: Cohort.t,
  droppedOutAt: option<Js.Date.t>,
  personalCoaches: array<UserProxy.t>,
}

let id = t => t.id

let taggings = t => t.taggings

let droppedOutAt = t => t.droppedOutAt

let personalCoaches = t => t.personalCoaches

let cohort = t => t.cohort

let user = t => t.user

let make = (~id, ~user, ~taggings, ~cohort, ~droppedOutAt, ~personalCoaches) => {
  id: id,
  user: user,
  taggings: taggings,
  droppedOutAt: droppedOutAt,
  cohort: cohort,
  personalCoaches: personalCoaches,
}
