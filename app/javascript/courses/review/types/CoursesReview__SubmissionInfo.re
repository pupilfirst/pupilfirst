type status = {
  failed: bool,
  feedbackSent: bool,
};

type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  levelId: string,
  userNames: string,
  status: option(status),
};
let id = t => t.id;
let title = t => t.title;
let levelId = t => t.levelId;
let userNames = t => t.userNames;
let status = t => t.status;
let failed = status => status.failed;
let feedbackSent = status => status.feedbackSent;

let createdAtPretty = t => t.createdAt |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t.createdAt |> DateFns.distanceInWordsToNow(~addSuffix=true);

let sort = submissions =>
  submissions
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns.differenceInSeconds(y.createdAt, x.createdAt) |> int_of_float
     );

let statusDecode = json =>
  Json.Decode.{
    failed: json |> field("failed", bool),
    feedbackSent: json |> field("feedbackSent", bool),
  };

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
    levelId: json |> field("levelId", string),
    createdAt: json |> field("createdAt", string) |> DateFns.parseString,
    userNames: json |> field("userNames", string),
    status:
      json |> field("status", nullable(statusDecode)) |> Js.Null.toOption,
  };

let make = (~id, ~title, ~createdAt, ~levelId, ~userNames, ~status) => {
  id,
  title,
  createdAt,
  levelId,
  userNames,
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
             ~createdAt=submission##createdAt |> DateFns.parseString,
             ~levelId=submission##levelId,
             ~userNames=submission##userNames,
             ~status=Some(status),
           ),
         ];
       | None => []
       }
     );

let replace = (e, l) => l |> Array.map(s => s.id == e.id ? e : s);
