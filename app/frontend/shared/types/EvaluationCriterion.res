type t = {
  name: string,
  id: string,
  maxGrade: int,
  gradesAndLabels: array<GradeLabel.t>,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    gradesAndLabels: json |> field("gradeLabels", array(GradeLabel.decode)),
    maxGrade: json |> field("maxGrade", int),
  }
}

let id = t => t.id

let maxGrade = t => t.maxGrade

let sort = evaluationCriteria =>
  evaluationCriteria |> ArrayUtils.copyAndSort((x, y) =>
    Js.String2.localeCompare(x.name, y.name)->int_of_float
  )

let name = t => t.name

let gradesAndLabels = t => t.gradesAndLabels

let makeFromJs = evaluationCriterion => {
  name: evaluationCriterion["name"],
  id: evaluationCriterion["id"],
  maxGrade: evaluationCriterion["maxGrade"],
  gradesAndLabels: evaluationCriterion["gradeLabels"] |> Js.Array.map(gL =>
    gL |> GradeLabel.makeFromJs
  ),
}

let make = (~id, ~name, ~maxGrade, ~gradesAndLabels) => {
  id: id,
  name: name,
  maxGrade: maxGrade,
  gradesAndLabels: gradesAndLabels,
}
