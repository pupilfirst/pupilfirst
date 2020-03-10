type t = {
  id: string,
  name: string,
  email: string,
  avatarUrl: option(string),
  title: string,
  teams: array(CoachesCourseIndex__Team.t),
};

let name = t => t.name;

let email = t => t.email;

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let title = t => t.title;

let teams = t => t.teams;

let removeTeam = (t, teamId) => {
  let updatedTeams = t.teams |> Js.Array.filter(team => teamId != CoachesCourseIndex__Team.id(team));
  {...t, teams: updatedTeams};
};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    email: json |> field("email", string),
    id: json |> field("id", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    title: json |> field("title", string),
    teams: json |> field("teams", array(CoachesCourseIndex__Team.decode)),
  };
