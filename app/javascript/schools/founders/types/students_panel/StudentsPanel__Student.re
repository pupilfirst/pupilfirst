type t = {
  id: int,
  name: string,
  avatarUrl: string,
  teamId: int,
  email: string,
  tags: list(string),
  exited: bool,
  excludedFromLeaderboard: bool,
};

let name = t => t.name;
let avatarUrl = t => t.avatarUrl;
let id = t => t.id;

let teamId = t => t.teamId;

let email = t => t.email;

let tags = t => t.tags;

let exited = t => t.exited;

let excludedFromLeaderboard = t => t.excludedFromLeaderboard;

let updateInfo = (exited, excludedFromLeaderboard, t) => {
  ...t,
  exited,
  excludedFromLeaderboard,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    teamId: json |> field("teamId", int),
    email: json |> field("email", string),
    tags: json |> field("tags", list(string)),
    exited: json |> field("exited", bool),
    excludedFromLeaderboard: json |> field("excludedFromLeaderboard", bool),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
  };

let encode = (name, teamName, t) =>
  Json.Encode.(
    object_([
      ("id", t.id |> int),
      ("team_id", t.teamId |> int),
      ("name", name |> string),
      ("team_name", teamName |> string),
      ("email", t.email |> string),
      ("exited", t.exited |> bool),
      ("excluded_from_leaderboard", t.excludedFromLeaderboard |> bool),
    ])
  );
