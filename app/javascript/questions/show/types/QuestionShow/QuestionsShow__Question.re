type t = {
  id: string,
  title: string,
  userId: string,
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
    userId: json |> field("userId", string),
    createdAt: json |> field("createdAt", string),
  };

let id = t => t.id;

let title = t => t.title;

let userId = t => t.userId;

let createdAt = t => t.createdAt;