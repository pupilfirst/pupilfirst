[@bs.config {jsx: 3}];
[%bs.raw {|require("./CurriculumEditor__TargetEditor.css")|}];

open CurriculumEditor__Types;
open SchoolAdmin__Utils;

let markIcon: string = [%raw
  "require('./images/target-complete-mark-icon.svg')"
];
let linkIcon: string = [%raw
  "require('./images/target-complete-link-icon.svg')"
];
let quizIcon: string = [%raw
  "require('./images/target-complete-quiz-icon.svg')"
];

let str = ReasonReact.string;
type methodOfCompletion =
  | NotSelected
  | Evaluated
  | VisitLink
  | TakeQuiz
  | MarkAsComplete;

type activeStep =
  | AddContent
  | TargetActions;

type evaluationCriterion = (int, string, bool);

type prerequisiteTarget = (int, string, bool);

type resource = (int, string);

type state = {
  title: string,
  evaluationCriteria: list(evaluationCriterion),
  prerequisiteTargets: list(prerequisiteTarget),
  methodOfCompletion,
  quiz: list(QuizQuestion.t),
  contentBlocks: list(ContentBlock.t),
  linkToComplete: string,
  hasTitleError: bool,
  hasLinktoCompleteError: bool,
  isValidQuiz: bool,
  dirty: bool,
  saving: bool,
  activeStep,
  visibility: Target.visibility,
};

type action =
  | UpdateTitle(string, bool)
  | UpdateLinkToComplete(string, bool)
  | UpdateEvaluationCriterion(int, string, bool)
  | UpdatePrerequisiteTargets(int, string, bool)
  | UpdateMethodOfCompletion(methodOfCompletion)
  | AddQuizQuestion
  | UpdateQuizQuestion(QuizQuestion.id, QuizQuestion.t)
  | RemoveQuizQuestion(QuizQuestion.id)
  | UpdateSaving
  | UpdateActiveStep(activeStep)
  | UpdateVisibility(Target.visibility);

let updateTitle = (send, title) => {
  let hasError = title |> String.length < 2;
  send(UpdateTitle(title, hasError));
};
let updateLinkToComplete = (send, link) => {
  let hasError = UrlUtils.isInvalid(link);
  send(UpdateLinkToComplete(link, hasError));
};

let saveDisabled = state => {
  let hasMethordOfCompletionError =
    switch (state.methodOfCompletion) {
    | NotSelected => true
    | Evaluated =>
      state.evaluationCriteria
      |> List.filter(((_, _, selected)) => selected)
      |> List.length == 0
    | VisitLink => state.hasLinktoCompleteError
    | TakeQuiz => !state.isValidQuiz
    | MarkAsComplete => false
    };
  state.title
  |> String.length < 2
  || state.hasLinktoCompleteError
  || hasMethordOfCompletionError
  || !state.dirty
  || state.saving;
};

let handleMethodOfCompletion = target => {
  let hasQuiz = target |> Target.quiz |> List.length > 0;
  let hasEvaluationCriteria =
    target |> Target.evaluationCriteria |> List.length > 0;
  let hasLinkToComplete =
    switch (target |> Target.linkToComplete) {
    | Some(_) => true
    | None => false
    };
  switch (hasEvaluationCriteria, hasQuiz, hasLinkToComplete) {
  | (true, _y, _z) => Evaluated
  | (_x, true, _z) => TakeQuiz
  | (_x, _y, true) => VisitLink
  | (false, false, false) => MarkAsComplete
  };
};

let eligibleTargets = (targets, targetGroupIds) =>
  targets
  |> List.filter(target =>
       targetGroupIds |> List.mem(target |> Target.targetGroupId)
     )
  |> List.filter(target => !(target |> Target.visibility === Archived));

let handleEC = (evaluationCriteria, target) => {
  let selectedEcIds = target |> Target.evaluationCriteria |> Array.of_list;

  evaluationCriteria
  |> List.map(criterion => {
       let criterionId = criterion |> EvaluationCriteria.id |> int_of_string;
       let selected =
         selectedEcIds
         |> Js.Array.findIndex(selectedCriterionId =>
              criterionId == selectedCriterionId
            )
         > (-1);
       (
         criterion |> EvaluationCriteria.id |> int_of_string,
         criterion |> EvaluationCriteria.name,
         selected,
       );
     });
};

let handlePT = (targets, target) => {
  let selectedTargetIds =
    target |> Target.prerequisiteTargets |> Array.of_list;

  targets
  |> Target.removeTarget(target)
  |> List.map(criterion => {
       let targetId = criterion |> Target.id |> int_of_string;
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

let setPayload = (state, target, authenticityToken) => {
  let payload = Js.Dict.empty();
  let targetData = Js.Dict.empty();
  let prerequisiteTargetIds =
    state.prerequisiteTargets
    |> List.filter(((_, _, selected)) => selected == true)
    |> List.map(((key, _, _)) => key);
  let evaluationCriteriaIds =
    state.methodOfCompletion == Evaluated ?
      state.evaluationCriteria
      |> List.filter(((_, _, selected)) => selected == true)
      |> List.map(((key, _, _)) => key) :
      [];
  let linkToComplete =
    state.methodOfCompletion == VisitLink ? state.linkToComplete : "";
  let quiz = state.methodOfCompletion == TakeQuiz ? state.quiz : [];

  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    targetData,
    "sort_index",
    target |> Target.sortIndex |> string_of_int |> Js.Json.string,
  );
  Js.Dict.set(targetData, "title", state.title |> Js.Json.string);

  Js.Dict.set(
    targetData,
    "prerequisite_target_ids",
    prerequisiteTargetIds |> Json.Encode.(list(int)),
  );

  Js.Dict.set(
    targetData,
    "evaluation_criterion_ids",
    evaluationCriteriaIds |> Json.Encode.(list(int)),
  );

  Js.Dict.set(
    targetData,
    "link_to_complete",
    linkToComplete |> Js.Json.string,
  );

  Js.Dict.set(
    targetData,
    "quiz",
    quiz |> Json.Encode.(list(QuizQuestion.encoder)),
  );
  Js.Dict.set(payload, "target", targetData |> Js.Json.object_);
  payload;
};

let handleQuiz = target => {
  let quiz = target |> Target.quiz;
  quiz |> List.length > 0 ? quiz : [QuizQuestion.empty("0")];
};

let isValidQuiz = quiz =>
  quiz
  |> List.filter(quizQuestion =>
       quizQuestion |> QuizQuestion.isValidQuizQuestion != true
     )
  |> List.length == 0;

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button";
  classes ++ (bool ? " toggle-button__button--active" : " text-gray-600");
};

let completionButtonClasses = value =>
  value ?
    "flex flex-col items-center bg-white border border-gray-400 hover:bg-gray-200 text-sm font-semibold focus:outline-none rounded p-4" :
    "flex flex-col items-center bg-white border border-gray-400 opacity-50 hover:bg-gray-200 text-gray-900 text-sm font-semibold focus:outline-none rounded p-4";
let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full";
let updateDescriptionCB = description => Js.log(description);

let reducer = (state, action) =>
  switch (action) {
  | UpdateTitle(title, hasTitleError) => {
      ...state,
      title,
      hasTitleError,
      dirty: true,
    }
  | UpdateLinkToComplete(linkToComplete, hasLinktoCompleteError) => {
      ...state,
      linkToComplete,
      hasLinktoCompleteError,
      dirty: true,
    }
  | UpdateEvaluationCriterion(key, value, selected) =>
    let oldEC =
      state.evaluationCriteria |> List.filter(((item, _, _)) => item !== key);
    {
      ...state,
      evaluationCriteria: [(key, value, selected), ...oldEC],
      dirty: true,
    };
  | UpdatePrerequisiteTargets(key, value, selected) =>
    let oldPT =
      state.prerequisiteTargets
      |> List.filter(((item, _, _)) => item !== key);
    {
      ...state,
      prerequisiteTargets: [(key, value, selected), ...oldPT],
      dirty: true,
    };
  | UpdateMethodOfCompletion(methodOfCompletion) => {
      ...state,
      methodOfCompletion,
      dirty: true,
    }
  | AddQuizQuestion =>
    let lastQuestionId = state.quiz |> List.rev |> List.hd |> QuizQuestion.id;

    let quiz =
      state.quiz
      |> List.rev
      |> List.append([
           QuizQuestion.empty(
             (lastQuestionId |> int_of_string) + 1 |> string_of_int,
           ),
         ])
      |> List.rev;
    {...state, quiz, dirty: true, isValidQuiz: isValidQuiz(quiz)};
  | UpdateQuizQuestion(id, quizQuestion) =>
    let quiz =
      state.quiz
      |> List.map(a => a |> QuizQuestion.id == id ? quizQuestion : a);
    {...state, quiz, dirty: true, isValidQuiz: isValidQuiz(quiz)};

  | RemoveQuizQuestion(id) =>
    let quiz = state.quiz |> List.filter(a => a |> QuizQuestion.id !== id);
    {...state, quiz, dirty: true, isValidQuiz: isValidQuiz(quiz)};
  | UpdateSaving => {...state, saving: !state.saving}
  | UpdateActiveStep(step) => {...state, activeStep: step}
  | UpdateVisibility(visibility) => {...state, visibility}
  };

[@react.component]
let make =
    (
      ~target,
      ~targetGroupId,
      ~contentBlocks,
      ~evaluationCriteria,
      ~targets,
      ~targetGroupIdsInLevel,
      ~authenticityToken,
      ~updateTargetCB,
      ~hideEditorActionCB,
      ~updateContentBlockDeletionCB,
    ) => {
  let handleInitialState = {
    title: target |> Target.title,
    evaluationCriteria: handleEC(evaluationCriteria, target),
    contentBlocks,
    prerequisiteTargets:
      handlePT(eligibleTargets(targets, targetGroupIdsInLevel), target),
    quiz: handleQuiz(target),
    linkToComplete:
      switch (target |> Target.linkToComplete) {
      | Some(linkToComplete) => linkToComplete
      | None => ""
      },
    methodOfCompletion: handleMethodOfCompletion(target),
    hasTitleError: false,
    hasLinktoCompleteError: false,
    dirty: false,
    isValidQuiz: true,
    saving: false,
    activeStep: AddContent,
    visibility: target |> Target.visibility,
  };

  let (state, dispatch) = React.useReducer(reducer, handleInitialState);

  let targetEvaluated = () =>
    switch (state.methodOfCompletion) {
    | NotSelected => true
    | Evaluated => true
    | VisitLink => false
    | TakeQuiz => false
    | MarkAsComplete => false
    };

  let validNumberOfEvaluationCriteria =
    state.evaluationCriteria
    |> List.filter(((_, _, selected)) => selected)
    |> List.length != 0;

  let multiSelectPrerequisiteTargetsCB = (key, value, selected) =>
    dispatch(UpdatePrerequisiteTargets(key, value, selected));
  let multiSelectEvaluationCriterionCB = (key, value, selected) =>
    dispatch(UpdateEvaluationCriterion(key, value, selected));
  let removeQuizQuestionCB = id => dispatch(RemoveQuizQuestion(id));
  let updateQuizQuestionCB = (id, quizQuestion) =>
    dispatch(UpdateQuizQuestion(id, quizQuestion));
  let questionCanBeRemoved = state.quiz |> List.length > 1;
  let handleErrorCB = () => dispatch(UpdateSaving);
  let handleResponseCB = json => {
    let id = json |> Json.Decode.(field("id", string));
    let sortIndex = json |> Json.Decode.(field("sortIndex", int));
    let prerequisiteTargets =
      state.prerequisiteTargets
      |> List.filter(((_, _, selected)) => selected)
      |> List.map(((id, _, _)) => id);

    let evaluationCriteria =
      switch (state.methodOfCompletion) {
      | Evaluated =>
        state.evaluationCriteria
        |> List.filter(((_, _, selected)) => selected)
        |> List.map(((id, _, _)) => id)
      | _ => []
      };
    let linkToComplete =
      switch (state.methodOfCompletion) {
      | VisitLink => Some(state.linkToComplete)
      | _ => None
      };
    let quiz =
      switch (state.methodOfCompletion) {
      | TakeQuiz => state.quiz
      | _ => []
      };
    let newTarget =
      Target.create(
        id,
        targetGroupId,
        state.title,
        evaluationCriteria,
        prerequisiteTargets,
        quiz,
        linkToComplete,
        sortIndex,
        Live,
      );
    Notification.success("Success", "Target updated successfully");
    updateTargetCB(newTarget, []);
  };
  let createTarget = () => {
    dispatch(UpdateSaving);
    let payload = setPayload(state, target, authenticityToken);
    let tgId = targetGroupId;
    let url = "/school/target_groups/" ++ tgId ++ "/targets";
    Api.create(url, payload, handleResponseCB, handleErrorCB);
  };

  let updateTarget = targetId => {
    dispatch(UpdateSaving);
    let payload = setPayload(state, target, authenticityToken);
    let url = "/school/targets/" ++ targetId;
    Api.update(url, payload, handleResponseCB, handleErrorCB);
  };
  let showPrerequisiteTargets = state.prerequisiteTargets |> List.length > 0;
  <div>
    <div className="blanket" />
    <div className="drawer-right drawer-right-large">
      <div className="drawer-right__close absolute">
        <button
          title="close"
          onClick={_ => hideEditorActionCB()}
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <i className="fal fa-times text-xl" />
        </button>
      </div>
      <div className={formClasses(state.saving)}>
        <div className="w-full">
          <ul className="flex flex-wrap max-w-3xl mx-auto mt-4 px-3">
            <li
              onClick={_event => dispatch(UpdateActiveStep(AddContent))}
              className="w-1/2 border border-b-0 bg-white rounded-tl-lg p-3 text-center font-semibold text-primary-500">
              {"1. Add Content" |> str}
            </li>
            <li
              onClick={_event => dispatch(UpdateActiveStep(TargetActions))}
              className="w-1/2 mr-auto border border-b-0 bg-white rounded-tr-lg p-3 text-center font-semibold -ml-px">
              {"2. Method of Completion" |> str}
            </li>
          </ul>
          {
            switch (state.activeStep) {
            | AddContent =>
              <div className="mx-auto bg-white border-t">
                <div className="max-w-3xl py-6 px-3 mx-auto">
                  <label
                    className="inline-block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                    htmlFor="title">
                    {"Title" |> str}
                  </label>
                  <span> {"*" |> str} </span>
                  <input
                    className="appearance-none block w-full bg-white text-2xl font-semibold text-gray-900 border-b border-gray-400 pb-2 mb-6 leading-tight hover:border-gray-500 focus:outline-none focus:bg-white focus:border-gray-500"
                    id="title"
                    type_="text"
                    placeholder="Type target title here"
                    value={state.title}
                    onChange=(
                      event =>
                        updateTitle(
                          dispatch,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  {
                    state.hasTitleError ?
                      <div className="drawer-right-form__error-msg">
                        {"not a valid title" |> str}
                      </div> :
                      ReasonReact.null
                  }
                  <CurriculumEditor__TargetContentEditor
                    key={target |> Target.id}
                    target
                    contentBlocks={state.contentBlocks}
                    updateContentBlockDeletionCB
                    authenticityToken
                  />
                </div>
              </div>
            | TargetActions =>
              <div className="mx-auto bg-white border-t">
                <div className="max-w-3xl py-6 px-3 mx-auto">
                  {
                    showPrerequisiteTargets ?
                      <div>
                        <label
                          className="block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                          htmlFor="prerequisite_targets">
                          {"Any prerequisite targets?" |> str}
                        </label>
                        <div id="prerequisite_targets" className="mb-6">
                          <School__SelectBox
                            items={state.prerequisiteTargets}
                            multiSelectCB=multiSelectPrerequisiteTargetsCB
                          />
                        </div>
                      </div> :
                      ReasonReact.null
                  }
                  <div className="flex items-center mb-6">
                    <label
                      className="block tracking-wide text-gray-800 text-xs font-semibold mr-6"
                      htmlFor="evaluated">
                      {"Is this target reviewed by a faculty?" |> str}
                    </label>
                    <div
                      id="evaluated"
                      className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden">
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            dispatch(UpdateMethodOfCompletion(Evaluated));
                          }
                        )
                        className={
                          booleanButtonClasses(
                            state.methodOfCompletion == Evaluated,
                          )
                        }>
                        {"Yes" |> str}
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            dispatch(
                              UpdateMethodOfCompletion(MarkAsComplete),
                            );
                          }
                        )
                        className={booleanButtonClasses(!targetEvaluated())}>
                        {"No" |> str}
                      </button>
                    </div>
                  </div>
                  {
                    targetEvaluated() ?
                      ReasonReact.null :
                      <div>
                        <div className="mb-6">
                          <label
                            className="block tracking-wide text-gray-800 text-xs font-semibold mr-6 mb-3"
                            htmlFor="method_of_completion">
                            {
                              "How do you want the student to complete the target?"
                              |> str
                            }
                          </label>
                          <div
                            id="method_of_completion" className="flex -mx-2">
                            <div className="w-1/3 px-2">
                              <button
                                onClick=(
                                  _event => {
                                    ReactEvent.Mouse.preventDefault(_event);
                                    dispatch(
                                      UpdateMethodOfCompletion(
                                        MarkAsComplete,
                                      ),
                                    );
                                  }
                                )
                                className={
                                  completionButtonClasses(
                                    state.methodOfCompletion == MarkAsComplete,
                                  )
                                }>
                                <div className="mb-1">
                                  <img className="w-12 h-12" src=markIcon />
                                </div>
                                {"Simply mark the target as completed." |> str}
                              </button>
                            </div>
                            <div className="w-1/3 px-2">
                              <button
                                onClick=(
                                  _event => {
                                    ReactEvent.Mouse.preventDefault(_event);
                                    dispatch(
                                      UpdateMethodOfCompletion(VisitLink),
                                    );
                                  }
                                )
                                className={
                                  completionButtonClasses(
                                    state.methodOfCompletion == VisitLink,
                                  )
                                }>
                                <div className="mb-1">
                                  <img className="w-12 h-12" src=linkIcon />
                                </div>
                                {"Visit a link to complete the target." |> str}
                              </button>
                            </div>
                            <div className="w-1/3 px-2">
                              <button
                                onClick=(
                                  _event => {
                                    ReactEvent.Mouse.preventDefault(_event);
                                    dispatch(
                                      UpdateMethodOfCompletion(TakeQuiz),
                                    );
                                  }
                                )
                                className={
                                  completionButtonClasses(
                                    state.methodOfCompletion == TakeQuiz,
                                  )
                                }>
                                <div className="mb-1">
                                  <img className="w-12 h-12" src=quizIcon />
                                </div>
                                {"Take a quiz to complete the target." |> str}
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                  }
                  {
                    switch (state.methodOfCompletion) {
                    | Evaluated =>
                      <div id="evaluation_criteria" className="mb-6">
                        <label
                          className="block tracking-wide text-gray-800 text-xs font-semibold mr-6 mb-2"
                          htmlFor="evaluation_criteria">
                          {"Choose evaluation criteria from your list" |> str}
                        </label>
                        {
                          validNumberOfEvaluationCriteria ?
                            ReasonReact.null :
                            <div className="drawer-right-form__error-msg">
                              {"Atleast one has to be selected" |> str}
                            </div>
                        }
                        <School__SelectBox
                          items={state.evaluationCriteria}
                          multiSelectCB=multiSelectEvaluationCriterionCB
                        />
                      </div>
                    | MarkAsComplete => ReasonReact.null
                    | TakeQuiz =>
                      <div>
                        <h3
                          className="block tracking-wide text-gray-800 font-semibold mb-2"
                          htmlFor="Quiz question 1">
                          {"Prepare the quiz now." |> str}
                        </h3>
                        {
                          state.isValidQuiz ?
                            ReasonReact.null :
                            <div className="drawer-right-form__error-msg">
                              {
                                "All questions must be filled in, and all questions should have at least two answers."
                                |> str
                              }
                            </div>
                        }
                        {
                          state.quiz
                          |> List.mapi((index, quizQuestion) =>
                               <CurriculumEditor__TargetQuizQuestion
                                 key={
                                   quizQuestion
                                   |> QuizQuestion.id
                                 }
                                 questionNumber=index
                                 quizQuestion
                                 updateQuizQuestionCB
                                 removeQuizQuestionCB
                                 questionCanBeRemoved
                               />
                             )
                          |> Array.of_list
                          |> ReasonReact.array
                        }
                        <a
                          onClick=(
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              dispatch(AddQuizQuestion);
                            }
                          )
                          className="flex items-center bg-gray-200 hover:bg-gray-400 border-2 border-dashed rounded-lg p-3 cursor-pointer mb-5">
                          <i className="far fa-plus-circle text-lg" />
                          <h5 className="font-semibold ml-2">
                            {"Add another Question" |> str}
                          </h5>
                        </a>
                      </div>
                    | VisitLink =>
                      <div>
                        <label
                          className="inline-block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                          htmlFor="link_to_complete">
                          {"Link to complete" |> str}
                        </label>
                        <span> {"*" |> str} </span>
                        <input
                          className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                          id="link_to_complete"
                          type_="text"
                          placeholder="Paste link to complete"
                          value={state.linkToComplete}
                          onChange=(
                            event =>
                              updateLinkToComplete(
                                dispatch,
                                ReactEvent.Form.target(event)##value,
                              )
                          )
                        />
                        {
                          state.hasLinktoCompleteError ?
                            <div className="drawer-right-form__error-msg">
                              {"not a valid link" |> str}
                            </div> :
                            ReasonReact.null
                        }
                      </div>
                    | NotSelected => ReasonReact.null
                    }
                  }
                </div>
              </div>
            }
          }
          <div className="bg-white py-6">
            <div
              className="flex max-w-3xl w-full justify-between items-center px-3 mx-auto">
              {
                switch (state.activeStep) {
                | TargetActions =>
                  <div className="flex items-center flex-shrink-0">
                    <label
                      className="block tracking-wide text-gray-800 text-xs font-semibold mr-3"
                      htmlFor="archived">
                      {"Target Visibility" |> str}
                    </label>
                    <div
                      id="visibility"
                      className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden">
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            dispatch(UpdateVisibility(Live));
                          }
                        )
                        className={
                          booleanButtonClasses(state.visibility === Live)
                        }>
                        {"Live" |> str}
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            dispatch(UpdateVisibility(Archived));
                          }
                        )
                        className={
                          booleanButtonClasses(state.visibility === Archived)
                        }>
                        {"Archived" |> str}
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            dispatch(UpdateVisibility(Draft));
                          }
                        )
                        className={
                          booleanButtonClasses(state.visibility === Draft)
                        }>
                        {"Draft" |> str}
                      </button>
                    </div>
                  </div>
                | AddContent => ReasonReact.null
                }
              }
              {
                switch (state.activeStep) {
                | AddContent =>
                  <div className="w-full flex justify-end">
                    <button
                      onClick=(
                        _event => dispatch(UpdateActiveStep(TargetActions))
                      )
                      className="btn btn-large btn-primary">
                      <span className="mr-2"> {"Next Step" |> str} </span>
                      <i className="far fa-arrow-right text-sm" />
                    </button>
                  </div>
                | TargetActions =>
                  <div className="w-auto">
                    <button
                      disabled={saveDisabled(state)}
                      onClick=(_e => updateTarget(target |> Target.id))
                      className="btn btn-primary w-full text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
                      {"Update Target" |> str}
                    </button>
                  </div>
                }
              }
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>;
};

module Jsx2 = {
  let component =
    ReasonReact.statelessComponent("CurriculumEditor__TargetEditor");

  let make =
      (
        ~target,
        ~targetGroupId,
        ~contentBlocks,
        ~evaluationCriteria,
        ~targets,
        ~targetGroupIdsInLevel,
        ~authenticityToken,
        ~updateTargetCB,
        ~hideEditorActionCB,
        ~updateContentBlockDeletionCB,
        _children,
      ) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(
        ~target,
        ~targetGroupId,
        ~contentBlocks,
        ~evaluationCriteria,
        ~targets,
        ~targetGroupIdsInLevel,
        ~authenticityToken,
        ~updateTargetCB,
        ~hideEditorActionCB,
        ~updateContentBlockDeletionCB,
        (),
      ),
      _children,
    );
};
