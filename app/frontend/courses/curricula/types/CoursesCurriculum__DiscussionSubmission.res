exception UnexpectedStatusValue(string)

type t = {
  id: string,
  createdAt: Js.Date.t,
  checklist: array<SubmissionChecklistItem.t>,
  userNames: string,
  teamName: option<string>,
  comments: array<CoursesCurriculum__SubmissionComment.t>,
  reactions: array<CoursesCurriculum__Reaction.t>,
}

let id = t => t.id
let createdAt = t => t.createdAt
let checklist = t => t.checklist
let userNames = t => t.userNames
let teamName = t => t.teamName
let comments = t => t.comments
let reactions = t => t.reactions

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let sort = ts =>
  ts |> ArrayUtils.copyAndSort((t1, t2) => t2.createdAt->DateFns.differenceInSeconds(t1.createdAt))

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    checklist: json |> field(
      "checklist",
      array(
        SubmissionChecklistItem.decode(
          json |> field("files", array(SubmissionChecklistItem.decodeFile)),
        ),
      ),
    ),
    userNames: json |> field("userNames", string),
    teamName: json |> optional(field("teamName", string)),
    comments: json |> field("comments", array(CoursesCurriculum__SubmissionComment.decode)),
    reactions: json |> field("reactions", array(CoursesCurriculum__Reaction.decode)),
  }
}

let make = (~id, ~createdAt, ~checklist, ~userNames, ~teamName, ~comments, ~reactions) => {
  id,
  createdAt,
  checklist,
  userNames,
  teamName,
  comments,
  reactions,
}
