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

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);