type t = {
  name: string,
  number: int,
  id: string,
};

let name = t => t.name;

let number = t => t.number;

let id = t => t.id;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
  };
