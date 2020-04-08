type t = {
  id,
  title: string,
}
and id = string;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
  };
