type t = {
  id: int,
  userId: int,
  teamId: int,
  email: string,
  tags: list(string),
  exited: bool,
  excludedFromLeaderboard: bool,
};

let id = t => t.id;

let teamId = t => t.teamId;

let userId = t => t.userId;

let email = t => t.email;

let tags = t => t.tags;

let exited = t => t.exited;

let excludedFromLeaderboard = t => t.excludedFromLeaderboard;

let updateInfo = (name, teamName, exited, excludedFromLeaderboard, t) => {
  ...t,
  exited,
  excludedFromLeaderboard,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    teamId: json |> field("teamId", int),
    userId: json |> field("userId", int),
    email: json |> field("email", string),
    tags: json |> field("tags", list(string)),
    exited: json |> field("exited", bool),
    excludedFromLeaderboard: json |> field("excludedFromLeaderboard", bool),
  };

let encode = t =>
  Json.Encode.(
    object_([
      ("id", t.id |> int),
      ("team_id", t.teamId |> int),
      ("email", t.email |> string),
      ("exited", t.exited |> bool),
      ("excluded_from_leaderboard", t.excludedFromLeaderboard |> bool),
    ])
  );