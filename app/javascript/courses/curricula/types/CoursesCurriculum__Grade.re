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

let sortByCriterion = (criteria, grades) => {
  let gradeEcIds = grades |> List.map(grade => grade.evaluationCriterionId);
  let sortedCriteria =
    criteria
    |> List.filter(ec => gradeEcIds |> List.mem(EvaluationCriterion.id(ec)))
    |> Array.of_list
    |> EvaluationCriterion.sort;

  sortedCriteria
  |> Array.map(criterion =>
       grades
       |> List.find(grade =>
            grade.evaluationCriterionId == EvaluationCriterion.id(criterion)
          )
     )
  |> Array.to_list;
};

let grade = t => t.grade;
let submissionId = t => t.submissionId;
let evaluationCriterionId = t => t.evaluationCriterionId;
