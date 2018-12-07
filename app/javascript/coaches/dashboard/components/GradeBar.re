[%bs.raw {|require("./GradeBar.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("GradeBar");

let gradeDescription = (gradeLabels, grading) =>
  <div className="grade-bar__criterion-name">
    (grading |> Grading.criterionName |> str)
    (
      switch (grading |> Grading.grade) {
      | Some(grade) =>
        <span>
          (": " |> str)
          <span className="grade-bar__grade-label">
            (grade |> GradeLabel.labelFor(gradeLabels) |> str)
          </span>
        </span>
      | None => ReasonReact.null
      }
    )
  </div>;

let maxGrade = gradeLabels =>
  gradeLabels |> GradeLabel.maxGrade |> string_of_int;

let gradePillClasses = (gradeReceived, passGrade, pillGrade, callBack) => {
  let defaultClasses = "btn grade-bar__grade-pill";
  let resultModifier =
    switch (gradeReceived) {
    | None => ""
    | Some(grade) when pillGrade > grade => ""
    | Some(grade) =>
      grade < passGrade ?
        " grade-bar__grade-pill--failed" : " grade-bar__grade-pill--passed"
    };
  let selectableModifier =
    switch (callBack) {
    | None => ""
    | Some(_callBack) =>
      pillGrade < passGrade ?
        " grade-bar__grade-pill--selectable-fail" :
        " grade-bar__grade-pill--selectable-pass"
    };
  defaultClasses ++ resultModifier ++ selectableModifier;
};

let gradeBarHeader = (grading, gradeLabels) =>
  <div className="grade-bar__header d-flex justify-content-between">
    (grading |> gradeDescription(gradeLabels))
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

let handleClick = (gradeSelectCB, grading, newGrade) =>
  switch (gradeSelectCB) {
  | None => ()
  | Some(callBack) => callBack(grading |> Grading.updateGrade(newGrade))
  };

let gradeBarPill = (gradeLabel, grading, gradeSelectCB, passGrade) => {
  let myGrade = gradeLabel |> GradeLabel.grade;
  <div
    key=(myGrade |> string_of_int)
    role="button"
    onClick=(_event => handleClick(gradeSelectCB, grading, myGrade))
    className=(
      gradePillClasses(
        grading |> Grading.grade,
        passGrade,
        myGrade,
        gradeSelectCB,
      )
    )>
    (
      switch (gradeSelectCB) {
      | None => ReasonReact.null
      | Some(_CB) => myGrade |> string_of_int |> str
      }
    )
  </div>;
};

let gradeBarPanel = (grading, gradeLabels, gradeSelectCB, passGrade) =>
  <div className="btn-group grade-bar__track d-flex" role="group">
    (
      gradeLabels
      |> List.map(gradeLabel =>
           gradeBarPill(gradeLabel, grading, gradeSelectCB, passGrade)
         )
      |> Array.of_list
      |> ReasonReact.array
    )
  </div>;

let make = (~grading, ~gradeLabels, ~gradeSelectCB=?, ~passGrade, _children) => {
  ...component,
  render: _self =>
    <div
      className="btn-toolbar grade-bar__container flex-column mb-4"
      role="toolbar">
      (gradeBarHeader(grading, gradeLabels))
      (gradeBarPanel(grading, gradeLabels, gradeSelectCB, passGrade))
    </div>,
};