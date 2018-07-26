type t = {
  name: string,
  id: int,
  levelNumber: int,
  levelName: string,
  logoUrl: string,
};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    levelNumber: json |> field("levelNumber", int),
    levelName: json |> field("levelName", string),
    logoUrl: json |> field("logoUrl", string),
  };

let id = t => t.id;

let name = t => t.name;

let levelNumber = t => t.levelNumber;

let levelName = t => t.levelName;

let logoUrl = t => t.logoUrl;