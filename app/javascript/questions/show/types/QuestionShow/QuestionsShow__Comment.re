type t = {
  id: int,
  value: string,
  userId: int,
  commentableId: int,
  commentableType: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    value: json |> field("value", string),
    userId: json |> field("user_id", int),
    commentableId: json |> field("commentableId", int),
    commentableType: json |> field("commentableType", string),
  };