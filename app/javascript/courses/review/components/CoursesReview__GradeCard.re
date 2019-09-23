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

let gradeSubmissionQuery =
    (
      authenticityToken,
      submissionId,
      state,
      setState,
      passGrade,
      updateGradingCB,
    ) => {
  let jsGradesArray = state.grades |> Array.map(g => g |> Grade.asJsType);

  setState(state => {...state, saving: true});

  (
    state.newFeedback == "" ?
      CreateGradingMutation.make(
        ~submissionId,
        ~feedback=state.newFeedback,
        ~grades=jsGradesArray,
        (),
      ) :
      CreateGradingMutation.make(~submissionId, ~grades=jsGradesArray, ())
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##createGrading##success ?
         updateGradingCB(
           ~grades=state.grades,
           ~passed=passed(state.grades, passGrade),
           ~newFeedback=state.newFeedback,
         ) :
         setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let validGrades = (grades, evaluvationCriteria) =>
  grades |> Array.length == (evaluvationCriteria |> Array.length);

let updateGrading = (grade, evaluvationCriteria, state, passGrade, setState) => {
  let newGrades =
    state.grades
    |> Js.Array.filter(g =>
         g
         |> Grade.evaluationCriterionId
         != (grade |> Grade.evaluationCriterionId)
       )
    |> Array.append([|grade|]);

  setState(state =>
    {
      ...state,
      status:
        validGrades(newGrades, evaluvationCriteria) ?
          Graded(passed(newGrades, passGrade)) : Grading,
      grades: newGrades,
    }
  );
};
let handleGradePillClick =
    (
      evaluationCriterionId,
      evaluvationCriteria,
      value,
      state,
      passGrade,
      setState,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  switch (setState) {
  | Some(setState) =>
    updateGrading(
      Grade.make(~evaluationCriterionId, ~value),
      evaluvationCriteria,
      state,
      passGrade,
      setState,
    )
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
    (
      gradeLabels,
      evaluvationCriterion,
      gradeValue,
      passGrade,
      evaluvationCriteria,
      state,
      setState,
    ) =>
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
                   evaluvationCriteria,
                   gradeLabelGrade,
                   state,
                   passGrade,
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

let showGrades = (grades, gradeLabels, passGrade, evaluvationCriteria, state) =>
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
             evaluvationCriteria,
             state,
             None,
           )
         )
      |> React.array
    }
  </div>;
let renderGradePills =
    (gradeLabels, evaluvationCriteria, grades, passGrade, state, setState) =>
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

       showGradePill(
         gradeLabels,
         ec,
         gradeValue,
         passGrade,
         evaluvationCriteria,
         state,
         Some(setState),
       );
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
    className="flex w-full md:w-3/6 flex-col items-center justify-center md:border-l">
    <div
      className="flex items-start md:items-stretch justify-center mt-4 md:mt-0 w-full md:pl-6">
      <div
        className="bg-gray-200 flex flex-col flex-1 justify-between rounded-lg pt-3 mr-2">
        <div>
          <p className="text-xs px-3"> {"Evaluated By" |> str} </p>
          <p className="text-sm font-semibold px-3 pb-3">
            {"Pratham Sehgal" |> str}
          </p>
        </div>
        <div className="text-xs bg-gray-300 p-1 rounded-b-lg px-3 py-1">
          {"on August 6, 2019" |> str}
        </div>
      </div>
      <div className="w-24 flex flex-col items-center justify-center">
        <div
          className={
            "w-24 h-18 rounded-lg border flex justify-center items-center bg-"
            ++ color
            ++ "-100 "
            ++ "border-"
            ++ color
            ++ "-400 "
          }>
          {
            switch (status) {
            | Graded(passed) =>
              passed ?
                <Icon
                  className="if i-badge-check-solid text-3xl md:text-4xl text-green-500"
                /> :
                <FaIcon
                  classes="fas fa-exclamation-triangle text-3xl md:text-4xl text-red-500"
                />
            | Grading =>
              <FaIcon
                classes="fas fa-signature text-3xl md:text-4xl text-orange-500"
              />
            | UnGraded =>
              <FaIcon
                classes="fas fa-marker text-3xl md:text-4xl text-gray-400"
              />
            }
          }
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
    <div className="mt-4 md:pl-6 w-full">
      <div className="btn btn-danger w-full"> {"Undo Grading" |> str} </div>
    </div>
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

let gradeSubmission =
    (
      authenticityToken,
      submissionId,
      state,
      setState,
      passGrade,
      updateGradingCB,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  switch (state.status) {
  | Graded(_) =>
    gradeSubmissionQuery(
      authenticityToken,
      submissionId,
      state,
      setState,
      passGrade,
      updateGradingCB,
    )
  | Grading
  | UnGraded => ()
  };
};

[@react.component]
let make =
    (
      ~authenticityToken,
      ~submissionId,
      ~gradeLabels,
      ~evaluvationCriteria,
      ~grades,
      ~passGrade,
      ~passedAt,
      ~feedback,
      ~updateGradingCB,
    ) => {
  let (state, setState) =
    React.useState(() =>
      {
        status: initalStatus(passedAt, grades),
        grades: [||],
        newFeedback: "",
        saving: false,
      }
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
        <div className="flex md:flex-row flex-col">
          <div className="w-full md:w-3/6">
            {
              switch (grades) {
              | [||] =>
                renderGradePills(
                  gradeLabels,
                  evaluvationCriteria,
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
                  evaluvationCriteria,
                  state,
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
            className="btn btn-success btn-large w-full border border-green-600"
            onClick={
              gradeSubmission(
                authenticityToken,
                submissionId,
                state,
                setState,
                passGrade,
                updateGradingCB,
              )
            }>
            {"Review Submission" |> str}
          </div>
        </div>

      | _ => React.null
      }
    }
  </div>;
};