type t = {
  id: string,
  createdAt: Js.Date.t,
  passedAt: option<Js.Date.t>,
  feedbackSent: bool,
  evaluatedAt: option<Js.Date.t>,
  archivedAt: option<Js.Date.t>,
}

let id = t => t.id
let createdAt = t => t.createdAt
let passedAt = t => t.passedAt
let evaluatedAt = t => t.evaluatedAt
let feedbackSent = t => t.feedbackSent
let archivedAt = t => t.archivedAt

let make = (~id, ~createdAt, ~passedAt, ~evaluatedAt, ~feedbackSent, ~archivedAt) => {
  id: id,
  createdAt: createdAt,
  passedAt: passedAt,
  feedbackSent: feedbackSent,
  evaluatedAt: evaluatedAt,
  archivedAt: archivedAt,
}

let makeFromJs = details =>
  details |> Js.Array.map(s =>
    make(
      ~id=s["id"],
      ~createdAt=DateFns.decodeISO(s["createdAt"]),
      ~passedAt=s["passedAt"]->Belt.Option.map(DateFns.decodeISO),
      ~evaluatedAt=s["evaluatedAt"]->Belt.Option.map(DateFns.decodeISO),
      ~feedbackSent=s["feedbackSent"],
      ~archivedAt=s["archivedAt"]->Belt.Option.map(DateFns.decodeISO),
    )
  )
