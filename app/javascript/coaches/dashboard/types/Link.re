type t = {
  title: string,
  url: string,
};

let decode = json =>
  Json.Decode.{
    title: json |> field("title", string),
    url: json |> field("url", string),
  };