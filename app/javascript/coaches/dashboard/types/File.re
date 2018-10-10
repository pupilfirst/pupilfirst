type t = {
  title: string,
  id: int,
};

let decode = json =>
  Json.Decode.{
    title: json |> field("title", string),
    id: json |> field("id", int),
  };

let title = t => t.title;

let id = t => t.id;