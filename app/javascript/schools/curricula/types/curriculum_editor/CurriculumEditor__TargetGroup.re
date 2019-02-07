type t = {
  id: int,
  name: string,
  levelId: int,
};

let levelId = t => t.levelId;

let name = t => t.name;

let id = t => t.id;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    levelId: json |> field("levelId", int),
  };