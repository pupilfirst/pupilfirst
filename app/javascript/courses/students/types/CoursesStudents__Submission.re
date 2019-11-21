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
  |> Js.Array.map(s =>
       make(
         ~id=s##id,
         ~title=s##title,
         ~createdAt=s##createdAt |> DateFns.parseString,
         ~passedAt=s##passedAt |> OptionUtils.map(DateFns.parseString),
         ~levelId=s##levelId,
       )
     );
};
