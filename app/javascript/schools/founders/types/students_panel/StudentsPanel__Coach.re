type t = {
  id: int,
  userId: int,
};

let id = t => t.id;

let userId = t => t.userId;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    userId: json |> field("userId", int),
  };