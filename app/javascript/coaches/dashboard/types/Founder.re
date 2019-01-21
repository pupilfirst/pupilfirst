type t = {
  id: int,
  name: string,
  avatarUrl: string,
  teamId: int,
};

let name = t => t.name;

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let teamId = t => t.teamId;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    avatarUrl: json |> field("avatarUrl", string),
    teamId: json |> field("teamId", int),
  };

let founderNames = (founders: list(t)) => founders |> List.map(founder => founder.name) |> String.concat(", ");

let withIds = (ids, founders) => founders |> List.filter(founder => List.mem(founder.id, ids));

let inTeam = (team, founders) => founders |> List.filter(founder => founder |> teamId == (team |> Team.id));
