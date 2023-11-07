%%raw(`import "./CoursesCurriculum__GradeBar.css"`)

let str = React.string

open CoursesCurriculum__Types
let gradeDescription = (gradeLabels, grading) =>
  <div className="grade-bar__criterion-name">
    {grading |> Grading.criterionName |> str}
    {switch grading |> Grading.grade {
    | Some(grade) =>
      <span>
        {": " |> str}
        <span className="grade-bar__grade-label">
          {grade |> GradeLabel.labelFor(gradeLabels) |> str}
        </span>
      </span>
    | None => React.null
    }}
  </div>

let maxGrade = gradeLabels => gradeLabels |> GradeLabel.maxGrade |> string_of_int

let gradePillClasses = (gradeReceived, pillGrade, callBack) => {
  let defaultClasses = "grade-bar__grade-pill cursor-auto"
  let resultModifier = switch gradeReceived {
  | None => ""
  | Some(grade) if pillGrade > grade => ""
  | Some(_) => " grade-bar__grade-pill--completed"
  }
  let selectableModifier = switch callBack {
  | None => ""
  | Some(_callBack) => " grade-bar__grade-pill--selectable-pass cursor-pointer"
  }
  defaultClasses ++ (resultModifier ++ selectableModifier)
}

let gradeBarHeader = (grading, gradeLabels) =>
  <div className="grade-bar__header pb-1">
    {grading |> gradeDescription(gradeLabels)}
    {switch grading |> Grading.grade {
    | None => React.null
    | Some(grade) =>
      <div className="grade-bar__grade font-semibold">
        {(grade |> string_of_int) ++ ("/" ++ maxGrade(gradeLabels)) |> str}
      </div>
    }}
  </div>

let handleClick = (gradeSelectCB, grading, newGrade) =>
  switch gradeSelectCB {
  | None => ()
  | Some(callBack) => callBack(grading |> Grading.updateGrade(newGrade))
  }

let gradeBarPill = (gradeLabel, grading, gradeSelectCB) => {
  let myGrade = gradeLabel |> GradeLabel.grade
  <div
    key={myGrade->string_of_int}
    title={gradeLabel->GradeLabel.label}
    role="button"
    onClick={_event => handleClick(gradeSelectCB, grading, myGrade)}
    className={gradePillClasses(grading->Grading.grade, myGrade, gradeSelectCB)}>
    {switch gradeSelectCB {
    | None => React.null
    | Some(_CB) => myGrade->string_of_int->str
    }}
  </div>
}

let gradeBarPanel = (grading, gradeLabels, gradeSelectCB) =>
  <div className="grade-bar__track" role="group">
    {List.map(gradeLabel => gradeBarPill(gradeLabel, grading, gradeSelectCB), gradeLabels)
    ->Array.of_list
    ->React.array}
  </div>

@react.component
let make = (~grading, ~gradeSelectCB=?, ~criterion) => {
  let gradeLabels = criterion |> EvaluationCriterion.gradesAndLabels |> Array.to_list
  <div className="flex-column" role="toolbar">
    {gradeBarHeader(grading, gradeLabels)} {gradeBarPanel(grading, gradeLabels, gradeSelectCB)}
  </div>
}
