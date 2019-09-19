type t = {
  grade: int,
  label: string,
};

let decode = json =>
  Json.Decode.{
    label: json |> field("label", string),
    grade: json |> field("grade", int),
  };

let grade = t => t.grade;
let label = t => t.label;

let maxGrade = gradeLabels => {
  let a = gradeLabels |> ArrayUtils.copyAndSort((x, y) => x.grade - y.grade);
  (a |> Array.length) - 1 |> Array.get(a) |> grade;
};
