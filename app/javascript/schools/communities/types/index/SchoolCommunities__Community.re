type t = {
  id: string,
  name: string,
  targetLinkable: bool,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    targetLinkable: json |> field("targetLinkable", bool),
  };

let id = t => t.id;

let name = t => t.name;

let targetLinkable = t => t.targetLinkable;

let create = (id, name, targetLinkable) => {id, name, targetLinkable};

let updateList = (community, communities) =>
  communities |> List.map(c => c.id == community.id ? community : c);