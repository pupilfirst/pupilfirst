type t = {
  id: string,
  author: option(CoursesStudents__Coach.t),
  note: string,
  createdAt: Js.Date.t,
};

let make = (~id, ~note, ~createdAt, ~author) => {
  id,
  note,
  createdAt,
  author,
};

let makeFromJs = note => {
  make(
    ~id=note##id,
    ~note=note##note,
    ~createdAt=note##createdAt |> DateFns.parseString,
    ~author=
      note##author |> OptionUtils.map(CoursesStudents__Coach.makeFromJs),
  );
};
