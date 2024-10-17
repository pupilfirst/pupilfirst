type t = {
  id: string,
  name: string,
  description: option<string>,
  levelId: string,
  sortIndex: int,
  archived: bool,
}

let id = t => t.id

let name = t => t.name

let description = t => t.description

let levelId = t => t.levelId

let archived = t => t.archived

module Decode = {
  open Json.Decode

  let targetGroup = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    description: field.optional("description", option(string))->OptionUtils.flat,
    levelId: field.required("levelId", string),
    sortIndex: field.required("sortIndex", int),
    archived: field.required("archived", bool),
  })
}

let create = (id, name, description, levelId, sortIndex, archived) => {
  id,
  name,
  description,
  levelId,
  sortIndex,
  archived,
}

let updateArray = (targetGroups, targetGroup) => {
  targetGroups->Array.filter(tg => tg.id != targetGroup.id)->Array.concat([targetGroup])
}

let sort = targetGroups => ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex, targetGroups)

let unarchive = t => {...t, archived: false}

let unsafeFind = (targetGroups, componentName, id) =>
  ArrayUtils.unsafeFind(
    l => l.id == id,
    "Unable to find target group with id: " ++ (id ++ ("in CurriculumEditor__" ++ componentName)),
    targetGroups,
  )

let updateSortIndex = sortedTargetGroups =>
  sortedTargetGroups->Array.mapWithIndex((t, sortIndex) =>
    create(t.id, t.name, t.description, t.levelId, sortIndex, t.archived)
  )
