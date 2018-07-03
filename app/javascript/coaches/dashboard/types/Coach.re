type t = {
  name: string,
  id: int,
};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
  };

let name = t => t.name;