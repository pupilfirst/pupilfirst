type t = {
  id: string,
  name: string,
  avatarUrl: option(string),
  teamId: string,
  email: string,
  tags: list(string),
  exited: bool,
  excludedFromLeaderboard: bool,
  title: string,
  affiliation: option(string),
};

let name = t => t.name;

let avatarUrl = t => t.avatarUrl;

let id = t => t.id;

let teamId = t => t.teamId;

let title = t => t.title;

let affiliation = t => t.affiliation;

let email = t => t.email;

let tags = t => t.tags;

let exited = t => t.exited;

let excludedFromLeaderboard = t => t.excludedFromLeaderboard;

let updateInfo =
    (~exited, ~excludedFromLeaderboard, ~title, ~affiliation, ~student) => {
  ...student,
  exited,
  excludedFromLeaderboard,
  title,
  affiliation,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    teamId: json |> field("teamId", string),
    email: json |> field("email", string),
    tags: json |> field("tags", list(string)),
    exited: json |> field("exited", bool),
    excludedFromLeaderboard: json |> field("excludedFromLeaderboard", bool),
    name: json |> field("name", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    title: json |> field("title", string),
    affiliation: json |> optional(field("affiliation", string)),
  };

let encode = (name, teamName, t) =>
  Json.Encode.(
    object_([
      ("id", t.id |> string),
      ("team_id", t.teamId |> string),
      ("name", name |> string),
      ("team_name", teamName |> string),
      ("email", t.email |> string),
      ("exited", t.exited |> bool),
      ("excluded_from_leaderboard", t.excludedFromLeaderboard |> bool),
      ("title", t.title |> string),
      ("affiliation", t.affiliation |> OptionUtils.toString |> string),
    ])
  );
