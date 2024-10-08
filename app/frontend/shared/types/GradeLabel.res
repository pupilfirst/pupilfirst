exception GradeLabelsEmpty

type t = {
  label: string,
  grade: int,
}

@scope("JSON") @val
external parse: string => t = "parse"

let grade = t => t.grade
let label = t => t.label

let labelFor = (gradeLabels, grade) =>
  switch List.find(gradeLabels, gradeLabel => gradeLabel.grade == grade) {
  | Some(t) => t->label
  | None => {
      Debug.error("GradeLabel", "Could not find label for grade " ++ string_of_int(grade))
      "Missing"
    }
  }

let create = (grade, label) => {grade, label}

let empty = grade => {grade, label: ""}

let update = (label, t) => {...t, label}

let asJsObject = t => {"grade": t.grade, "label": t.label}

let valid = t => Js.String.length(Js.String.trim(t.label)) >= 1

let makeFromJs = rawGradeLabel => {
  label: rawGradeLabel["label"],
  grade: rawGradeLabel["grade"],
}

let maxGrade = gradeLabels => {
  let rec aux = (max, remains) =>
    switch remains {
    | list{} => max
    | list{head, ...tail} => aux(Js.Math.max_int(head.grade, max), tail)
    }

  switch aux(0, gradeLabels) {
  | 0 =>
    Rollbar.error("GradeLabel.maxGrade received an empty list of gradeLabels")
    raise(GradeLabelsEmpty)
  | validGrade => validGrade
  }
}
