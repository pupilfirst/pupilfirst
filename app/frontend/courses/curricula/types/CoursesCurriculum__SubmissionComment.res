type id = string

type t = {
  id: id,
  userId: string,
  user: CoursesCurriculum__User.t,
  submissionId: string,
  comment: string,
  reactions: array<CoursesCurriculum__Reaction.t>,
  moderationReports: array<CoursesCurriculum__ModerationReport.t>,
  createdAt: Js.Date.t,
  hiddenAt: option<Js.Date.t>,
  hiddenById: option<string>,
}

let id = t => t.id
let userId = t => t.userId
let user = t => t.user
let submissionId = t => t.submissionId
let comment = t => t.comment
let reactions = t => t.reactions
let moderationReports = t => t.moderationReports
let createdAt = t => t.createdAt
let hiddenAt = t => t.hiddenAt
let hiddenById = t => t.hiddenById

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")
let hiddenAtPretty = t =>
  switch t.hiddenAt {
  | Some(hiddenAt) => hiddenAt->DateFns.format("MMMM d, yyyy")
  | None => ""
  }

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    userId: field("userId", string, json),
    user: field("user", CoursesCurriculum__User.decode, json),
    submissionId: field("submissionId", string, json),
    comment: field("comment", string, json),
    reactions: field("reactions", array(CoursesCurriculum__Reaction.decode), json),
    createdAt: field("createdAt", DateFns.decodeISO, json),
    hiddenAt: option(field("hiddenAt", DateFns.decodeISO), json),
    hiddenById: option(field("hiddenById", string), json),
    moderationReports: field(
      "moderationReports",
      array(CoursesCurriculum__ModerationReport.decode),
      json,
    ),
  }
}
