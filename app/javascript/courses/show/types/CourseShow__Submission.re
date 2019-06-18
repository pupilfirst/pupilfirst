type t = {
  id: string,
  description: string,
  createdAt: string,
};

let id = t => t.id;
let description = t => t.description;
let createdAt = t => t.createdAt;

let createdAtPretty = t =>
  t |> createdAt |> DateFns.parseString |> DateFns.format("MMMM D, YYYY");

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    description: json |> field("description", string),
    createdAt: json |> field("createdAt", string),
  };

let make = (~id, ~description, ~createdAt) => {id, description, createdAt};
