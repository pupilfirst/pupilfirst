type t = {
  id: string,
  name: string,
  levelId: string,
};

let id = t => t.id;
let levelId = t => t.levelId;

let name = t => t.name;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    levelId: json |> field("levelId", string),
  };
