type t = {
  id: string,
  user: UserDetails.t,
  taggings: array<string>,
  level: Shared__Level.t,
  cohort: Cohort.t,
  droppedOutAt: option<Js.Date.t>,
  personalCoaches: array<UserProxy.t>,
}

let id = t => t.id

let level = t => t.level

let taggings = t => t.taggings

let droppedOutAt = t => t.droppedOutAt

let personalCoaches = t => t.personalCoaches

let cohort = t => t.cohort

let user = t => t.user

let make = (~id, ~user, ~taggings, ~level, ~cohort, ~droppedOutAt, ~personalCoaches) => {
  id: id,
  user: user,
  taggings: taggings,
  level: level,
  droppedOutAt: droppedOutAt,
  cohort: cohort,
  personalCoaches: personalCoaches,
}

let makeFromJs = jsObject =>
  make(
    ~id=jsObject["id"],
    ~user=UserDetails.makeFromJs(jsObject["user"]),
    ~taggings=jsObject["taggings"],
    ~level=Shared__Level.makeFromJs(jsObject["level"]),
    ~droppedOutAt=jsObject["droppedOutAt"]->Belt.Option.map(DateFns.parseISO),
    ~cohort=Cohort.makeFromJs(jsObject["cohort"]),
    ~personalCoaches=jsObject["personalCoaches"]->Js.Array2.map(UserProxy.makeFromJs),
  )
