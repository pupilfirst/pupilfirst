type t = {
  id: string,
  description: string,
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    description: json |> field("description", string),
    createdAt: json |> field("createdAt", string),
  };