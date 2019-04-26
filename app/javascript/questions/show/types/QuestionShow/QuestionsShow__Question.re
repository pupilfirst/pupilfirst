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
    description: json |> field("description", string),
    userId: json |> field("userId", int),
  };

let id = t => t.id;

let title = t => t.title;

let description = t => t.description;

let userId = t => t.userId;