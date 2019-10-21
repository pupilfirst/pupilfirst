type t = {
  id: string,
  name: string,
  coachIds: list(string),
  levelNumber: int,
};

let id = t => t.id;

let name = t => t.name;

let coachIds = t => t.coachIds;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    coachIds: json |> field("coachIds", list(string)),
    levelNumber: json |> field("levelNumber", int),
  };

let levelNumber = t => t.levelNumber;
