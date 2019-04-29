type t = {
  id: int,
  description: string,
  userId: int,
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    description: json |> field("description", string),
    userId: json |> field("userId", int),
    createdAt: json |> field("createdAt", string),
  };

let id = t => t.id;

let createdAt = t => t.createdAt;

let description = t => t.description;

let userId = t => t.userId;