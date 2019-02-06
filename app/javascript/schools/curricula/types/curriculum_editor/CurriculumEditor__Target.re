type t = {
  id: int,
  title: string,
  targetGroupId: int,
};

let id = t => t.id;

let title = t => t.title;

let targetGroupId = t => t.targetGroupId;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    targetGroupId: json |> field("targetGroupId", int),
  };