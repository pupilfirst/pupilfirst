type rec targetRole =
  | Student
  | Team(array<studentId>)
and studentId = string

type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  status: [#PendingReview | #Rejected | #Completed],
  targetId: string,
  targetRole: targetRole,
  milestoneNumber: option<int>,
}

let make = (
  ~id,
  ~title,
  ~createdAt,
  ~status,
  ~targetId,
  ~targetRole,
  ~milestoneNumber,
) => {
  id: id,
  title: title,
  createdAt: createdAt,
  status: status,
  targetId: targetId,
  targetRole: targetRole,
  milestoneNumber: milestoneNumber,
}

let id = t => t.id

let title = t => t.title

let status = t => t.status

let createdAt = t => t.createdAt

let targetId = t => t.targetId

let targetRole = t => t.targetRole

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let milestoneNumber = t => t.milestoneNumber

let makeFromJs = submissions => Js.Array.map(submission => {
    let createdAt = DateFns.decodeISO(submission["createdAt"])
    let status = switch submission["passedAt"] {
    | Some(_passedAt) => #Completed
    | None =>
      switch submission["evaluatedAt"] {
      | Some(_time) => #Rejected
      | None => #PendingReview
      }
    }
    let targetRole = submission["teamTarget"] ? Team(submission["studentIds"]) : Student

    make(
      ~id=submission["id"],
      ~title=submission["title"],
      ~createdAt,
      ~targetId=submission["targetId"],
      ~targetRole,
      ~status,
      ~milestoneNumber=submission["milestoneNumber"],
    )
  }, submissions)
