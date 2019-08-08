type id = string;

type file = {
  path: string,
  createdAt: string,
};

type t = {
  id,
  username: string,
  createdAt: string,
  file: option(file),
};

let decodeFile = json =>
  Json.Decode.{
    path: json |> field("path", string),
    createdAt: json |> field("createdAt", string),
  };

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    username: json |> field("username", string),
    createdAt: json |> field("createdAt", string),
    file: json |> field("file", nullable(decodeFile)) |> Js.Null.toOption,
  };
