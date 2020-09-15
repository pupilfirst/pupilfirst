type t = {
  id: string,
  name: string,
  targetLinkable: bool,
  topicCategories: array(SchoolCommunities__Category.t),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    targetLinkable: json |> field("targetLinkable", bool),
    topicCategories:
      json
      |> field("topicCategories", array(SchoolCommunities__Category.decode)),
  };

let id = t => t.id;

let name = t => t.name;

let targetLinkable = t => t.targetLinkable;

let topicCategories = t => t.topicCategories;

let create = (id, name, targetLinkable, topicCategories) => {
  id,
  name,
  targetLinkable,
  topicCategories,
};

let updateList = (community, communities) =>
  communities |> List.map(c => c.id == community.id ? community : c);

let makeFromJs = data => {
  id: data##id,
  name: data##name,
  targetLinkable: data##targetLinkable,
  topicCategories:
    Array.map(
      category => SchoolCommunities__Category.makeFromJs(category),
      data##topicCategories,
    ),
};
