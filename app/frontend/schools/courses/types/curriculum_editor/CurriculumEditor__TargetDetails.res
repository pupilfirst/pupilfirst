exception InvalidVisibilityValue(string)

type visibility =
  | Draft
  | Live
  | Archived

type t = {
  title: string,
  targetGroupId: string,
  visibility: visibility,
  assignmentId: string,
}

let title = t => t.title

let targetGroupId = t => t.targetGroupId

let visibility = t => t.visibility

let assignmentId = t => t.assignmentId

let visibilityFromJs = visibilityString =>
  switch visibilityString {
  | "draft" => Draft
  | "live" => Live
  | "archived" => Archived
  | _ => raise(InvalidVisibilityValue("Unknown Value"))
  }

let visibilityAsString = visibility =>
  switch visibility {
  | Draft => "draft"
  | Live => "live"
  | Archived => "archived"
  }

let makeFromJs = targetData => {
  title: targetData["title"],
  targetGroupId: targetData["targetGroupId"],
  visibility: visibilityFromJs(targetData["visibility"]),
  assignmentId: targetData["assignmentId"],
}
