type t = {
  submissionId: string,
  evaluationCriterionId: string,
  grade: int,
};

let decode = json =>
  Json.Decode.{
    submissionId: json |> field("submissionId", string),
    evaluationCriterionId: json |> field("evaluationCriterionId", string),
    grade: json |> field("grade", int),
  };

let grade = t => t.grade;
let submissionId = t => t.submissionId;
let evaluationCriterionId = t => t.evaluationCriterionId;
