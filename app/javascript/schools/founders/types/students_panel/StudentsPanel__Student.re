type t = {
  id: int,
  name: string,
  avatarUrl: string,
  teamId: int,
  teamName: string,
  email: string,
  tags: list(string),
  exited: bool,
};

let name = t => t.name;

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let teamId = t => t.teamId;

let teamName = t => t.teamName;

let email = t => t.email;

let tags = t => t.tags;

let exited = t => t.exited;

let updateInfo = (name, teamName, exited, student) => {
  ...student,
  name,
  teamName,
  exited,
};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    avatarUrl: json |> field("avatarUrl", string),
    teamId: json |> field("teamId", int),
    teamName: json |> field("teamName", string),
    email: json |> field("email", string),
    tags: json |> field("tags", list(string)),
    exited: json |> field("exited", bool),
  };

let encode = t =>
  Json.Encode.(
    object_([
      ("id", t.id |> int),
      ("name", t.name |> string),
      ("avatar_url", t.avatarUrl |> string),
      ("team_id", t.teamId |> int),
      ("team_name", t.teamName |> string),
      ("email", t.email |> string),
      ("exited", t.exited |> bool),
    ])
  );