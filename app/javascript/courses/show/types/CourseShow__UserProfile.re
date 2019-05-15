type t = {
  userId: string,
  name: string,
  avatarUrl: option(string),
};

let decode = json =>
  Json.Decode.{
    userId: json |> field("userId", string),
    name: json |> field("name", string),
    avatarUrl:
      json |> field("avatarUrl", nullable(string)) |> Js.Null.toOption,
  };