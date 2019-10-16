type t = {
  id: string,
  name: string,
  teamId: string,
};

let id = t => t.id;
let name = t => t.name;

let teamId = t => t.teamId;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    teamId: json |> field("teamId", string),
  };
