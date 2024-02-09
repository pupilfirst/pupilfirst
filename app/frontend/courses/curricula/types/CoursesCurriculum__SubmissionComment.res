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
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    user: json |> field("user", CoursesCurriculum__User.decode),
    submissionId: json |> field("submissionId", string),
    comment: json |> field("comment", string),
    reactions: json |> field("reactions", array(CoursesCurriculum__Reaction.decode)),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    hiddenAt: json |> optional(field("hiddenAt", DateFns.decodeISO)),
    hiddenById: json |> optional(field("hiddenById", string)),
    moderationReports: json |> field(
      "moderationReports",
      array(CoursesCurriculum__ModerationReport.decode),
    ),
  }
}
