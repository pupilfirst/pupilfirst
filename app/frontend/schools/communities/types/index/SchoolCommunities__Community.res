type t = {
  id: string,
  name: string,
  targetLinkable: bool,
  topicCategories: array<SchoolCommunities__Category.t>,
  courseIds: array<string>,
}

module Decode = {
  open Json.Decode

  let school = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    targetLinkable: field.required("targetLinkable", bool),
    topicCategories: field.required(
      "topicCategories",
      array(SchoolCommunities__Category.Decode.category),
    ),
    courseIds: field.required("courseIds", array(string)),
  })
}

let id = t => t.id

let name = t => t.name

let targetLinkable = t => t.targetLinkable

let topicCategories = t => t.topicCategories

let courseIds = t => t.courseIds

let create = (~id, ~name, ~targetLinkable, ~topicCategories, ~courseIds) => {
  id,
  name,
  targetLinkable,
  topicCategories,
  courseIds,
}

let updateList = (community, communities) =>
  List.map(c => c.id == community.id ? community : c, communities)

let removeCategory = (community, categoryId) => {
  let updatedCategories = Js.Array.filter(
    category => SchoolCommunities__Category.id(category) != categoryId,
    community.topicCategories,
  )
  {...community, topicCategories: updatedCategories}
}

let addCategory = (community, category) => {
  ...community,
  topicCategories: Js.Array.concat(community.topicCategories, [category]),
}

let updateCategory = (community, category) => {
  let updatedCategories = Js.Array.map(
    c =>
      SchoolCommunities__Category.id(c) == SchoolCommunities__Category.id(category) ? category : c,
    community.topicCategories,
  )
  {...community, topicCategories: updatedCategories}
}
