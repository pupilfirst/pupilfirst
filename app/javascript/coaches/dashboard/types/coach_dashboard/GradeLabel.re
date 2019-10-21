exception GradeLabelsEmpty;

type t = {
  label: string,
  grade: int,
};

let decode = json =>
  Json.Decode.{
    label: json |> field("label", string),
    grade: json |> field("grade", int),
  };

let grade = t => t.grade;
let label = t => t.label;

let labelFor = (gradeLabels, grade) =>
  gradeLabels |> List.find(gradeLabel => gradeLabel.grade == grade) |> label;

let maxGrade = gradeLabels => {
  let rec aux = (max, remains) =>
    switch (remains) {
    | [] => max
    | [head, ...tail] => aux(Js.Math.max_int(head.grade, max), tail)
    };

  switch (aux(0, gradeLabels)) {
  | 0 =>
    Rollbar.error(
      "GradeLabel.maxGrade received an empty list of gradeLabels",
    );
    raise(GradeLabelsEmpty);
  | validGrade => validGrade
  };
};
