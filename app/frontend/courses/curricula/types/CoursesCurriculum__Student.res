type t = {
  @live
  levelId: string,
  endsAt: option<Js.Date.t>,
  completedAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    levelId: json |> field("levelId", string),
    endsAt: (json |> optional(field("endsAt", string)))->Belt.Option.map(DateFns.parseISO),
    completedAt: (json |> optional(field("completedAt", string)))
      ->Belt.Option.map(DateFns.parseISO),
  }
}

let levelId = t => t.levelId
let endsAt = t => t.endsAt
let completedAt = t => t.completedAt

let accessEnded = t => t.endsAt->Belt.Option.mapWithDefault(false, DateFns.isPast)
