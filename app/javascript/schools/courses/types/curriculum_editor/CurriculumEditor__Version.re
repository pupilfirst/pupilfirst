type t = {
  id: string,
  index: int,
  createdAt: Js.Date.t,
  updatedAt: Js.Date.t,
};

let id = t => t.id;

let createdAt = t => t.createdAt;

let updatedAt = t => t.updatedAt;

let index = t => t.index;

let make = (id, index, createdAt, updatedAt) => {
  id,
  index,
  createdAt,
  updatedAt,
};

let makeFromJs = js => {
  let length = js |> Array.length;
  js
  |> Array.mapi((index, c) =>
       make(
         c##id,
         length - index,
         c##createdAt |> Json.Decode.string |> DateFns.parseString,
         c##updatedAt |> Json.Decode.string |> DateFns.parseString,
       )
     );
};

let versionAt = t => t.createdAt |> DateFns.format("MMM D, YYYY HH:MM");

let isLatestTargetVersion = (versions, t) => {
  let length = versions |> Array.length;
  t.index == length;
};
