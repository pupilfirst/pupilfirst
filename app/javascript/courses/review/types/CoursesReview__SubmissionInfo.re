type status = {
  failed: bool,
  feedbackSent: bool,
};

type t = {
  id: string,
  targetId: string,
  title: string,
  createdAt: string,
  levelId: string,
  userNames: string,
  status: option(status),
};
let id = t => t.id;
let title = t => t.title;
let createdAt = t => t.createdAt;
let levelId = t => t.levelId;
let userNames = t => t.userNames;
let targetId = t => t.targetId;
let status = t => t.status;
let failed = status => status.failed;
let feedbackSent = status => status.feedbackSent;
let createdAtDate = t => t |> createdAt |> DateFns.parseString;

let createdAtPretty = t =>
  t |> createdAtDate |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t |> createdAtDate |> DateFns.distanceInWordsToNow(~addSuffix=true);

let sort = submissions =>
  submissions
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns.differenceInSeconds(
         y.createdAt |> DateFns.parseString,
         x.createdAt |> DateFns.parseString,
       )
       |> int_of_float
     );

let statusDecode = json =>
  Json.Decode.{
    failed: json |> field("failed", bool),
    feedbackSent: json |> field("feedbackSent", bool),
  };

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    targetId: json |> field("targetId", string),
    title: json |> field("title", string),
    levelId: json |> field("levelId", string),
    createdAt: json |> field("createdAt", string),
    userNames: json |> field("userNames", string),
    status:
      json |> field("status", nullable(statusDecode)) |> Js.Null.toOption,
  };

let make = (~id, ~title, ~createdAt, ~levelId, ~userNames, ~targetId, ~status) => {
  id,
  title,
  createdAt,
  levelId,
  userNames,
  targetId,
  status,
};

let makeStatus = (~failed, ~feedbackSent) => {failed, feedbackSent};

let decodeJS = details =>
  details
  |> Js.Array.map(s =>
       switch (s) {
       | Some(submission) =>
         let status =
           makeStatus(
             ~failed=submission##failed,
             ~feedbackSent=submission##feedbackSent,
           );
         [
           make(
             ~id=submission##id,
             ~title=submission##title,
             ~createdAt=submission##createdAt,
             ~levelId=submission##levelId,
             ~userNames=submission##userNames,
             ~targetId=submission##targetId,
             ~status=Some(status),
           ),
         ];
       | None => []
       }
     );
