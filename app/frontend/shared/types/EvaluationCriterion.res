type t = {
  name: string,
  id: string,
  maxGrade: int,
  gradesAndLabels: array<GradeLabel.t>,
}

module Decode = {
  open Json.Decode

  let t = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    gradesAndLabels: field.required("gradeLabels", array(GradeLabel.Decode.gradeLabel)),
    maxGrade: field.required("maxGrade", int),
  })
}

let id = t => t.id

let maxGrade = t => t.maxGrade

let sort = evaluationCriteria =>
  ArrayUtils.copyAndSort(
    (x, y) => Js.String2.localeCompare(x.name, y.name)->int_of_float,
    evaluationCriteria,
  )

let name = t => t.name

let gradesAndLabels = t => t.gradesAndLabels

let makeFromJs = evaluationCriterion => {
  name: evaluationCriterion["name"],
  id: evaluationCriterion["id"],
  maxGrade: evaluationCriterion["maxGrade"],
  gradesAndLabels: Array.map(evaluationCriterion["gradeLabels"], gL => GradeLabel.makeFromJs(gL)),
}

let make = (~id, ~name, ~maxGrade, ~gradesAndLabels) => {
  id,
  name,
  maxGrade,
  gradesAndLabels,
}
