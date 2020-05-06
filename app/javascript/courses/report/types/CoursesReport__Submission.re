type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  status: [ | `Pending | `Failed | `Passed],
  levelId: string,
  targetId: string,
};

let make = (~id, ~title, ~createdAt, ~levelId, ~status, ~targetId) => {
  id,
  title,
  createdAt,
  status,
  levelId,
  targetId,
};

let id = t => t.id;

let levelId = t => t.levelId;

let title = t => t.title;

let status = t => t.status;

let targetId = t => t.targetId;

let createdAtPretty = t => t.createdAt |> DateFns.format("MMMM D, YYYY");

let makeFromJs = submissions => {
  submissions
  |> Js.Array.map(submission =>
       switch (submission) {
       | Some(submission) =>
         let createdAt =
           submission##createdAt |> Json.Decode.string |> DateFns.parseString;
         let status =
           switch (submission##passedAt) {
           | Some(_passedAt) => `Passed
           | None =>
             switch (submission##evaluatorId) {
             | Some(_id) => `Failed
             | None => `Pending
             }
           };
         [
           make(
             ~id=submission##id,
             ~title=submission##title,
             ~createdAt,
             ~levelId=submission##levelId,
             ~targetId=submission##targetId,
             ~status,
           ),
         ];
       | None => []
       }
     );
};
