type t = {
  id: string,
  name: string,
  number: int,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
  };

let id = t => t.id;
let name = t => t.name;
let number = t => t.number;

let sort = levels => levels |> List.sort((x, y) => x.number - y.number);
