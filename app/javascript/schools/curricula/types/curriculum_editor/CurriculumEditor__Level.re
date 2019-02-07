type t = {
  id: int,
  name: string,
};

let name = t => t.name;

let id = t => t.id;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
  };

let selectLevel = (levels, level_name) =>
  levels |> List.find(q => q.name == level_name);