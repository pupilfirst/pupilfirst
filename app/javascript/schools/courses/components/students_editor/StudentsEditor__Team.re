type t = {
  id: string,
  name: string,
  coachIds: list(string),
  levelNumber: int,
  accessEndsAt: option(Js.Date.t),
};

let id = t => t.id;

let name = t => t.name;

let coachIds = t => t.coachIds;

let accessEndsAt = t => t.accessEndsAt;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    coachIds: json |> field("coachIds", list(string)),
    levelNumber: json |> field("levelNumber", int),
    accessEndsAt:
      json
      |> field("accessEndsAt", nullable(string))
      |> Js.Null.toOption
      |> OptionUtils.map(DateFns.parseString),
  };

let levelNumber = t => t.levelNumber;
