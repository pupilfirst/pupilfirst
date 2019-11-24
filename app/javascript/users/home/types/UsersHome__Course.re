type t = {
  id: string,
  name: string,
  links: array(string),
  description: string,
  exited: bool,
  imageUrl: option(string),
  linkedCommunities: array(string),
};

let name = t => t.name;
let id = t => t.id;
let links = t => t.links;
let description = t => t.description;
let exited = t => t.exited;
let imageUrl = t => t.imageUrl;
let linkedCommunities = t => t.linkedCommunities;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    description: json |> field("description", string),
    exited: json |> field("exited", bool),
    links: json |> field("links", array(string)),
    imageUrl:
      json |> field("imageUrl", nullable(string)) |> Js.Null.toOption,
    linkedCommunities: json |> field("linkedCommunities", array(string)),
  };
