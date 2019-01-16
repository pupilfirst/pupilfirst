type t = {
  id: int,
  name: string,
  avatarUrl: string,
};

let name = t => t.name;

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    avatarUrl: json |> field("avatarUrl", string),
  };

let founderNames = (founders: list(t)) => founders |> List.map(founder => founder.name) |> String.concat(", ");

let withIds = (ids, founders) => founders |> List.filter(founder => List.mem(founder.id, ids));
