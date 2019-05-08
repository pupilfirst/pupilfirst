type t = {
  id: int,
  name: string,
  coachIds: list(int),
  levelNumber: int,
};

let id = t => t.id;

let name = t => t.name;

let coachIds = t => t.coachIds;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    coachIds: json |> field("coachIds", list(int)),
    levelNumber: json |> field("levelNumber", int),
  };

let levelNumber = t => t.levelNumber;