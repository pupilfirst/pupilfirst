type t = {
  id: string,
  targetId: string,
  contentBlockIds: list(int),
};

let id = t => t.id;

let targetId = t => t.targetId;

let contentBlockIds = t => t.contentBlockIds;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    targetId: json |> field("targetId", string),
    contentBlockIds: json |> field("contentBlocks", list(int)),
  };
