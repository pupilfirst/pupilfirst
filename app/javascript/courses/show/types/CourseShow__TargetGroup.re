type t = {
  id: string,
  levelId: string,
  name: string,
  description: string,
  sortIndex: int,
  milestone: bool,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    levelId: json |> field("levelId", string),
    name: json |> field("name", string),
    description: json |> field("description", string),
    sortIndex: json |> field("sortIndex", int),
    milestone: json |> field("milestone", bool),
  };

let id = t => t.id;
let name = t => t.name;
let levelId = t => t.levelId;
let sortIndex = t => t.sortIndex;
let milestone = t => t.milestone;