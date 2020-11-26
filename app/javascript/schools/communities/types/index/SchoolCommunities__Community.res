type t = {
  id: string,
  name: string,
  targetLinkable: bool,
  topicCategories: array<SchoolCommunities__Category.t>,
  courseIds: array<string>,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    targetLinkable: json |> field("targetLinkable", bool),
    topicCategories: json |> field("topicCategories", array(SchoolCommunities__Category.decode)),
    courseIds: json |> field("courseIds", array(string)),
  }
}

let id = t => t.id

let name = t => t.name

let targetLinkable = t => t.targetLinkable

let topicCategories = t => t.topicCategories

let courseIds = t => t.courseIds

let create = (~id, ~name, ~targetLinkable, ~topicCategories, ~courseIds) => {
  id: id,
  name: name,
  targetLinkable: targetLinkable,
  topicCategories: topicCategories,
  courseIds: courseIds,
}

let updateList = (community, communities) =>
  communities |> List.map(c => c.id == community.id ? community : c)

let removeCategory = (community, categoryId) => {
  let updatedCategories =
    community.topicCategories |> Js.Array.filter(category =>
      SchoolCommunities__Category.id(category) != categoryId
    )
  {...community, topicCategories: updatedCategories}
}

let addCategory = (community, category) => {
  ...community,
  topicCategories: Js.Array.concat(community.topicCategories, [category]),
}

let updateCategory = (community, category) => {
  let updatedCategories =
    community.topicCategories |> Js.Array.map(c =>
      SchoolCommunities__Category.id(c) == SchoolCommunities__Category.id(category) ? category : c
    )
  {...community, topicCategories: updatedCategories}
}
