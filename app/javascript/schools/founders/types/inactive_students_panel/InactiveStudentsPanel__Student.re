type t = {
  id: string,
  userId: string,
  teamId: string,
  email: string,
  tags: list(string),
};

let id = t => t.id;

let teamId = t => t.teamId;

let userId = t => t.userId;

let email = t => t.email;

let tags = t => t.tags;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    teamId: json |> field("teamId", string),
    userId: json |> field("userId", string),
    email: json |> field("email", string),
    tags: json |> field("tags", list(string)),
  };

