type t = {
  id: string,
  name: string,
  description: option<string>,
  milestone: bool,
  levelId: string,
  sortIndex: int,
  archived: bool,
}

let id = t => t.id

let name = t => t.name

let description = t => t.description

let milestone = t => t.milestone

let levelId = t => t.levelId

let archived = t => t.archived

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    description: json |> field("description", nullable(string)) |> Js.Null.toOption,
    levelId: json |> field("levelId", string),
    milestone: json |> field("milestone", bool),
    sortIndex: json |> field("sortIndex", int),
    archived: json |> field("archived", bool),
  }
}

let create = (id, name, description, milestone, levelId, sortIndex, archived) => {
  id: id,
  name: name,
  description: description,
  milestone: milestone,
  levelId: levelId,
  sortIndex: sortIndex,
  archived: archived,
}

let updateArray = (targetGroups, targetGroup) => {
  targetGroups |> Js.Array.filter(tg => tg.id != targetGroup.id) |> Js.Array.concat([targetGroup])
}

let sort = targetGroups =>
  targetGroups |> ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex)

let unarchive = t => {...t, archived: false}

let unsafeFind = (targetGroups, componentName, id) =>
  targetGroups |> ArrayUtils.unsafeFind(
    l => l.id == id,
    "Unable to find target group with id: " ++ (id ++ ("in CurriculumEditor__" ++ componentName)),
  )

let updateSortIndex = sortedTargetGroups =>
  sortedTargetGroups |> Js.Array.mapi((t, sortIndex) =>
    create(t.id, t.name, t.description, t.milestone, t.levelId, sortIndex, t.archived)
  )
