type t = {
  evaluationCriterionId: string,
  value: int,
};

let make = (~evaluationCriterionId, ~value) => {
  evaluationCriterionId,
  value,
};

let evaluationCriterionId = t => t.evaluationCriterionId;
let value = t => t.value;
let asJsType = t => {
  "evaluationCriterionId": t.evaluationCriterionId,
  "grade": t.value,
};
