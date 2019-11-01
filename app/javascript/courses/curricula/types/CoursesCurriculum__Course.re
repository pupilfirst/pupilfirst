type t = {
  id: string,
  gradeLabels: list(GradeLabel.t),
  endsAt: option(string),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    gradeLabels: json |> field("gradeLabels", list(GradeLabel.decode)),
    endsAt: json |> field("endsAt", nullable(string)) |> Js.Null.toOption,
  };

let endsAt = t => t.endsAt;
let id = t => t.id;
let gradeLabels = t => t.gradeLabels;

let hasEnded = t =>
  switch (t.endsAt) {
  | Some(date) => date |> DateFns.parseString |> DateFns.isPast
  | None => false
  };
