type t = {
  id,
  title: string,
}
and id = string;

let title = t => t.title;

let id = t => t.id;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
  };
