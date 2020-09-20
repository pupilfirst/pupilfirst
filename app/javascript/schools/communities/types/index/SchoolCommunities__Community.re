type t = {
  id: string,
  name: string,
  targetLinkable: bool,
  topicCategories: array(SchoolCommunities__Category.t),
  courseIds: array(string),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    targetLinkable: json |> field("targetLinkable", bool),
    topicCategories:
      json
      |> field("topicCategories", array(SchoolCommunities__Category.decode)),
    courseIds: json |> field("courseIds", array(string)),
  };

let id = t => t.id;

let name = t => t.name;

let targetLinkable = t => t.targetLinkable;

let topicCategories = t => t.topicCategories;

let courseIds = t => t.courseIds;

let create = (~id, ~name, ~targetLinkable, ~topicCategories, ~courseIds) => {
  id,
  name,
  targetLinkable,
  topicCategories,
  courseIds,
};

let updateList = (community, communities) =>
  communities |> List.map(c => c.id == community.id ? community : c);
