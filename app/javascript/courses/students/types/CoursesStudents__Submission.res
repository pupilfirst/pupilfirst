type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  passedAt: option<Js.Date.t>,
  evaluatedAt: option<Js.Date.t>,
  levelId: string,
}

let make = (~id, ~title, ~createdAt, ~passedAt, ~levelId, ~evaluatedAt) => {
  id: id,
  title: title,
  createdAt: createdAt,
  passedAt: passedAt,
  levelId: levelId,
  evaluatedAt: evaluatedAt,
}

let id = t => t.id

let levelId = t => t.levelId

let title = t => t.title

let evaluatedAt = t => t.evaluatedAt

let sort = submissions =>
  submissions |> ArrayUtils.copyAndSort((x, y) =>
    DateFns.differenceInSeconds(y.createdAt, x.createdAt)
  )

let failed = t =>
  switch t.passedAt {
  | Some(_passedAt) => false
  | None => true
  }

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let timeDistance = t => t.createdAt->DateFns.formatDistanceToNowStrict(~addSuffix=true, ())

let makeFromJs = submissions => submissions |> Js.Array.map(submission =>
    switch submission {
    | Some(submission) =>
      let createdAt = submission["createdAt"]->DateFns.decodeISO

      let passedAt = submission["passedAt"]->Belt.Option.map(DateFns.decodeISO)

      let evaluatedAt = submission["evaluatedAt"]->Belt.Option.map(DateFns.decodeISO)

      list{
        make(
          ~id=submission["id"],
          ~title=submission["title"],
          ~createdAt,
          ~passedAt,
          ~levelId=submission["levelId"],
          ~evaluatedAt,
        ),
      }
    | None => list{}
    }
  )
