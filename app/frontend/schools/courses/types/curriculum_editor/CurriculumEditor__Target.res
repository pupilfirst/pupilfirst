exception InvalidVisibilityValue(string)

type visibility =
  | Draft
  | Live
  | Archived

type t = {
  id: string,
  targetGroupId: string,
  title: string,
  sortIndex: int,
  visibility: visibility,
  milestone: bool,
  hasAssignment: bool,
}

let id = t => t.id

let title = t => t.title

let targetGroupId = t => t.targetGroupId

let sortIndex = t => t.sortIndex

let visibility = t => t.visibility

let milestone = t => t.milestone

let hasAssignment = t => t.hasAssignment

module Decode = {
  open Json.Decode

  let decodeVisibility = string->map(visibilityString =>
    switch visibilityString {
    | "draft" => Draft
    | "live" => Live
    | "archived" => Archived
    | _ => raise(InvalidVisibilityValue("Unknown Value"))
    }
  )

  let target = object(field => {
    id: field.required("id", string),
    targetGroupId: field.required("targetGroupId", string),
    title: field.required("title", string),
    sortIndex: field.required("sortIndex", int),
    visibility: field.required("visibility", decodeVisibility),
    milestone: field.required("milestone", bool),
    hasAssignment: field.required("hasAssignment", bool),
  })
}

let updateArray = (targets, target) => {
  Js.Array.concat([target], Js.Array.filter(t => t.id != target.id, targets))
}

let create = (~id, ~targetGroupId, ~title, ~sortIndex, ~visibility, ~milestone, ~hasAssignment) => {
  id,
  targetGroupId,
  title,
  sortIndex,
  visibility,
  milestone,
  hasAssignment,
}

let sort = targets => ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex, targets)

let archive = t => {...t, visibility: Archived}

let archived = t =>
  switch t.visibility {
  | Archived => true
  | Live => false
  | Draft => false
  }

let removeTarget = (target, targets) => Js.Array.filter(t => t.id != target.id, targets)

let targetIdsInTargetGroup = (targetGroupId, targets) =>
  Js.Array.map(t => t.id, Js.Array.filter(t => t.targetGroupId == targetGroupId, targets))

let updateSortIndex = sortedTargets =>
  Js.Array.mapi(
    (t, sortIndex) =>
      create(
        ~id=t.id,
        ~targetGroupId=t.targetGroupId,
        ~title=t.title,
        ~sortIndex,
        ~visibility=t.visibility,
        ~milestone=t.milestone,
        ~hasAssignment=t.hasAssignment,
      ),
    sortedTargets,
  )

let template = (id, targetGroupId, title) =>
  create(
    ~id,
    ~targetGroupId,
    ~title,
    ~sortIndex=999,
    ~visibility=Draft,
    ~milestone=false,
    ~hasAssignment=false,
  )
