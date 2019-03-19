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

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let create = (id, name) => {id, name};