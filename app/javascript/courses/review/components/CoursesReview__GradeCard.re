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
    <div> {evaluvationCriteriaName |> str} </div>
    <div>
      {
        (selectedGrade |> string_of_int)
        ++ "/"
        ++ (GradeLabel.maxGrade(gradeLabels) |> string_of_int)
        |> str
      }
    </div>
  </div>;

let gradePillClasses = (selectedGrade, currentGrade, passgrade) =>
  currentGrade <= selectedGrade ?
    selectedGrade >= passgrade ? "bg-green-500" : "bg-red-500" : "bg-gray-100";

let showGradePill =
    (gradeLabels, evaluvationCriterion, gradeValue, passGrade, setState) =>
  <div className="mt-4 pr-4">
    {
      gradePillHeader(
        evaluvationCriterion |> EvaluationCriterion.name,
        gradeValue,
        gradeLabels,
      )
    }
    <div className="inline-flex w-full text-center">
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
                 "border py-1 px-4 text-sm flex-1 cursor-pointer "
                 ++ gradePillClasses(gradeValue, gradeLabelGrade, passGrade)
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

  <div className="mx-auto">
    <div
      className={
        "flex border-2 rounded-lg border-" ++ color ++ "-500 px-4 py-6"
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
              classes="fas fa-exclamation-triangle text-3xl text-red-500 mx-1"
            />
        | Grading =>
          <FaIcon classes="fas fa-signature text-6xl p-2 text-orange-600" />
        | UnGraded =>
          <FaIcon classes="fas fa-marker text-6xl p-2 text-gray-600" />
        }
      }
    </div>
    <div className={"text-center text-" ++ color ++ "-500 font-bold mt-2"}>
      {text |> str}
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
  <div className="p-4 md:px-6 md:pt-5">
    <div className="font-semibold text-sm lg:text-base">
      {"Grade Card" |> str}
    </div>
    {
      feedback == [||] && grades == [||] ?
        <CoursesReview__FeedbackEditor
          feedback={state.newFeedback}
          label="Add feedback"
          updateFeedbackCB={updateFeedbackCB(setState)}
        /> :
        React.null
    }
    <div className="flex justify-between w-full pb-4 mt-4">
      <div className="w-3/5">
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
            showGrades(grades, gradeLabels, passGrade, evaluvationCriteria)
          }
        }
      </div>
      {submissionStatusIcon(state.status)}
    </div>
  </div>;
};