type t = {
  id: int,
  title: string,
  description: string,
  userId: int,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    description: json |> field("title", string),
    userId: json |> field("userId", int),
  };