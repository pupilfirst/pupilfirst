[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__GradeCard.css")|}];

open CoursesReview__Types;
let str = React.string;
type status =
  | Graded(bool)
  | Grading
  | UnGraded;

type state = {
  status,
  grades: array(Grade.t),
  newFeedback: string,
};

let updateGrading = (grade, setState) =>
  setState(state =>
    {
      ...state,
      status: Grading,
      grades:
        state.grades
        |> Js.Array.filter(g =>
             g
             |> Grade.evaluationCriterionId
             != (grade |> Grade.evaluationCriterionId)
           )
        |> Array.append([|grade|]),
    }
  );

let handleGradePillClick = (evaluationCriterionId, value, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  switch (setState) {
  | Some(setState) =>
    updateGrading(Grade.make(~evaluationCriterionId, ~value), setState)
  | None => ()
  };
};

let findEvaluvationCriterion = (evaluvationCriteria, evaluationCriterionId) =>
  switch (
    evaluvationCriteria
    |> Js.Array.find(ec =>
         ec |> EvaluationCriterion.id == evaluationCriterionId
       )
  ) {
  | Some(ec) => ec
  | None =>
    Rollbar.error(
      "Unable to find evaluation Criterion with id: "
      ++ evaluationCriterionId
      ++ "in CoursesRevew__GradeCard",
    );
    evaluvationCriteria[0];
  };

let gradePillHeader = (evaluvationCriteriaName, selectedGrade, gradeLabels) =>
  <div className="flex justify-between">
    <p className="text-xs font-semibold text-gray-800">
      {evaluvationCriteriaName |> str}
    </p>
    <p className="text-xs font-semibold text-gray-800">
      {
        (selectedGrade |> string_of_int)
        ++ "/"
        ++ (GradeLabel.maxGrade(gradeLabels) |> string_of_int)
        |> str
      }
    </p>
  </div>;

let gradePillClasses = (selectedGrade, currentGrade, passgrade, setState) => {
  let defaultClasses =
    "course-review-grade-card__grade-pill border-gray-400 py-1 px-2 text-sm flex-1 font-semibold "
    ++ (
      switch (setState) {
      | Some(_) =>
        "cursor-pointer hover:shadow-lg focus:outline-none "
        ++ (
          currentGrade >= passgrade ?
            "hover:bg-green-500 hover:text-white " :
            "hover:bg-red-500 hover:text-white "
        )
      | None => ""
      }
    );

  defaultClasses
  ++ (
    currentGrade <= selectedGrade ?
      selectedGrade >= passgrade ?
        "bg-green-500 text-white shadow-lg" : "bg-red-500 text-white shadow-lg" :
      "bg-gray-100 text-gray-800"
  );
};

let showGradePill =
    (gradeLabels, evaluvationCriterion, gradeValue, passGrade, setState) =>
  <div className="md:pr-8 mt-4">
    {
      gradePillHeader(
        evaluvationCriterion |> EvaluationCriterion.name,
        gradeValue,
        gradeLabels,
      )
    }
    <div
      className="course-review-grade-card__grade-bar inline-flex w-full text-center mt-1">
      {
        gradeLabels
        |> Array.map(gradeLabel => {
             let gradeLabelGrade = gradeLabel |> GradeLabel.grade;

             <div
               onClick={
                 handleGradePillClick(
                   evaluvationCriterion |> EvaluationCriterion.id,
                   gradeLabelGrade,
                   setState,
                 )
               }
               title={gradeLabel |> GradeLabel.label}
               className={
                 gradePillClasses(
                   gradeValue,
                   gradeLabelGrade,
                   passGrade,
                   setState,
                 )
               }>
               {
                 switch (setState) {
                 | Some(_) => gradeLabelGrade |> string_of_int |> str
                 | None => React.null
                 }
               }
             </div>;
           })
        |> React.array
      }
    </div>
  </div>;

let showGrades = (grades, gradeLabels, passGrade, evaluvationCriteria) =>
  <div>
    {
      grades
      |> Array.map(grade =>
           showGradePill(
             gradeLabels,
             findEvaluvationCriterion(
               evaluvationCriteria,
               grade |> Grade.evaluationCriterionId,
             ),
             grade |> Grade.value,
             passGrade,
             None,
           )
         )
      |> React.array
    }
  </div>;
let renderGradePills =
    (gradeLabels, evaluvationCriteria, grades, passGrade, setState) =>
  evaluvationCriteria
  |> Array.map(ec => {
       let grade =
         grades
         |> Js.Array.find(g =>
              g
              |> Grade.evaluationCriterionId == (ec |> EvaluationCriterion.id)
            );
       let gradeValue =
         switch (grade) {
         | Some(g) => g |> Grade.value
         | None => 0
         };

       showGradePill(gradeLabels, ec, gradeValue, passGrade, Some(setState));
     })
  |> React.array;

let submissionStatusIcon = status => {
  let text =
    switch (status) {
    | Graded(passed) => passed ? "Passed" : "Failed"
    | Grading => "Reviewing"
    | UnGraded => "Not Reviewed"
    };
  let color =
    switch (status) {
    | Graded(passed) => passed ? "green" : "red"
    | Grading => "orange"
    | UnGraded => "gray"
    };

  <div
    className="hidden md:flex w-2/5 items-center flex-col justify-center border-l">
    <div
      className={
        "w-22 h-22 rounded-full border-5 flex justify-center items-center border-"
        ++ color
        ++ "-400"
      }>
      {
        switch (status) {
        | Graded(passed) =>
          passed ?
            <span className="fa-stack text-green-500 text-lg">
              <i className="fas fa-certificate fa-stack-2x" />
              <i className="fas fa-check fa-stack-1x fa-inverse" />
            </span> :
            <FaIcon
              classes="fas fa-exclamation-triangle text-4xl text-red-500"
            />
        | Grading =>
          <FaIcon classes="fas fa-signature text-4xl text-orange-500" />
        | UnGraded => <FaIcon classes="fas fa-marker text-4xl text-gray-400" />
        }
      }
    </div>
    <p className={"text-xs font-semibold text-" ++ color ++ "-800 mt-2"}>
      {text |> str}
    </p>
  </div>;
};

let initalStatus = (passedAt, grades) =>
  switch (passedAt, grades |> ArrayUtils.isNotEmpty) {
  | (Some(_), _) => Graded(true)
  | (None, true) => Graded(false)
  | (_, _) => UnGraded
  };
let updateFeedbackCB = (setState, newFeedback) =>
  setState(state => {...state, newFeedback});

[@react.component]
let make =
    (
      ~gradeLabels,
      ~evaluvationCriteria,
      ~grades,
      ~passGrade,
      ~passedAt,
      ~feedback,
    ) => {
  let (state, setState) =
    React.useState(() =>
      {status: initalStatus(passedAt, grades), grades: [||], newFeedback: ""}
    );
  <div>
    <div className="px-4 md:px-6 ">
      {
        feedback == [||] && grades == [||] ?
          <CoursesReview__FeedbackEditor
            feedback={state.newFeedback}
            label="Add Your Feedback"
            updateFeedbackCB={updateFeedbackCB(setState)}
          /> :
          React.null
      }
      <div className="w-full pb-4 pt-4 md:pt-5">
        <div className="font-semibold text-sm lg:text-base">
          {"Grade Card" |> str}
        </div>
        <div className="flex">
          <div className="w-full md:w-3/5">
            {
              switch (grades) {
              | [||] =>
                renderGradePills(
                  gradeLabels,
                  evaluvationCriteria,
                  state.grades,
                  passGrade,
                  setState,
                )

              | grades =>
                showGrades(
                  grades,
                  gradeLabels,
                  passGrade,
                  evaluvationCriteria,
                )
              }
            }
          </div>
          {submissionStatusIcon(state.status)}
        </div>
      </div>
    </div>
    {
      switch (grades) {
      | [||] =>
        <div className="bg-white py-4 mx-3 md:mx-6 border-t">
          <div
            className="btn btn-success btn-large w-full border border-green-600">
            {"Save Your Review" |> str}
          </div>
        </div>
      | _ => React.null
      }
    }
  </div>;
};