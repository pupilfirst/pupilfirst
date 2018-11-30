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
  "btn gradebar-button "
  ++ (
    switch (callBack) {
    | None =>
      beyondGradeReceived ?
        "" : failed ? "gradebar-button__failed" : "gradebar-button__passed"
    | Some(_CB) =>
      switch (gradeReceived) {
      | None => ""
      | Some(grade) => grade == buttonGrade ? "gradebar-button__selected" : ""
      }
    }
  );
};

let make = (~grading, ~gradeLabels, ~gradeSelectCB=?, _children) => {
  ...component,
  render: _self =>
    <div
      className="btn-toolbar gradebar-container m-1 flex-column"
      role="toolbar">
      <div className="gradebar=header d-flex justify-content-between">
        <div className="gradebar-criterion_name">
          (grading |> gradeDescription(gradeLabels) |> str)
        </div>
        (
          switch (grading |> Grading.grade) {
          | None => ReasonReact.null
          | Some(grade) =>
            <div>
              (
                (grade |> string_of_int) ++ "/" ++ maxGrade(gradeLabels) |> str
              )
            </div>
          }
        )
      </div>
      <div className="btn-group d-flex" role="group">
        (
          gradeLabels
          |> List.map(gradeLabel =>
               <button
                 key=(gradeLabel |> GradeLabel.grade |> string_of_int)
                 type_="button"
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
                   | Some(_CB) =>
                     gradeLabel |> GradeLabel.grade |> string_of_int |> str
                   }
                 )
               </button>
             )
          |> Array.of_list
          |> ReasonReact.array
        )
      </div>
    </div>,
};