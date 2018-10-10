type t = {
  name: string,
  id: int,
  imageUrl: string,
};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    imageUrl: json |> field("imageUrl", string),
  };

let name = t => t.name;

let imageUrl = t => t.imageUrl;