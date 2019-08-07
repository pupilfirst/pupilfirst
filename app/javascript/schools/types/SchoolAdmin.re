type t = {
  id: string,
  name: string,
  avatarUrl: string,
  email: string,
};

let name = t => t.name;

let avatarUrl = t => t.avatarUrl;

let id = t => t.id;

let email = t => t.email;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    email: json |> field("email", string),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
  };
