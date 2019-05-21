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
let levelId = t => t.levelId;
let milestone = t => t.milestone;