type t = {
  id: option(int),
  name: string,
  levelNumber: int,
  unlockOn: option(string),
};

let id = t => t.id;

let name = t => t.name;

let levelNumber = t => t.levelNumber;

let unlockOn = t => t.unlockOn;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", nullable(int)) |> Js.Null.toOption,
    name: json |> field("name", string),
    levelNumber: json |> field("levelNumber", int),
    unlockOn:
      json |> field("unlockOn", nullable(string)) |> Js.Null.toOption,
  };

let selectLevel = (levels, level_name) =>
  levels |> List.find(q => q.name == level_name);

let empty = levelNumber => {id: None, name: "", levelNumber, unlockOn: None};