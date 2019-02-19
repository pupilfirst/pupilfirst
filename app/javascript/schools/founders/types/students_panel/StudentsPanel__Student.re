type t = {
  id: int,
  name: string,
  avatarUrl: string,
  teamId: int,
  email: string,
};

let name = t => t.name;

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let teamId = t => t.teamId;

let email = t => t.email;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    avatarUrl: json |> field("avatarUrl", string),
    teamId: json |> field("teamId", int),
    email: json |> field("email", string),
  };
