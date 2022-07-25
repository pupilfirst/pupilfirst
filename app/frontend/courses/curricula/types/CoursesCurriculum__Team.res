type t = {
  @live
  name: string,
  levelId: string,
  accessEndsAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    name: json |> field("name", string),
    levelId: json |> field("levelId", string),
    accessEndsAt: (json |> optional(field("accessEndsAt", string)))
      ->Belt.Option.map(DateFns.parseISO),
  }
}

let levelId = t => t.levelId
let accessEndsAt = t => t.accessEndsAt

let accessEnded = t => t.accessEndsAt->Belt.Option.mapWithDefault(false, DateFns.isPast)
