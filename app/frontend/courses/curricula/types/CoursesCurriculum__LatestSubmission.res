type t = {
  targetId: string,
  passedAt: option<Js.Date.t>,
  evaluatedAt: option<Js.Date.t>,
}

let decode = json => {
  open Json.Decode
  {
    targetId: field("targetId", string, json),
    passedAt: option(field("passedAt", string), json)->Belt.Option.map(DateFns.parseISO),
    evaluatedAt: option(field("evaluatedAt", string), json)->Belt.Option.map(DateFns.parseISO),
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
  targetId,
  passedAt: pending ? None : Some(Js.Date.make()),
  evaluatedAt: None,
}
