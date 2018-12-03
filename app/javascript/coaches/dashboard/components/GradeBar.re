[%bs.raw {|require("./GradeBar.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("GradeBar");

let gradeDescription = (gradeLabels, grading) =>
  (grading |> Grading.criterionName)
  ++ (
    switch (grading |> Grading.grade) {
    | Some(grade) => ": " ++ (grade |> GradeLabel.labelFor(gradeLabels))
    | None => ""
    }
  );

let maxGrade = gradeLabels =>
  gradeLabels |> GradeLabel.maxGrade |> string_of_int;

let buttonClasses = (gradeReceived, passGrade, buttonGrade, callBack) => {
  let failed =
    switch (gradeReceived) {
    | None => false
    | Some(grade) => grade < passGrade
    };
  let beyondGradeReceived =
    switch (gradeReceived) {
    | None => true
    | Some(grade) => buttonGrade > grade
    };
  "btn grade-bar__track--select "
  ++ (
    switch (callBack) {
    | None when beyondGradeReceived => ""
    | None =>
      failed ? "grade-bar__button--failed" : "grade-bar__button--passed"
    | Some(_cb) =>
      switch (gradeReceived) {
      | None => ""
      | Some(grade) when grade == buttonGrade => "grade-bar__button--selected"
      | Some(_otherGrade) => ""
      }
    }
  );
};

let gradeBarHeader = (grading, gradeLabels) =>
  <div className="grade-bar__header d-flex justify-content-between">
    <div className="grade-bar__criterion_name">
      (grading |> gradeDescription(gradeLabels) |> str)
    </div>
    (
      switch (grading |> Grading.grade) {
      | None => ReasonReact.null
      | Some(grade) =>
        <div>
          ((grade |> string_of_int) ++ "/" ++ maxGrade(gradeLabels) |> str)
        </div>
      }
    )
  </div>;

let gradeBarButton = (gradeLabel, grading, gradeSelectCB) =>
  <div
    key=(gradeLabel |> GradeLabel.grade |> string_of_int)
    role="button"
    className=(
      buttonClasses(
        grading |> Grading.grade,
        3,
        gradeLabel |> GradeLabel.grade,
        gradeSelectCB,
      )
    )>
    (
      switch (gradeSelectCB) {
      | None => ReasonReact.null
      | Some(_CB) => gradeLabel |> GradeLabel.grade |> string_of_int |> str
      }
    )
  </div>;

let gradeBarPanel = (grading, gradeLabels, gradeSelectCB) =>
  <div className="btn-group grade-bar__track d-flex" role="group">
    (
      gradeLabels
      |> List.map(gradeLabel =>
           gradeBarButton(gradeLabel, grading, gradeSelectCB)
         )
      |> Array.of_list
      |> ReasonReact.array
    )
  </div>;

let make = (~grading, ~gradeLabels, ~gradeSelectCB=?, _children) => {
  ...component,
  render: _self =>
    <div
      className="btn-toolbar grade-bar__container flex-column mb-4"
      role="toolbar">
      (gradeBarHeader(grading, gradeLabels))
      (gradeBarPanel(grading, gradeLabels, gradeSelectCB))
    </div>,
};