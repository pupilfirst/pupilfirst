type t = {
  userId: string,
  name: string,
  avatarUrl: string,
  title: option(string),
};

let userId = t => t.userId;
let name = t => t.name;
let avatarUrl = t => t.avatarUrl;
let title = t => t.title;

let decode = json =>
  Json.Decode.{
    userId: json |> field("userId", string),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
    title: json |> field("title", nullable(string)) |> Js.Null.toOption,
  };
