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
       DateFns.differenceInSeconds(y.createdAt, x.createdAt) |> int_of_float
     );

let failed = t => {
  switch (t.passedAt) {
  | Some(_passedAt) => false
  | None => true
  };
};

let createdAtPretty = t => t.createdAt |> DateFns.format("MMMM D, YYYY");

let makeFromJs = submissions => {
  submissions
  |> Js.Array.map(submission =>
       switch (submission) {
       | Some(submission) => [
           make(
             ~id=submission##id,
             ~title=submission##title,
             ~createdAt=submission##createdAt |> DateFns.parseString,
             ~passedAt=
               submission##passedAt |> OptionUtils.map(DateFns.parseString),
             ~levelId=submission##levelId,
           ),
         ]
       | None => []
       }
     );
};
