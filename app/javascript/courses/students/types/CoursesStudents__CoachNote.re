type t = {
  author: option(CoursesStudents__Coach.t),
  note: string,
  createdAt: Js.Date.t,
};

let make = (~note, ~createdAt, ~author) => {note, createdAt, author};

let makeFromJs = note => {
  make(
    ~note=note##note,
    ~createdAt=note##createdAt |> DateFns.parseString,
    ~author=
      note##author |> OptionUtils.map(CoursesStudents__Coach.makeFromJs),
  );
};
