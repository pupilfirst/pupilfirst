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
}

let id = t => t.id

let title = t => t.title

let targetGroupId = t => t.targetGroupId

let sortIndex = t => t.sortIndex

let visibility = t => t.visibility

let milestone = t => t.milestone

let decodeVisbility = visibilityString =>
  switch visibilityString {
  | "draft" => Draft
  | "live" => Live
  | "archived" => Archived
  | _ => raise(InvalidVisibilityValue("Unknown Value"))
  }

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    targetGroupId: json |> field("targetGroupId", string),
    title: json |> field("title", string),
    sortIndex: json |> field("sortIndex", int),
    visibility: decodeVisbility(json |> field("visibility", string)),
    milestone: json |> field("milestone", bool),
  }
}

let updateArray = (targets, target) => {
  targets |> Js.Array.filter(t => t.id != target.id) |> Js.Array.concat([target])
}

let create = (~id, ~targetGroupId, ~title, ~sortIndex, ~visibility, ~milestone) => {
  id: id,
  targetGroupId: targetGroupId,
  title: title,
  sortIndex: sortIndex,
  visibility: visibility,
  milestone: milestone,
}

let sort = targets => targets |> ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex)

let archive = t => {...t, visibility: Archived}

let archived = t =>
  switch t.visibility {
  | Archived => true
  | Live => false
  | Draft => false
  }

let removeTarget = (target, targets) => targets |> Js.Array.filter(t => t.id != target.id)

let targetIdsInTargetGroup = (targetGroupId, targets) =>
  targets |> Js.Array.filter(t => t.targetGroupId == targetGroupId) |> Js.Array.map(t => t.id)

let updateSortIndex = sortedTargets =>
  sortedTargets |> Js.Array.mapi((t, sortIndex) =>
    create(
      ~id=t.id,
      ~targetGroupId=t.targetGroupId,
      ~title=t.title,
      ~sortIndex,
      ~visibility=t.visibility,
      ~milestone=t.milestone,
    )
  )

let template = (id, targetGroupId, title) =>
  create(~id, ~targetGroupId, ~title, ~sortIndex=999, ~visibility=Draft, ~milestone=false)
