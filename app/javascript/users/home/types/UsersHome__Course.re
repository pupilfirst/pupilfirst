type t = {
  id: string,
  name: string,
  links: array(string),
  description: string,
  exited: bool,
  thumbnailUrl: option(string),
  linkedCommunities: array(string),
  ended: bool,
};

let name = t => t.name;
let id = t => t.id;
let links = t => t.links;
let description = t => t.description;
let exited = t => t.exited;
let thumbnailUrl = t => t.thumbnailUrl;
let linkedCommunities = t => t.linkedCommunities;
let ended = t => t.ended;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    description: json |> field("description", string),
    exited: json |> field("exited", bool),
    links: json |> field("links", array(string)),
    thumbnailUrl:
      json |> field("thumbnailUrl", nullable(string)) |> Js.Null.toOption,
    linkedCommunities: json |> field("linkedCommunities", array(string)),
    ended: json |> field("ended", bool),
  };
