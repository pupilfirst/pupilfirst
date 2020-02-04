type t = {
  id: string,
  index: int,
  createdAt: Js.Date.t,
};

let id = t => t.id;

let createdAt = t => t.createdAt;

let index = t => t.index;

let make = (id, index, createdAt) => {id, index, createdAt};

let makeFromJs = js => {
  js
  |> Array.mapi((index, c) =>
       make(
         c##id,
         index + 1,
         c##createdAt |> Json.Decode.string |> DateFns.parseString,
       )
     );
};

let versionAt = t => t.createdAt |> DateFns.format("Do MMMM YYYY");
