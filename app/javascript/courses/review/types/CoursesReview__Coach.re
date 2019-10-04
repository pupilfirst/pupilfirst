type t = {
  name: string,
  title: option(string),
  avatarUrl: string,
};
let name = t => t.name;
let title = t => t.title;
let avatarUrl = t => t.avatarUrl;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    title: json |> field("title", nullable(string)) |> Js.Null.toOption,
    avatarUrl: json |> field("avatarUrl", string),
  };
