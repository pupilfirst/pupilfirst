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

type evaluationCriterion = (int, string, bool);

type prerequisiteTarget = (int, string, bool);

type state = {
  title: string,
  targetGroupId: string,
  role: TargetDetails.role,
  evaluationCriteria: array(string),
  prerequisiteTargets: array(string),
  methodOfCompletion,
  quiz: array(TargetDetails__QuizQuestion.t),
  linkToComplete: option(string),
  dirty: bool,
  saving: bool,
  loading: bool,
  visibility: TargetDetails.visibility,
  completionInstructions: option(string),
};

type action =
  | LoadTargetDetails(TargetDetails.t)
  | UpdateTitle(string)
  | UpdatePrerequisiteTargets(prerequisiteTarget);

module TargetDetailsQuery = [%graphql
  {|
    query($targetId: ID!) {
      targetDetails(targetId: $targetId) {
        title
        targetGroupId
        evaluationCriteria
        prerequisiteTargets
        quiz {
          id
          question
          answerOptions {
            id
            answer
            hint
            correctAnswer
          }
        }
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
      loading: false,
    }
  | UpdateTitle(title) => {...state, title}
  | UpdatePrerequisiteTargets(prerequisiteTarget) =>
    let (targetId, _title, selected) = prerequisiteTarget;
    let currentPrerequisiteTargets = state.prerequisiteTargets;
    {
      ...state,
      prerequisiteTargets:
        selected
          ? currentPrerequisiteTargets
            |> Js.Array.concat([|targetId |> string_of_int|])
          : currentPrerequisiteTargets
            |> Js.Array.filter(id => id != (targetId |> string_of_int)),
    };
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

let updateTitle = (send, event) => {
  let title = ReactEvent.Form.target(event)##value;
  send(UpdateTitle(title));
};

let eligiblePrerequisiteTargets = (targetId, targets, state, targetGroups) => {
  let targetGroupId =
    targets
    |> ListUtils.unsafeFind(
         target => targetId == Target.id(target),
         "unable",
       )
    |> Target.targetGroupId;
  let targetGroup =
    targetGroups
    |> Array.of_list
    |> ArrayUtils.unsafeFind(
         tg => TargetGroup.id(tg) == targetGroupId,
         "cannot find target group with ID: " ++ targetGroupId,
       );
  let levelId = targetGroup |> TargetGroup.levelId;
  let targetGroupsInSameLevel =
    targetGroups
    |> List.filter(tg => TargetGroup.levelId(tg) == levelId)
    |> List.map(tg => TargetGroup.id(tg));
  targets
  |> List.filter(target => !(target |> Target.visibility === Archived))
  |> List.filter(target =>
       targetGroupsInSameLevel |> List.mem(Target.targetGroupId(target))
     )
  |> List.filter(target => Target.id(target) != targetId);
};

let prerequisiteTargetsForSelector = (targetId, targets, state, targetGroups) => {
  let selectedTargetIds = state.prerequisiteTargets;
  eligiblePrerequisiteTargets(targetId, targets, state, targetGroups)
  |> List.map(criterion => {
       let selected =
         selectedTargetIds
         |> Js.Array.findIndex(selectedTargetId =>
              targetId == selectedTargetId
            )
         > (-1);
       (
         criterion |> Target.id |> int_of_string,
         criterion |> Target.title,
         selected,
       );
     });
};

let multiSelectPrerequisiteTargetsCB = (send, key, value, selected) => {
  send(UpdatePrerequisiteTargets((key, value, selected)));
};

let prerequisiteTargetEditor = (send, prerequisiteTargetsData) => {
  prerequisiteTargetsData |> ListUtils.isNotEmpty
    ? <div>
        <label
          className="block tracking-wide text-sm font-semibold mb-2"
          htmlFor="prerequisite_targets">
          {"Are there any prerequisite targets?" |> str}
        </label>
        <div id="prerequisite_targets" className="mb-6">
          <School__SelectBox
            noSelectionHeading="No prerequisites selected"
            noSelectionDescription="This target will not have any prerequisites."
            emptyListDescription="There are no other targets available for selection."
            items={
              prerequisiteTargetsData |> School__SelectBox.convertOldItems
            }
            selectCB={
              multiSelectPrerequisiteTargetsCB(send)
              |> School__SelectBox.convertOldCallback
            }
          />
        </div>
      </div>
    : ReasonReact.null;
};

[@react.component]
let make = (~targetId, ~targets, ~targetGroups, ~evaluationCriteria) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        title: "",
        targetGroupId: "",
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

  <div className="max-w-3xl py-6 px-3 mx-auto" id="target-properties">
    {state.loading
       ? SkeletonLoading.multiple(
           ~count=2,
           ~element=SkeletonLoading.contents(),
         )
       : <div className="mt-2">
           <label
             className="inline-block tracking-wide text-sm font-semibold mb-2"
             htmlFor="title">
             {"Title" |> str}
           </label>
           <span> {"*" |> str} </span>
           <div
             className="flex items-center border-b border-gray-400 pb-2 mb-4">
             <input
               className="appearance-none block w-full bg-white text-2xl pr-4 font-semibold text-gray-900 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
               id="title"
               type_="text"
               placeholder="Type target title here"
               onChange={updateTitle(send)}
               value={state.title}
             />
           </div>
           <School__InputGroupError
             message="Enter a valid title"
             active={state.title |> String.length < 1}
           />
           {prerequisiteTargetEditor(
              send,
              prerequisiteTargetsForSelector(
                targetId,
                targets,
                state,
                targetGroups,
              ),
            )}
         </div>}
  </div>;
};
