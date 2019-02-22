type t = {
  id: int,
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
    id: json |> field("id", int),
    name: json |> field("name", string),
    levelNumber: json |> field("levelNumber", int),
    unlockOn:
      json |> field("unlockOn", nullable(string)) |> Js.Null.toOption,
  };

let selectLevel = (levels, level_name) =>
  levels |> List.find(q => q.name == level_name);

let create = (id, name, levelNumber, unlockOn) => {
  id,
  name,
  levelNumber,
  unlockOn,
};

let updateList = (levels, level) => {
  let oldLevels = levels |> List.filter(l => l.id !== level.id);
  oldLevels |> List.rev |> List.append([level]) |> List.rev;
};

let sort = levels =>
  levels |> List.sort((x, y) => x.levelNumber - y.levelNumber);