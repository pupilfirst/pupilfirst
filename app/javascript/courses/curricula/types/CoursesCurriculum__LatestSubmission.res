type t = {
  targetId: string,
  passedAt: option<Js.Date.t>,
  evaluatedAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    targetId: json |> field("targetId", string),
    passedAt: (json |> optional(field("passedAt", string)))->Belt.Option.map(DateFns.parseISO),
    evaluatedAt: (json |> optional(field("evaluatedAt", string)))
      ->Belt.Option.map(DateFns.parseISO),
  }
}

let targetId = t => t.targetId

let hasPassed = t =>
  switch t.passedAt {
  | Some(_time) => true
  | None => false
  }

let hasBeenEvaluated = t =>
  switch t.evaluatedAt {
  | Some(_time) => true
  | None => false
  }

let make = (~pending, ~targetId) => {
  targetId: targetId,
  passedAt: pending ? None : Some(Js.Date.make()),
  evaluatedAt: None,
}
