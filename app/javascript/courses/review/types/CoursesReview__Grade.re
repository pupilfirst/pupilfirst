type t = {
  evaluationCriterionId: string,
  value: int,
};

let make = (~evaluationCriterionId, ~value) => {
  evaluationCriterionId,
  value,
};

let sortByCriterion = (criteria, grades) => {
  let gradeEcIds =
    grades |> Array.map(grade => grade.evaluationCriterionId) |> Array.to_list;
  let sortedCriteria =
    criteria
    |> Js.Array.filter(ec =>
         gradeEcIds |> List.mem(EvaluationCriterion.id(ec))
       )
    |> EvaluationCriterion.sort;

  sortedCriteria
  |> Array.map(criterion =>
       grades
       |> Array.to_list
       |> List.find(grade =>
            grade.evaluationCriterionId == EvaluationCriterion.id(criterion)
          )
     );
};

let evaluationCriterionId = t => t.evaluationCriterionId;
let value = t => t.value;
let asJsType = t => {
  "evaluationCriterionId": t.evaluationCriterionId,
  "grade": t.value,
};
