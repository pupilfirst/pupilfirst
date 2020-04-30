type t = {
  id: string,
  author: option(User.t),
  note: string,
  createdAt: Js.Date.t,
};

let make = (~id, ~note, ~createdAt, ~author) => {
  id,
  note,
  createdAt,
  author,
};

let id = t => t.id;

let note = t => t.note;

let createdAt = t => t.createdAt;

let author = t => t.author;

let noteOn = t => t.createdAt->DateFns2.format("MMMM D, YYYY");

let sort = notes =>
  notes
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns.differenceInSeconds(y.createdAt, x.createdAt) |> int_of_float
     );

let makeFromJs = note => {
  make(
    ~id=note##id,
    ~note=note##note,
    ~createdAt=note##createdAt->Json.Decode.string->DateFns2.parse,
    ~author=note##author |> OptionUtils.map(User.makeFromJs),
  );
};
