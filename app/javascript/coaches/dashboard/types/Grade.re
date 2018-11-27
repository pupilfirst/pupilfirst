type t = {
  criterionId: int,
  grade: int,
};

let decode = json =>
  Json.Decode.{
    criterionId: json |> field("criterionId", int),
    grade: json |> field("grade", int),
  };

let grade = t => t.grade;