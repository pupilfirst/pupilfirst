type t = {
  name: string,
  description: string,
  id: string,
  maxGrade: int,
  passGrade: int,
  gradesAndLabels: array(EvaluationCriterionEditor__GradesAndLabels.t),
};

let name = t => t.name;

let description = t => t.description;

let id = t => t.id;

let maxGrade = t => t.maxGrade;

let passGrade = t => t.passGrade;

let makeFromJs = evaluationCriterion => {
  name: evaluationCriterion##name,
  id: evaluationCriterion##id,
  description: evaluationCriterion##description,
  maxGrade: evaluationCriterion##maxGrade,
  passGrade: evaluationCriterion##passGrade,
  gradesAndLabels:
    evaluationCriterion##gradesAndLabels
    |> Js.Array.map(gL =>
         gL |> EvaluationCriterionEditor__GradesAndLabels.makeFromJs
       ),
};
