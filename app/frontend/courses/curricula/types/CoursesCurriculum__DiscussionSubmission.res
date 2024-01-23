exception UnexpectedStatusValue(string)

type t = {
  id: string,
  targetId: string,
  createdAt: Js.Date.t,
  checklist: array<SubmissionChecklistItem.t>,
  userNames: string,
  teamName: option<string>,
  comments: array<CoursesCurriculum__SubmissionComment.t>,
  reactions: array<CoursesCurriculum__Reaction.t>,
  anonymous: bool,
  pinned: bool,
  moderationReports: array<CoursesCurriculum__ModerationReport.t>,
}

let id = t => t.id
let targetId = t => t.targetId
let createdAt = t => t.createdAt
let checklist = t => t.checklist
let userNames = t => t.userNames
let teamName = t => t.teamName
let comments = t => t.comments
let reactions = t => t.reactions
let anonymous = t => t.anonymous
let pinned = t => t.pinned
let moderationReports = t => t.moderationReports

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let sort = ts =>
  ts |> ArrayUtils.copyAndSort((t1, t2) => t2.createdAt->DateFns.differenceInSeconds(t1.createdAt))

let compareByPinned = (a, b) => {
  if a.pinned === b.pinned {
    0
  } /* Elements are equal */
  else if a.pinned {
    -1
  } else {
    /* a should come before b */

    1 /* b should come before a */
  }
}

let sortByPinned = submissions =>
  submissions |> ArrayUtils.copyAndSort((t1, t2) => compareByPinned(t1, t2))

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    targetId: json |> field("targetId", string),
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
    anonymous: json |> field("anonymous", bool),
    pinned: json |> field("pinned", bool),
    moderationReports: json |> field(
      "moderationReports",
      array(CoursesCurriculum__ModerationReport.decode),
    ),
  }
}

let make = (
  ~id,
  ~targetId,
  ~createdAt,
  ~checklist,
  ~userNames,
  ~teamName,
  ~comments,
  ~reactions,
  ~anonymous,
  ~pinned,
  ~moderationReports,
) => {
  id,
  targetId,
  createdAt,
  checklist,
  userNames,
  teamName,
  comments,
  reactions,
  anonymous,
  pinned,
  moderationReports,
}
