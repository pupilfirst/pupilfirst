type t = {
  label: string,
  grade: int,
};

let decode = json =>
  Json.Decode.{
    label: json |> field("label", string),
    grade: json |> field("grade", string) |> int_of_string,
  };

let grade = t => t.grade;

let label = t => t.label;

let labelFor = (gradeLabels, grade) =>
  gradeLabels |> List.find(gradeLabel => gradeLabel.grade == grade) |> label;

let maxGrade = gradeLabels =>
  gradeLabels
  |> List.sort((x, y) => x.grade - y.grade)
  |> List.rev
  |> List.hd
  |> grade;