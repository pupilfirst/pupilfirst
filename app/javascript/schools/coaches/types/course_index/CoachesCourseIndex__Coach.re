type t = {
  id: int,
  name: string,
  imageUrl: string,
  title: string,
  teams: option(list(CoachesCourseIndex__Team.t)),
};

let name = t => t.name;

let id = t => t.id;

let imageUrl = t => t.imageUrl;

let title = t => t.title;

let teams = t => t.teams;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    imageUrl: json |> field("imageUrl", string),
    title: json |> field("title", string),
    teams:
      json
      |> field("teams", nullable(list(CoachesCourseIndex__Team.decode)))
      |> Js.Null.toOption,
  };
