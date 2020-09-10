type t = {
  id: string,
  name: string,
  communityId: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    communityId: json |> field("communityId", string),
  };

let id = t => t.id;

let name = t => t.name;

let communityId = t => t.communityId;
