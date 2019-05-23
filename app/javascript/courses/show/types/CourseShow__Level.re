type t = {
  id: string,
  name: string,
  number: int,
  unlockOn: option(string),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
    unlockOn:
      json |> field("unlockOn", nullable(string)) |> Js.Null.toOption,
  };

let id = t => t.id;
let name = t => t.name;
let number = t => t.number;

let isLocked = t =>
  switch (t.unlockOn) {
  | Some(date) => date |> DateFns.parseString |> DateFns.isFuture
  | None => false
  };