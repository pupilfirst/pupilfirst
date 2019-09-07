type t = {
  id: string,
  title: string,
  createdAt: string,
  levelId: string,
  userNames: string,
  failed: bool,
  feedbackSent: bool,
};

let id = t => t.id;
let title = t => t.title;
let createdAt = t => t.createdAt;
let levelId = t => t.levelId;

let userNames = t => t.userNames;

let failed = t => t.failed;

let feedbackSent = t => t.feedbackSent;

let createdAtDate = t => t |> createdAt |> DateFns.parseString;

let createdAtPretty = t =>
  t |> createdAtDate |> DateFns.format("MMMM D, YYYY");

let sort = submissions =>
  submissions
  |> List.sort((x, y) =>
       DateFns.differenceInSeconds(
         y.createdAt |> DateFns.parseString,
         x.createdAt |> DateFns.parseString,
       )
       |> int_of_float
     );
let make =
    (~id, ~title, ~createdAt, ~levelId, ~userNames, ~failed, ~feedbackSent) => {
  id,
  title,
  createdAt,
  levelId,
  userNames,
  failed,
  feedbackSent,
};
