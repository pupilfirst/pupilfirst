[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

type methodOfCompletion =
  | Evaluated
  | VisitLink
  | TakeQuiz
  | MarkAsComplete;

type role =
  | Student
  | Team;

type visibility =
  | Draft
  | Live
  | Archived;

type state = {
  title: string,
  role: TargetDetails.role,
  evaluationCriteria: array(string),
  prerequisiteTargets: array(string),
  methodOfCompletion,
  quiz: array(QuizQuestion.t),
  linkToComplete: option(string),
  dirty: bool,
  saving: bool,
  loading: bool,
  visibility: TargetDetails.visibility,
  completionInstructions: option(string),
};

type action =
  | LoadTargetDetails(TargetDetails.t);

module TargetDetailsQuery = [%graphql
  {|
    query($targetId: ID!) {
      targetDetails(targetId: $targetId) {
        title
        evaluationCriteria
        prerequisiteTargets
        completionInstructions
        visibility
        linkToComplete
        role
      }
  }
|}
];

let reducer = (state, action) =>
  switch (action) {
  | LoadTargetDetails(targetDetails) => {
      ...state,
      title: targetDetails.title,
      role: targetDetails.role,
      evaluationCriteria: targetDetails.evaluationCriteria,
      prerequisiteTargets: targetDetails.prerequisiteTargets,
      quiz: targetDetails.quiz,
    }
  };

let loadTargetDetails = (targetId, send) => {
  let response =
    TargetDetailsQuery.make(~targetId, ())
    |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead(), ~notify=true);
  response
  |> Js.Promise.then_(result => {
       let targetDetails = TargetDetails.makeFromJs(result##targetDetails);
       send(LoadTargetDetails(targetDetails));
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~targetId, ~eligiblePrerequisites=?, ~evaluationCriteria=?) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        title: "",
        role: TargetDetails.Student,
        evaluationCriteria: [||],
        prerequisiteTargets: [||],
        methodOfCompletion: Evaluated,
        quiz: [||],
        linkToComplete: None,
        dirty: false,
        saving: false,
        loading: true,
        visibility: TargetDetails.Draft,
        completionInstructions: None,
      },
    );
  React.useEffect0(() => {
    loadTargetDetails(targetId, send);
    None;
  });
  <div> {"Target details editor goes here" |> str} </div>;
};
