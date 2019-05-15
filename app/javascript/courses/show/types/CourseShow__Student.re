type t = {
  id: string,
  userId: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    userId: json |> field("userId", string),
  };