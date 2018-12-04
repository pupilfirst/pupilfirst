type t = {
  criterionId: int,
  criterionName: string,
  grade: option(int),
};

let decode = json =>
  Json.Decode.{
    criterionId: json |> field("criterionId", int),
    criterionName: json |> field("criterionName", string),
    grade: json |> field("grade", nullable(int)) |> Js.Null.toOption,
  };

let grade = t => t.grade;

let pending = evaluation =>
  evaluation |> List.exists(grading => grading.grade == None);

let isFail = (passGrade, grading) =>
  switch (grading.grade) {
  | Some(grade) => grade < passGrade
  | None => false
  };

let anyFail = (passGrade, evaluation) =>
  evaluation |> List.exists(grading => grading |> isFail(passGrade));

let clearedEvaluation = evaluation =>
  evaluation
  |> List.map(grading =>
       {
         criterionId: grading.criterionId,
         criterionName: grading.criterionName,
         grade: None,
       }
     );

let criterionId = t => t.criterionId;

let criterionName = t => t.criterionName;

let updateGrade = (newGrade, t) => {
  criterionId: t.criterionId,
  criterionName: t.criterionName,
  grade: Some(newGrade),
};