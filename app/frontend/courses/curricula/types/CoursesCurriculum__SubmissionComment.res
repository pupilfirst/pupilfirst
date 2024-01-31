type id = string

type t = {
  id: id,
  userId: string,
  userName: string,
  submissionId: string,
  comment: string,
  reactions: array<CoursesCurriculum__Reaction.t>,
  moderationReports: array<CoursesCurriculum__ModerationReport.t>,
  updatedAt: Js.Date.t,
  hiddenAt: option<Js.Date.t>,
  hiddenById: option<string>,
}

let id = t => t.id
let userId = t => t.userId
let userName = t => t.userName
let submissionId = t => t.submissionId
let comment = t => t.comment
let reactions = t => t.reactions
let moderationReports = t => t.moderationReports
let updatedAt = t => t.updatedAt
let hiddenAt = t => t.hiddenAt
let hiddenById = t => t.hiddenById

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    userName: json |> field("userName", string),
    submissionId: json |> field("submissionId", string),
    comment: json |> field("comment", string),
    reactions: json |> field("reactions", array(CoursesCurriculum__Reaction.decode)),
    updatedAt: json |> field("updatedAt", DateFns.decodeISO),
    hiddenAt: json |> optional(field("hiddenAt", DateFns.decodeISO)),
    hiddenById: json |> optional(field("hiddenById", string)),
    moderationReports: json |> field(
      "moderationReports",
      array(CoursesCurriculum__ModerationReport.decode),
    ),
  }
}
