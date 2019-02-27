type t = {
  title: string,
  url: string,
  private: bool,
};

let title = t => t.title;

let url = t => t.url;

let private = t => t.private;

let decode = json =>
  Json.Decode.{
    title: json |> field("title", string),
    url: json |> field("url", string),
    private: json |> field("private", bool),
  };