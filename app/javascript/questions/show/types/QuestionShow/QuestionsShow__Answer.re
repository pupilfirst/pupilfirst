type t = {
  id: int,
  description: string,
  userId: int,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    description: json |> field("description", string),
    userId: json |> field("userId", int),
  };

let id = t => t.id;

let description = t => t.description;

let userId = t => t.userId;