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
  coachIds: array(string),
};

let id = t => t.id;
let title = t => t.title;
let levelId = t => t.levelId;
let userNames = t => t.userNames;
let status = t => t.status;
let coachIds = t => t.coachIds;

let failed = status => status.failed;
let feedbackSent = status => status.feedbackSent;

let createdAtPretty = t => t.createdAt |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t.createdAt |> DateFns.distanceInWordsToNow(~addSuffix=true);

let sortDown = submissions =>
  submissions
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns.differenceInSeconds(y.createdAt, x.createdAt) |> int_of_float
     );

let sortUp = submissions => submissions |> sortDown |> Js.Array.reverseInPlace;

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
    coachIds: json |> field("coachIds", array(string)),
  };

let make = (~id, ~title, ~createdAt, ~levelId, ~userNames, ~status, ~coachIds) => {
  id,
  title,
  createdAt,
  levelId,
  userNames,
  status,
  coachIds,
};

let makeStatus = (~failed, ~feedbackSent) => {failed, feedbackSent};

let decodeJs = details =>
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
             ~coachIds=submission##coachIds,
           ),
         ];
       | None => []
       }
     );

let replace = (e, l) => l |> Array.map(s => s.id == e.id ? e : s);
