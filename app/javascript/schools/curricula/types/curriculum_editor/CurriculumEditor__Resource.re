type t = {
  id: int,
  title: string,
};

let id = t => t.id;

let title = t => t.title;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
  };

let create = (id, title) => {id, title};