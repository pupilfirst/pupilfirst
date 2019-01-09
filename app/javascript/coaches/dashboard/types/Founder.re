type t = {
  id: int,
  name: string,
};

let name = t => t.name;

let id = t => t.id;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
  };

let founderNames = (founders: list(t)) =>
  founders |> List.map(founder => founder.name) |> String.concat(", ");