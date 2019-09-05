type t = {
  id: string,
  targetId: string,
  title: string,
  createdAt: string,
  levelId: string,
  userIds: list(string),
};

let id = t => t.id;
let title = t => t.title;
let createdAt = t => t.createdAt;
let levelId = t => t.levelId;

let userIds = t => t.userIds;

let createdAtDate = t => t |> createdAt |> DateFns.parseString;

let createdAtPretty = t =>
  t |> createdAtDate |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t |> createdAtDate |> DateFns.distanceInWordsToNow(~addSuffix=true);

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    targetId: json |> field("targetId", string),
    title: json |> field("title", string),
    levelId: json |> field("levelId", string),
    userIds: json |> field("userIds", list(string)),
    createdAt: json |> field("createdAt", string),
  };
