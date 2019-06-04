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

type evaluationCriterion = (int, string, bool);

type prerequisiteTarget = (int, string, bool);

type resource = (int, string);

type state = {
  title: string,
  evaluationCriteria: list(evaluationCriterion),
  prerequisiteTargets: list(prerequisiteTarget),
  methodOfCompletion,
  quiz: list(QuizQuestion.t),
  linkToComplete: string,
  role: string,
  targetActionType: string,
  hasTitleError: bool,
  hasDescriptionError: bool,
  hasYoutubeVideoIdError: bool,
  hasLinktoCompleteError: bool,
  isValidQuiz: bool,
  isArchived: bool,
  dirty: bool,
  saving: bool,
  activeStep: int,
};

type action =
  | UpdateTitle(string, bool)
  | UpdateLinkToComplete(string, bool)
  | UpdateEvaluationCriterion(int, string, bool)
  | UpdatePrerequisiteTargets(int, string, bool)
  | UpdateMethodOfCompletion(methodOfCompletion)
  | AddQuizQuestion
  | UpdateQuizQuestion(int, QuizQuestion.t)
  | RemoveQuizQuestion(int)
  | UpdateIsArchived(bool)
  | UpdateSaving
  | UpdateActiveStep(int);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetEditor");

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
  || state.hasYoutubeVideoIdError
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
  |> List.filter(target => !(target |> Target.visibility === "archived"));

let handleEC = (evaluationCriteria, target) => {
  let selectedEcIds = target |> Target.evaluationCriteria |> Array.of_list;

  evaluationCriteria
  |> List.map(criterion => {
       let criterionId = criterion |> EvaluationCriteria.id;
       let selected =
         selectedEcIds
         |> Js.Array.findIndex(selectedCriterionId =>
              criterionId == selectedCriterionId
            )
         > (-1);
       (
         criterion |> EvaluationCriteria.id,
         criterion |> EvaluationCriteria.name,
         selected,
       );
     });
};

let handlePT = (targets, target) => {
  let selectedEcIds = target |> Target.prerequisiteTargets |> Array.of_list;

  targets
  |> Target.removeTarget(target)
  |> List.map(criterion => {
       let criterionId = criterion |> Target.id;
       let selected =
         selectedEcIds
         |> Js.Array.findIndex(selectedCriterionId =>
              criterionId == selectedCriterionId
            )
         > (-1);
       (criterion |> Target.id, criterion |> Target.title, selected);
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

  switch (target) {
  | Some(target) =>
    Js.Dict.set(
      targetData,
      "sort_index",
      target |> Target.sortIndex |> string_of_int |> Js.Json.string,
    )
  | None => ()
  };
  Js.Dict.set(targetData, "role", state.role |> Js.Json.string);
  Js.Dict.set(
    targetData,
    "target_action_type",
    state.targetActionType |> Js.Json.string,
  );
  Js.Dict.set(targetData, "title", state.title |> Js.Json.string);

  Js.Dict.set(
    targetData,
    "prerequisite_target_ids",
    prerequisiteTargetIds |> Json.Encode.(list(int)),
  );

  Js.Dict.set(targetData, "archived", state.isArchived |> Js.Json.boolean);

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
  quiz |> List.length > 0 ? quiz : [QuizQuestion.empty(0)];
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
    "flex flex-col items-center bg-white border border-gray-400 hover:bg-gray-200-green text-sm font-semibold focus:outline-none rounded p-4" :
    "flex flex-col items-center bg-white border border-gray-400 opacity-50 hover:bg-gray-200 text-gray-900 text-sm font-semibold focus:outline-none rounded p-4";
let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full";
let make =
    (
      ~target,
      ~targetGroupId,
      ~evaluationCriteria,
      ~targets,
      ~targetGroupIdsInLevel,
      ~authenticityToken,
      ~updateTargetCB,
      ~hideEditorActionCB,
      _children,
    ) => {
  ...component,
  initialState: () =>
    switch (target) {
    | Some(target) => {
        title: target |> Target.title,
        evaluationCriteria: handleEC(evaluationCriteria, target),
        prerequisiteTargets:
          handlePT(eligibleTargets(targets, targetGroupIdsInLevel), target),
        quiz: handleQuiz(target),
        linkToComplete:
          switch (target |> Target.linkToComplete) {
          | Some(linkToComplete) => linkToComplete
          | None => ""
          },
        role: target |> Target.role,
        targetActionType: target |> Target.targetActionType,
        methodOfCompletion: handleMethodOfCompletion(target),
        hasTitleError: false,
        hasDescriptionError: false,
        hasYoutubeVideoIdError: false,
        hasLinktoCompleteError: false,
        isArchived: target |> Target.visibility === "archived",
        dirty: false,
        isValidQuiz: true,
        saving: false,
        activeStep: 1,
      }
    | None => {
        title: "",
        evaluationCriteria:
          evaluationCriteria
          |> List.map(criteria =>
               (
                 criteria |> EvaluationCriteria.id,
                 criteria |> EvaluationCriteria.name,
                 true,
               )
             ),
        prerequisiteTargets:
          eligibleTargets(targets, targetGroupIdsInLevel)
          |> List.map(_target =>
               (_target |> Target.id, _target |> Target.title, false)
             ),
        quiz: [QuizQuestion.empty(0)],
        methodOfCompletion: NotSelected,
        linkToComplete: "",
        role: "founder",
        targetActionType: "Todo",
        hasTitleError: false,
        hasDescriptionError: false,
        hasYoutubeVideoIdError: false,
        hasLinktoCompleteError: false,
        isArchived: false,
        dirty: false,
        isValidQuiz: true,
        saving: false,
        activeStep: 1,
      }
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateTitle(title, hasTitleError) =>
      ReasonReact.Update({...state, title, hasTitleError, dirty: true})
    | UpdateLinkToComplete(linkToComplete, hasLinktoCompleteError) =>
      ReasonReact.Update({
        ...state,
        linkToComplete,
        hasLinktoCompleteError,
        dirty: true,
      })
    | UpdateEvaluationCriterion(key, value, selected) =>
      let oldEC =
        state.evaluationCriteria
        |> List.filter(((item, _, _)) => item !== key);
      ReasonReact.Update({
        ...state,
        evaluationCriteria: [(key, value, selected), ...oldEC],
        dirty: true,
      });
    | UpdatePrerequisiteTargets(key, value, selected) =>
      let oldPT =
        state.prerequisiteTargets
        |> List.filter(((item, _, _)) => item !== key);
      ReasonReact.Update({
        ...state,
        prerequisiteTargets: [(key, value, selected), ...oldPT],
        dirty: true,
      });
    | UpdateMethodOfCompletion(methodOfCompletion) =>
      ReasonReact.Update({...state, methodOfCompletion, dirty: true})
    | AddQuizQuestion =>
      let lastQuestionId =
        state.quiz |> List.rev |> List.hd |> QuizQuestion.id;

      let quiz =
        state.quiz
        |> List.rev
        |> List.append([QuizQuestion.empty(lastQuestionId + 1)])
        |> List.rev;
      ReasonReact.Update({
        ...state,
        quiz,
        dirty: true,
        isValidQuiz: isValidQuiz(quiz),
      });
    | UpdateQuizQuestion(id, quizQuestion) =>
      let quiz =
        state.quiz
        |> List.map(a => a |> QuizQuestion.id == id ? quizQuestion : a);
      ReasonReact.Update({
        ...state,
        quiz,
        dirty: true,
        isValidQuiz: isValidQuiz(quiz),
      });

    | RemoveQuizQuestion(id) =>
      let quiz = state.quiz |> List.filter(a => a |> QuizQuestion.id !== id);
      ReasonReact.Update({
        ...state,
        quiz,
        dirty: true,
        isValidQuiz: isValidQuiz(quiz),
      });
    | UpdateIsArchived(isArchived) =>
      ReasonReact.Update({...state, isArchived, dirty: true})
    | UpdateSaving => ReasonReact.Update({...state, saving: !state.saving})
    | UpdateActiveStep(step) =>
      ReasonReact.Update({...state, activeStep: step})
    },
  render: ({state, send}) => {
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
      send(UpdatePrerequisiteTargets(key, value, selected));
    let multiSelectEvaluationCriterionCB = (key, value, selected) =>
      send(UpdateEvaluationCriterion(key, value, selected));
    let removeQuizQuestionCB = id => send(RemoveQuizQuestion(id));
    let updateQuizQuestionCB = (id, quizQuestion) =>
      send(UpdateQuizQuestion(id, quizQuestion));
    let questionCanBeRemoved = state.quiz |> List.length > 1;
    let handleErrorCB = () => send(UpdateSaving);
    let handleResponseCB = json => {
      let id = json |> Json.Decode.(field("id", int));
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
          state.role,
          state.targetActionType,
          sortIndex,
          "live",
        );
      switch (target) {
      | Some(_) =>
        Notification.success("Success", "Target updated successfully")
      | None => Notification.success("Success", "Target created successfully")
      };
      updateTargetCB(newTarget);
    };
    let createTarget = () => {
      send(UpdateSaving);
      let payload = setPayload(state, target, authenticityToken);
      let tgId = targetGroupId |> string_of_int;
      let url = "/school/target_groups/" ++ tgId ++ "/targets";
      Api.create(url, payload, handleResponseCB, handleErrorCB);
    };

    let updateTarget = targetId => {
      send(UpdateSaving);
      let payload = setPayload(state, target, authenticityToken);
      let url = "/school/targets/" ++ (targetId |> string_of_int);
      Api.update(url, payload, handleResponseCB, handleErrorCB);
    };
    let showPrerequisiteTargets = state.prerequisiteTargets |> List.length > 0;
    <div>
      <div className="blanket" />
      <div className="drawer-right">
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
            <ul className="flex">
              <li
                onClick={_event => send(UpdateActiveStep(1))}
                className="w-1/2 border p-3 text-center font-semibold text-primary-500">
                {"1. Create Lesson" |> str}
              </li>
              <li
                onClick={_event => send(UpdateActiveStep(2))}
                className="w-1/2 border p-3 text-center font-semibold -ml-px">
                {"2. Method of Completion" |> str}
              </li>
            </ul>
            {
              state.activeStep === 1 ?
                <div className="mx-auto bg-white">
                  <div className="max-w-2xl p-6 mx-auto">
                    <h5
                      className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                      {"Target Details" |> str}
                    </h5>
                    <label
                      className="inline-block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                      htmlFor="title">
                      {"Title" |> str}
                    </label>
                    <span> {"*" |> str} </span>
                    <input
                      className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                      id="title"
                      type_="text"
                      placeholder="Type target title here"
                      value={state.title}
                      onChange={
                        event =>
                          updateTitle(
                            send,
                            ReactEvent.Form.target(event)##value,
                          )
                      }
                    />
                    {
                      state.hasTitleError ?
                        <div className="drawer-right-form__error-msg">
                          {"not a valid title" |> str}
                        </div> :
                        ReasonReact.null
                    }
                  </div>
                </div> :
                ReasonReact.null
            }
            {
              state.activeStep === 2 ?
                <div className="mx-auto">
                  <div className="max-w-2xl p-6 mx-auto">
                    <h5
                      className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                      {"Method of Target Completion" |> str}
                    </h5>
                    {
                      showPrerequisiteTargets ?
                        <div>
                          <label
                            className="block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                            htmlFor="prerequisite_targets">
                            {"Any prerequisite targets?" |> str}
                          </label>
                          <div id="prerequisite_targets" className="mb-6">
                            <CurriculumEditor__SelectBox
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
                        className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden border">
                        <button
                          onClick={
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              send(UpdateMethodOfCompletion(Evaluated));
                            }
                          }
                          className={
                            booleanButtonClasses(
                              state.methodOfCompletion == Evaluated,
                            )
                          }>
                          {"Yes" |> str}
                        </button>
                        <button
                          onClick={
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              send(UpdateMethodOfCompletion(MarkAsComplete));
                            }
                          }
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
                                  onClick={
                                    _event => {
                                      ReactEvent.Mouse.preventDefault(_event);
                                      send(
                                        UpdateMethodOfCompletion(
                                          MarkAsComplete,
                                        ),
                                      );
                                    }
                                  }
                                  className={
                                    completionButtonClasses(
                                      state.methodOfCompletion
                                      == MarkAsComplete,
                                    )
                                  }>
                                  <div className="mb-1">
                                    <img className="w-12 h-12" src=markIcon />
                                  </div>
                                  {
                                    "Simply mark the target as completed."
                                    |> str
                                  }
                                </button>
                              </div>
                              <div className="w-1/3 px-2">
                                <button
                                  onClick={
                                    _event => {
                                      ReactEvent.Mouse.preventDefault(_event);
                                      send(
                                        UpdateMethodOfCompletion(VisitLink),
                                      );
                                    }
                                  }
                                  className={
                                    completionButtonClasses(
                                      state.methodOfCompletion == VisitLink,
                                    )
                                  }>
                                  <div className="mb-1">
                                    <img className="w-12 h-12" src=linkIcon />
                                  </div>
                                  {
                                    "Visit a link to complete the target."
                                    |> str
                                  }
                                </button>
                              </div>
                              <div className="w-1/3 px-2">
                                <button
                                  onClick={
                                    _event => {
                                      ReactEvent.Mouse.preventDefault(_event);
                                      send(
                                        UpdateMethodOfCompletion(TakeQuiz),
                                      );
                                    }
                                  }
                                  className={
                                    completionButtonClasses(
                                      state.methodOfCompletion == TakeQuiz,
                                    )
                                  }>
                                  <div className="mb-1">
                                    <img className="w-12 h-12" src=quizIcon />
                                  </div>
                                  {
                                    "Take a quiz to complete the target." |> str
                                  }
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
                            {
                              "Choose evaluation criteria from your list" |> str
                            }
                          </label>
                          {
                            validNumberOfEvaluationCriteria ?
                              ReasonReact.null :
                              <div className="drawer-right-form__error-msg">
                                {"Atleast one has to be selected" |> str}
                              </div>
                          }
                          <CurriculumEditor__SelectBox
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
                                     |> string_of_int
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
                                send(AddQuizQuestion);
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
                            className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                            id="link_to_complete"
                            type_="text"
                            placeholder="Paste link to complete"
                            value={state.linkToComplete}
                            onChange=(
                              event =>
                                updateLinkToComplete(
                                  send,
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
                </div> :
                ReasonReact.null
            }
            <div className="bg-white py-6">
              <div
                className="flex max-w-2xl w-full justify-between items-center px-6 mx-auto">
                {
                  switch (target) {
                  | Some(_) =>
                    <div className="flex items-center flex-shrink-0">
                      <label
                        className="block tracking-wide text-gray-800 text-xs font-semibold mr-3"
                        htmlFor="archived">
                        {"Is this target archived?" |> str}
                      </label>
                      <div
                        id="archived"
                        className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden border">
                        <button
                          onClick=(
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              send(UpdateIsArchived(true));
                            }
                          )
                          className={
                            booleanButtonClasses(state.isArchived == true)
                          }>
                          {"Yes" |> str}
                        </button>
                        <button
                          onClick=(
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              send(UpdateIsArchived(false));
                            }
                          )
                          className={
                            booleanButtonClasses(state.isArchived == false)
                          }>
                          {"No" |> str}
                        </button>
                      </div>
                    </div>
                  | None => ReasonReact.null
                  }
                }
                {
                  switch (target) {
                  | Some(target) =>
                    <div className="w-auto">
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(_e => updateTarget(target |> Target.id))
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
                        {"Update Target" |> str}
                      </button>
                    </div>

                  | None =>
                    <div className="w-full">
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(_e => createTarget())
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 shadow rounded focus:outline-none mt-3">
                        {"Create Target" |> str}
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
  },
};