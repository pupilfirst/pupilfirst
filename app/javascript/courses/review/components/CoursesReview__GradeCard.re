[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__GradeCard.css")|}];

open CoursesReview__Types;
let str = React.string;

type status =
  | Graded(bool)
  | Grading
  | Ungraded;

type state = {
  grades: array(Grade.t),
  newFeedback: string,
  saving: bool,
};

let passed = (grades, passgrade) =>
  grades
  |> Js.Array.filter(g => g |> Grade.value < passgrade)
  |> ArrayUtils.isEmpty;

module CreateGradingMutation = [%graphql
  {|
    mutation($submissionId: ID!, $feedback: String, $grades: [GradeInput!]!) {
      createGrading(submissionId: $submissionId, feedback: $feedback, grades: $grades){
        success
      }
    }
  |}
];

module UndoGradingMutation = [%graphql
  {|
    mutation($submissionId: ID!) {
      undoGrading(submissionId: $submissionId){
        success
      }
    }
  |}
];

let undoGrading = (authenticityToken, submissionId, setState) => {
  setState(state => {...state, saving: true});

  UndoGradingMutation.make(~submissionId, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##undoGrading##success
         ? DomUtils.reload() |> ignore
         : setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let gradeSubmissionQuery =
    (
      authenticityToken,
      submissionId,
      state,
      setState,
      passGrade,
      updateSubmissionCB,
    ) => {
  let jsGradesArray = state.grades |> Array.map(g => g |> Grade.asJsType);

  setState(state => {...state, saving: true});

  (
    state.newFeedback == ""
      ? CreateGradingMutation.make(~submissionId, ~grades=jsGradesArray, ())
      : CreateGradingMutation.make(
          ~submissionId,
          ~feedback=state.newFeedback,
          ~grades=jsGradesArray,
          (),
        )
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##createGrading##success
         ? updateSubmissionCB(
             ~grades=state.grades,
             ~passed=Some(passed(state.grades, passGrade)),
             ~newFeedback=Some(state.newFeedback),
           )
         : ();
       setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let validGrades = (grades, evaluationCriteria) =>
  grades |> Array.length == (evaluationCriteria |> Array.length);

let updateGrading = (grade, state, setState) => {
  let newGrades =
    state.grades
    |> Js.Array.filter(g =>
         g
         |> Grade.evaluationCriterionId
         != (grade |> Grade.evaluationCriterionId)
       )
    |> Array.append([|grade|]);

  setState(state => {...state, grades: newGrades});
};
let handleGradePillClick =
    (evaluationCriterionId, value, state, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  switch (setState) {
  | Some(setState) =>
    updateGrading(
      Grade.make(~evaluationCriterionId, ~value),
      state,
      setState,
    )
  | None => ()
  };
};

let findEvaluvationCriterion = (evaluationCriteria, evaluationCriterionId) =>
  switch (
    evaluationCriteria
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
    evaluationCriteria[0];
  };

let gradePillHeader = (evaluationCriteriaName, selectedGrade, gradeLabels) =>
  <div className="flex justify-between">
    <p className="text-xs font-semibold text-gray-800">
      {evaluationCriteriaName |> str}
    </p>
    <p className="text-xs font-semibold text-gray-800">
      {(selectedGrade |> string_of_int)
       ++ "/"
       ++ (
         GradeLabel.maxGrade(gradeLabels |> Array.to_list) |> string_of_int
       )
       |> str}
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
          currentGrade >= passgrade
            ? "hover:bg-green-500 hover:text-white "
            : "hover:bg-red-500 hover:text-white "
        )
      | None => ""
      }
    );

  defaultClasses
  ++ (
    currentGrade <= selectedGrade
      ? selectedGrade >= passgrade
          ? "bg-green-500 text-white shadow-lg"
          : "bg-red-500 text-white shadow-lg"
      : "bg-gray-100 text-gray-800"
  );
};

let showGradePill =
    (
      key,
      gradeLabels,
      evaluvationCriterion,
      gradeValue,
      passGrade,
      state,
      setState,
    ) =>
  <div
    ariaLabel={
      "evaluation-criterion-"
      ++ (evaluvationCriterion |> EvaluationCriterion.id)
    }
    key={key |> string_of_int}
    className="md:pr-8 mt-4">
    {gradePillHeader(
       evaluvationCriterion |> EvaluationCriterion.name,
       gradeValue,
       gradeLabels,
     )}
    <div
      className="course-review-grade-card__grade-bar inline-flex w-full text-center mt-1">
      {gradeLabels
       |> Array.map(gradeLabel => {
            let gradeLabelGrade = gradeLabel |> GradeLabel.grade;

            <div
              key={gradeLabelGrade |> string_of_int}
              onClick={handleGradePillClick(
                evaluvationCriterion |> EvaluationCriterion.id,
                gradeLabelGrade,
                state,
                setState,
              )}
              title={gradeLabel |> GradeLabel.label}
              className={gradePillClasses(
                gradeValue,
                gradeLabelGrade,
                passGrade,
                setState,
              )}>
              {switch (setState) {
               | Some(_) => gradeLabelGrade |> string_of_int |> str
               | None => React.null
               }}
            </div>;
          })
       |> React.array}
    </div>
  </div>;

let showGrades = (grades, gradeLabels, passGrade, evaluationCriteria, state) =>
  <div>
    {grades
     |> Array.mapi((key, grade) =>
          showGradePill(
            key,
            gradeLabels,
            findEvaluvationCriterion(
              evaluationCriteria,
              grade |> Grade.evaluationCriterionId,
            ),
            grade |> Grade.value,
            passGrade,
            state,
            None,
          )
        )
     |> React.array}
  </div>;
let renderGradePills =
    (gradeLabels, evaluationCriteria, grades, passGrade, state, setState) =>
  evaluationCriteria
  |> Array.mapi((key, ec) => {
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

       showGradePill(
         key,
         gradeLabels,
         ec,
         gradeValue,
         passGrade,
         state,
         Some(setState),
       );
     })
  |> React.array;
let gradeStatusClasses = (color, status) =>
  "w-24 h-20 rounded-lg border flex justify-center items-center bg-"
  ++ color
  ++ "-100 "
  ++ "border-"
  ++ color
  ++ "-400 "
  ++ (
    switch (status) {
    | Grading => "course-review-grade-card__status-pulse"
    | Graded(_)
    | Ungraded => ""
    }
  );

let submissionStatusIcon = (status, submission, authenticityToken, setState) => {
  let (text, color) =
    switch (status) {
    | Graded(passed) => passed ? ("Passed", "green") : ("Failed", "red")
    | Grading => ("Reviewing", "orange")
    | Ungraded => ("Not Reviewed", "gray")
    };

  <div
    ariaLabel="submission-status"
    className="flex w-full md:w-3/6 flex-col items-center justify-center md:border-l">
    <div
      className="flex items-start md:items-stretch justify-center mt-4 md:mt-0 w-full md:pl-6">
      {switch (submission |> Submission.evaluatedAt, status) {
       | (Some(date), Graded(_)) =>
         <div
           className="bg-gray-200 flex flex-col flex-1 justify-between rounded-lg pt-3 mr-2">
           {switch (submission |> Submission.evaluatorName) {
            | Some(name) =>
              <div>
                <p className="text-xs px-3"> {"Evaluated By" |> str} </p>
                <p className="text-sm font-semibold px-3 pb-3">
                  {name |> str}
                </p>
              </div>
            | None => React.null
            }}
           <div className="text-xs bg-gray-300 p-1 rounded-b-lg px-3 py-1">
             {"on " ++ (date |> Submission.prettyDate) |> str}
           </div>
         </div>
       | (None, Graded(_))
       | (_, Grading)
       | (_, Ungraded) => React.null
       }}
      <div className="w-24 flex flex-col items-center justify-center">
        <div className={gradeStatusClasses(color, status)}>
          {switch (status) {
           | Graded(passed) =>
             passed
               ? <Icon
                   className="if i-badge-check-solid text-3xl md:text-5xl text-green-500"
                 />
               : <FaIcon
                   classes="fas fa-exclamation-triangle text-3xl md:text-4xl text-red-500"
                 />
           | Grading =>
             <Icon
               className="if i-writing-pad-solid text-3xl md:text-5xl text-orange-300"
             />
           | Ungraded =>
             <Icon
               className="if i-eye-solid text-3xl md:text-4xl text-gray-400"
             />
           }}
        </div>
        <p
          className={
            "text-xs text-center w-full border rounded px-1 py-px font-semibold mt-1 "
            ++ "border-"
            ++ color
            ++ "-400 "
            ++ "bg-"
            ++ color
            ++ "-100 "
            ++ "text-"
            ++ color
            ++ "-800 "
          }>
          {text |> str}
        </p>
      </div>
    </div>
    {switch (submission |> Submission.evaluatedAt, status) {
     | (Some(_), Graded(_)) =>
       <div className="mt-4 md:pl-6 w-full">
         <button
           onClick={_ =>
             undoGrading(
               authenticityToken,
               submission |> Submission.id,
               setState,
             )
           }
           className="btn btn-danger btn-small w-full">
           <i className="fas fa-undo" />
           <span className="ml-2"> {"Undo Grading" |> str} </span>
         </button>
       </div>
     | (None, Graded(_))
     | (_, Grading)
     | (_, Ungraded) => React.null
     }}
  </div>;
};

let updateFeedbackCB = (setState, newFeedback) =>
  setState(state => {...state, newFeedback});

let gradeSubmission =
    (
      authenticityToken,
      submissionId,
      state,
      setState,
      passGrade,
      updateSubmissionCB,
      status,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  switch (status) {
  | Graded(_) =>
    gradeSubmissionQuery(
      authenticityToken,
      submissionId,
      state,
      setState,
      passGrade,
      updateSubmissionCB,
    )
  | Grading
  | Ungraded => ()
  };
};

let showFeedbackForm = (grades, state, setState) =>
  switch (grades) {
  | [||] =>
    <CoursesReview__FeedbackEditor
      feedback={state.newFeedback}
      label="Add Your Feedback"
      updateFeedbackCB={updateFeedbackCB(setState)}
    />
  | _ => React.null
  };
let reviewButtonDisabled = status =>
  switch (status) {
  | Graded(_) => false
  | Grading
  | Ungraded => true
  };

let computeStatus =
    (submission, selectedGrades, evaluationCriteria, passGrade) =>
  switch (
    submission |> Submission.passedAt,
    submission |> Submission.grades |> ArrayUtils.isNotEmpty,
  ) {
  | (Some(_), _) => Graded(true)
  | (None, true) => Graded(false)
  | (_, _) =>
    if (selectedGrades == [||]) {
      Ungraded;
    } else if (selectedGrades
               |> Array.length != (evaluationCriteria |> Array.length)) {
      Grading;
    } else {
      Graded(passed(selectedGrades, passGrade));
    }
  };

let submitButtonText = (feedback, grades) =>
  switch (feedback != "", grades |> ArrayUtils.isNotEmpty) {
  | (false, false)
  | (false, true) => "Save grades"
  | (true, false)
  | (true, true) => "Save grades & send feedback"
  };

[@react.component]
let make =
    (
      ~authenticityToken,
      ~submission,
      ~gradeLabels,
      ~evaluationCriteria,
      ~passGrade,
      ~updateSubmissionCB,
    ) => {
  let (state, setState) =
    React.useState(() => {grades: [||], newFeedback: "", saving: false});
  let status =
    computeStatus(submission, state.grades, evaluationCriteria, passGrade);
  <DisablingCover disabled={state.saving}>
    <div className="px-4 md:px-6 ">
      {showFeedbackForm(submission |> Submission.grades, state, setState)}
      <div className="w-full pb-4 pt-4 md:pt-5">
        <div className="font-semibold text-sm lg:text-base">
          {"Grade Card" |> str}
        </div>
        <div className="flex md:flex-row flex-col">
          <div className="w-full md:w-3/6">
            {switch (submission |> Submission.grades) {
             | [||] =>
               renderGradePills(
                 gradeLabels,
                 evaluationCriteria,
                 state.grades,
                 passGrade,
                 state,
                 setState,
               )

             | grades =>
               showGrades(
                 grades,
                 gradeLabels,
                 passGrade,
                 evaluationCriteria,
                 state,
               )
             }}
          </div>
          {submissionStatusIcon(
             status,
             submission,
             authenticityToken,
             setState,
           )}
        </div>
      </div>
    </div>
    {switch (submission |> Submission.grades) {
     | [||] =>
       <div className="bg-white py-4 mx-3 md:mx-6 border-t">
         <button
           disabled={reviewButtonDisabled(status)}
           className="btn btn-success btn-large w-full border border-green-600"
           onClick={gradeSubmission(
             authenticityToken,
             submission |> Submission.id,
             state,
             setState,
             passGrade,
             updateSubmissionCB,
             status,
           )}>
           {submitButtonText(state.newFeedback, state.grades) |> str}
         </button>
       </div>

     | _ => React.null
     }}
  </DisablingCover>;
};
