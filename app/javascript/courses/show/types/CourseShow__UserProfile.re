type t = {
  userId: string,
  name: string,
  avatarUrl: string,
};

let decode = json =>
  Json.Decode.{
    userId: json |> field("userId", string),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
  };

let userId = t => t.userId;
let avatarUrl = t => t.avatarUrl;