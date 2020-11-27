type rec targetRole =
  | Student
  | Team(array<studentId>)
and studentId = string

type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  status: [#PendingReview | #Rejected | #Completed],
  levelId: string,
  targetId: string,
  targetRole: targetRole,
}

let make = (~id, ~title, ~createdAt, ~levelId, ~status, ~targetId, ~targetRole) => {
  id: id,
  title: title,
  createdAt: createdAt,
  status: status,
  levelId: levelId,
  targetId: targetId,
  targetRole: targetRole,
}

let id = t => t.id

let levelId = t => t.levelId

let title = t => t.title

let status = t => t.status

let createdAt = t => t.createdAt

let targetId = t => t.targetId

let targetRole = t => t.targetRole

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let makeFromJs = submissions => submissions |> Js.Array.map(submission =>
    switch submission {
    | Some(submission) =>
      let createdAt = submission["createdAt"] |> DateFns.decodeISO
      let status = switch submission["passedAt"] {
      | Some(_passedAt) => #Completed
      | None =>
        switch submission["evaluatedAt"] {
        | Some(_time) => #Rejected
        | None => #PendingReview
        }
      }
      let targetRole = submission["teamTarget"] ? Team(submission["studentIds"]) : Student
      list{
        make(
          ~id=submission["id"],
          ~title=submission["title"],
          ~createdAt,
          ~levelId=submission["levelId"],
          ~targetId=submission["targetId"],
          ~targetRole,
          ~status,
        ),
      }
    | None => list{}
    }
  )
