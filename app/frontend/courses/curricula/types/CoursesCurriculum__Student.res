type t = {
  @live
  levelId: string,
  endsAt: option<Js.Date.t>,
  completedAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    levelId: field("levelId", string, json),
    endsAt: option(field("endsAt", string), json)->Belt.Option.map(DateFns.parseISO),
    completedAt: option(field("completedAt", string), json)->Belt.Option.map(DateFns.parseISO),
  }
}

let levelId = t => t.levelId
let endsAt = t => t.endsAt
let completedAt = t => t.completedAt

let accessEnded = t => t.endsAt->Belt.Option.mapWithDefault(false, DateFns.isPast)
