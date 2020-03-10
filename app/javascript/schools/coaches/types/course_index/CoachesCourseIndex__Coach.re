type t = {
  id: string,
  name: string,
  avatarUrl: option(string),
  title: string,
  teams: option(list(CoachesCourseIndex__Team.t)),
};

let name = t => t.name;

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let title = t => t.title;

let teams = t => t.teams;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    title: json |> field("title", string),
    teams:
      json
      |> field("teams", nullable(list(CoachesCourseIndex__Team.decode)))
      |> Js.Null.toOption,
  };
