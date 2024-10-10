exception UnexpectedStatusValue(string)

type t = {
  id: string,
  targetId: string,
  createdAt: Js.Date.t,
  checklist: array<SubmissionChecklistItem.t>,
  userNames: string,
  users: array<CoursesCurriculum__User.t>,
  teamName: option<string>,
  comments: array<CoursesCurriculum__SubmissionComment.t>,
  reactions: array<CoursesCurriculum__Reaction.t>,
  anonymous: bool,
  pinned: bool,
  moderationReports: array<CoursesCurriculum__ModerationReport.t>,
  hiddenAt: option<Js.Date.t>,
}

let id = t => t.id
let targetId = t => t.targetId
let createdAt = t => t.createdAt
let checklist = t => t.checklist
let userNames = t => t.userNames
let users = t => t.users
let teamName = t => t.teamName
let comments = t => t.comments
let reactions = t => t.reactions
let anonymous = t => t.anonymous
let pinned = t => t.pinned
let moderationReports = t => t.moderationReports
let hiddenAt = t => t.hiddenAt

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")
let hiddenAtPretty = t =>
  switch t.hiddenAt {
  | Some(hiddenAt) => hiddenAt->DateFns.format("MMMM d, yyyy")
  | None => ""
  }

let sort = ts =>
  ArrayUtils.copyAndSort((t1, t2) => t2.createdAt->DateFns.differenceInSeconds(t1.createdAt), ts)

let firstUser = t => t.users[0]

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    targetId: field("targetId", string, json),
    createdAt: field("createdAt", DateFns.decodeISO, json),
    checklist: field(
      "checklist",
      array(
        SubmissionChecklistItem.decode(
          field("files", array(SubmissionChecklistItem.decodeFile), json),
        ),
      ),
      json,
    ),
    userNames: field("userNames", string, json),
    users: field("users", array(CoursesCurriculum__User.decode), json),
    teamName: option(field("teamName", string), json),
    comments: field("comments", array(CoursesCurriculum__SubmissionComment.decode), json),
    reactions: field("reactions", array(CoursesCurriculum__Reaction.decode), json),
    anonymous: field("anonymous", bool, json),
    pinned: field("pinned", bool, json),
    moderationReports: field(
      "moderationReports",
      array(CoursesCurriculum__ModerationReport.decode),
      json,
    ),
    hiddenAt: option(field("hiddenAt", DateFns.decodeISO), json),
  }
}

let make = (
  ~id,
  ~targetId,
  ~createdAt,
  ~checklist,
  ~userNames,
  ~users,
  ~teamName,
  ~comments,
  ~reactions,
  ~anonymous,
  ~pinned,
  ~moderationReports,
  ~hiddenAt,
) => {
  id,
  targetId,
  createdAt,
  checklist,
  userNames,
  users,
  teamName,
  comments,
  reactions,
  anonymous,
  pinned,
  moderationReports,
  hiddenAt,
}
