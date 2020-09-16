type t = {
  id: string,
  title: string,
  lastActivityAt: option(string),
  liveRepliesCount: int,
  likesCount: int,
  categoryId: option(string),
  creatorName: option(string),
  time: string,
};

let id = t => t.id;

let title = t => t.title;

let lastActivityAt = t => t.lastActivityAt;

let liveRepliesCount = t => t.liveRepliesCount;

let likesCount = t => t.likesCount;

let categoryId = t => t.categoryId;

let creatorName = t => t.creatorName;

let time = t => t.time;

let decode = json => {
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
    lastActivityAt: json |> optional(field("lastActivityAt", string)),
    liveRepliesCount: json |> field("liveRepliesCount", int),
    likesCount: json |> field("likesCount", int),
    categoryId: json |> optional(field("categoryId", string)),
    creatorName: json |> optional(field("creatorName", string)),
    time: json |> field("time", string),
  };
};
