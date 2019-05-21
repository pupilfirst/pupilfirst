type t = {
  id: string,
  name: string,
  maxGrade: int,
  passGrade: int,
  gradeLabels: list(GradeLabel.t),
  endsAt: option(string),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    maxGrade: json |> field("maxGrade", int),
    passGrade: json |> field("passGrade", int),
    gradeLabels: json |> field("gradeLabels", list(GradeLabel.decode)),
    endsAt: json |> field("endsAt", nullable(string)) |> Js.Null.toOption,
  };

let endsAt = t => t.endsAt;