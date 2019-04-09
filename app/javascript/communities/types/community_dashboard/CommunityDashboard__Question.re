type t = {
  id: int,
  title: string,
  description: string,
};

let id = t => t.id;

let description = t => t.description;

let title = t => t.title;

let sort = question => question |> List.sort((x, y) => x.id - y.id);

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
  };