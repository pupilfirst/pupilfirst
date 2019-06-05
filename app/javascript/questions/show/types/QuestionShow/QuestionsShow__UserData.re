type t = {
  userId: string,
  name: string,
  avatarUrl: string,
  title: string,
};

let decode = json =>
  Json.Decode.{
    userId: json |> field("userId", string),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
    title: json |> field("title", string),
  };

let name = t => t.name;

let avatarUrl = t => t.avatarUrl;

let title = t => t.title;

let user = (userId, users) =>
  users |> List.find(user => user.userId == userId);

let userName = (userId, users) =>
  users |> List.find(user => user.userId == userId) |> name;

let userAvatarUrl = (userId, users) =>
  users |> List.find(user => user.userId == userId) |> avatarUrl;