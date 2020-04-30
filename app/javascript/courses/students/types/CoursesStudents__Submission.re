type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  passedAt: option(Js.Date.t),
  levelId: string,
};

let make = (~id, ~title, ~createdAt, ~passedAt, ~levelId) => {
  id,
  title,
  createdAt,
  passedAt,
  levelId,
};

let id = t => t.id;

let levelId = t => t.levelId;

let title = t => t.title;

let sort = submissions =>
  submissions
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns2.differenceInSeconds(y.createdAt, x.createdAt)
     );

let failed = t => {
  switch (t.passedAt) {
  | Some(_passedAt) => false
  | None => true
  };
};

let createdAtPretty = t => t.createdAt->DateFns2.format("MMMM D, YYYY");

let makeFromJs = submissions => {
  submissions
  |> Js.Array.map(submission =>
       switch (submission) {
       | Some(submission) =>
         let createdAt =
           submission##createdAt |> Json.Decode.string |> DateFns2.parse;

         let passedAt =
           submission##passedAt
           ->Belt.Option.map(passedAt =>
               passedAt |> Json.Decode.string |> DateFns2.parse
             );

         [
           make(
             ~id=submission##id,
             ~title=submission##title,
             ~createdAt,
             ~passedAt,
             ~levelId=submission##levelId,
           ),
         ];
       | None => []
       }
     );
};
