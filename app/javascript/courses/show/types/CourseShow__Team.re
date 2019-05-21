type t = {
  name: string,
  levelId: string,
  accessEndsAt: option(string),
};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    levelId: json |> field("levelId", string),
    accessEndsAt:
      json |> field("accessEndsAt", nullable(string)) |> Js.Null.toOption,
  };

let levelId = t => t.levelId;
let accessEndsAt = t => t.accessEndsAt;