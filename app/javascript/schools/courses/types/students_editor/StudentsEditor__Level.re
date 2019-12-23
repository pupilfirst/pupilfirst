type t = {
  name: string,
  number: int,
};

let name = t => t.name;

let number = t => t.number;

let decode = json => Json.Decode.{name: json |> field("name", string), number: json |> field("number", int)};
