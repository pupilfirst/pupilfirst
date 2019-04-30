type t = {
  id: string,
  title: string,
  description: string,
  userId: string,
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
    description: json |> field("description", string),
    userId: json |> field("userId", string),
    createdAt: json |> field("createdAt", string),
  };

let id = t => t.id;

let title = t => t.title;

let description = t => t.description;

let userId = t => t.userId;

let createdAt = t => t.createdAt;