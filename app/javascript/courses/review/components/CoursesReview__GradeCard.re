[@bs.config {jsx: 3}];

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

module CreateGradingMutation = [%graphql
  {|
  mutation($submissionId: ID!, $feedback: String, $grades: [GradeInput!]!) {
    createGrading(submissionId: $submissionId, feedback: $feedback, grades: $grades){
      success
    }
  }
|}
];

let gradeSubmissionQuery = (authenticityToken, submissionId, state, setState) => {
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
         Notification.success("halo", "tada") :
         Notification.error("halo", "tada");
       setState(state => {...state, saving: true});
       Js.Promise.resolve();
     })
  |> ignore;
};

let validGrades = (grades, evaluvationCriteria, status) =>
  (
    switch (status) {
    | Graded(_)
    | Grading => true
    | UnGraded => false
    }
  )
  && grades
  |> Array.length == (evaluvationCriteria |> Array.length);

let passed = (grades, passgrade) =>
  grades
  |> Js.Array.filter(g => g |> Grade.value < passgrade)
  |> ArrayUtils.isEmpty;

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
        validGrades(newGrades, evaluvationCriteria, state.status) ?
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
    "border-r py-1 px-2 text-sm flex-1 font-semibold "
    ++ (
      switch (setState) {
      | Some(_) =>
        "cursor-pointer "
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
        "bg-green-500 text-white" : "bg-red-500 text-white" :
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
  <div className="mt-4 pr-4">
    {
      gradePillHeader(
        evaluvationCriterion |> EvaluationCriterion.name,
        gradeValue,
        gradeLabels,
      )
    }
    <div
      className="inline-flex w-full text-center border rounded-lg overflow-hidden mt-1">
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
  <div className="mt-4 pr-4">
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

  <div className="w-2/5 items-center flex flex-col justify-center border-l">
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

let gradeSubmission =
    (authenticityToken, submissionId, state, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  switch (state.status) {
  | Graded(_) =>
    gradeSubmissionQuery(authenticityToken, submissionId, state, setState)
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
    <div className="p-4 md:px-6 md:pt-5">
      {
        feedback == [||] && grades == [||] ?
          <CoursesReview__FeedbackEditor
            feedback={state.newFeedback}
            label="Add feedback"
            updateFeedbackCB={updateFeedbackCB(setState)}
          /> :
          React.null
      }
      <div className="w-full pb-4 mt-4">
        <div className="font-semibold text-sm lg:text-base">
          {"Grade Card" |> str}
        </div>
        <div className="flex">
          <div className="w-3/5">
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
        <div className="border-t">
          <div className="flex bg-gray-200 p-4 md:p-6 text-center font-bold">
            <div
              className="px-4 py-2 bg-orange-400 mx-auto cursor-pointer"
              onClick={
                gradeSubmission(
                  authenticityToken,
                  submissionId,
                  state,
                  setState,
                )
              }>
              {"Review Submission" |> str}
            </div>
          </div>
        </div>
      | _ => React.null
      }
    }
  </div>;
};
