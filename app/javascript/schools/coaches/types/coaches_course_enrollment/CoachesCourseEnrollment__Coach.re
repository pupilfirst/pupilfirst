type t = {
  id: int,
  name: string,
  imageUrl: string,
  email: string,
  title: string,
  teams: option(list(CoachesCourseEnrollment__Team.t)),
};

let name = t => t.name;

let id = t => t.id;

let email = t => t.email;

let imageUrl = t => t.imageUrl;

let title = t => t.title;

let teams = t => t.teams;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    imageUrl: json |> field("imageUrl", string),
    email: json |> field("email", string),
    title: json |> field("title", string),
    teams:
      json
      |> field(
           "teams",
           nullable(list(CoachesCourseEnrollment__Team.decode)),
         )
      |> Js.Null.toOption,
  };

let updateList = (coaches, coach) => {
  let oldList = coaches |> List.filter(t => t.id !== coach.id);
  oldList
  |> List.rev
  |> List.append([coach])
  |> List.rev
  |> List.sort((x, y) => x.id - y.id);
};