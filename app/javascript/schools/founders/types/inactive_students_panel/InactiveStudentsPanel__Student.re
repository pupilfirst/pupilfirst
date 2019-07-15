type t = {
  id: string,
  name: string,
  avatarUrl: string,
  teamId: string,
  email: string,
  tags: list(string),
};

let id = t => t.id;

let teamId = t => t.teamId;

let name = t => t.name;

let avatarUrl = t => t.avatarUrl;

let email = t => t.email;

let tags = t => t.tags;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    teamId: json |> field("teamId", string),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
    email: json |> field("email", string),
    tags: json |> field("tags", list(string)),
  };
