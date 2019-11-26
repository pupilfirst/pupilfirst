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

let makeFromJs = submissions => {
  submissions
  |> Js.Array.map(submission =>
       switch (submission) {
       | Some(submission) => [
           make(
             ~id=submission##id,
             ~title=submission##title,
             ~createdAt=submission##createdAt |> DateFns.parseString,
             ~passedAt=submission##passedAt |> OptionUtils.map(DateFns.parseString),
             ~levelId=submission##levelId,
           ),
         ]
       | None => []
       }
     );
};
