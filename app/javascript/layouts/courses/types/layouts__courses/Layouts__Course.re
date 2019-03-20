type t = {
  id: int,
  name: string,
  path: string,
};

let name = t => t.name;

let id = t => t.id;

let path = t => t.path;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    path: json |> field("path", string),
  };

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);