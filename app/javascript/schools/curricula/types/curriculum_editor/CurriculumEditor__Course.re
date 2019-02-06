type t = {
  id: int,
  name: string,
};

let name = t => t.name;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
  };