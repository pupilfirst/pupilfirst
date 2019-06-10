[@bs.config {jsx: 3}];

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

type visibility =
  | Live
  | Draft
  | Archived;

type activeStep =
  | AddContent
  | TargetActions;

type evaluationCriterion = (int, string, bool);

type prerequisiteTarget = (int, string, bool);

type resource = (int, string);

let updateTitle = (setTitle, setHasTitleError, title) => {
  let hasError = title |> String.length < 2;
  setTitle(_ => title);
  setHasTitleError(_ => hasError);
};
let updateLinkToComplete =
    (setLinkToComplete, setHasLinkToCompleteError, link) => {
  let hasError = UrlUtils.isInvalid(link);
  setLinkToComplete(_ => link);
  setHasLinkToCompleteError(_ => hasError);
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

let handleQuiz = target => {
  let quiz = target |> Target.quiz;
  quiz |> List.length > 0 ? quiz : [QuizQuestion.empty(0)];
};

let quizValid = quiz =>
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

[@react.component]
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
    ) => {
  let (title, setTitle) =
    React.useState(() =>
      switch (target) {
      | Some(target) => target |> Target.title
      | None => ""
      }
    );
  let (saving, setSaving) = React.useState(() => false);
  let (activeStep, setActiveStep) = React.useState(() => AddContent);
  let (visibility, setVisibility) =
    React.useState(() =>
      switch (target) {
      | Some(target) => target |> Target.visibility
      | None => Draft
      }
    );
  let (evaluationCriteria, setEvaluationCriteria) =
    React.useState(() =>
      switch (target) {
      | Some(target) => handleEC(evaluationCriteria, target)
      | None =>
        evaluationCriteria
        |> List.map(criteria =>
             (
               criteria |> EvaluationCriteria.id,
               criteria |> EvaluationCriteria.name,
               true,
             )
           )
      }
    );

  let (prerequisiteTargets, setPrerequisiteTargets) =
    React.useState(() =>
      switch (target) {
      | Some(target) =>
        handlePT(eligibleTargets(targets, targetGroupIdsInLevel), target)
      | None =>
        eligibleTargets(targets, targetGroupIdsInLevel)
        |> List.map(_target =>
             (_target |> Target.id, _target |> Target.title, false)
           )
      }
    );
  let (quiz, setQuiz) =
    React.useState(() =>
      switch (target) {
      | Some(target) => handleQuiz(target)
      | None => [QuizQuestion.empty(0)]
      }
    );

  let (linkToComplete, setLinkToComplete) =
    React.useState(() =>
      switch (target) {
      | Some(target) =>
        switch (target |> Target.linkToComplete) {
        | Some(linkToComplete) => linkToComplete
        | None => ""
        }
      | None => ""
      }
    );

  let (methodOfCompletion, setMethodOfCompletion) =
    React.useState(() =>
      switch (target) {
      | Some(target) => handleMethodOfCompletion(target)
      | None => NotSelected
      }
    );

  let (hasTitleError, setHasTitleError) = React.useState(() => false);
  let (hasLinkToCompleteError, setHasLinkToCompleteError) =
    React.useState(() => false);
  let (dirty, setDirty) = React.useState(() => false);
  let (isValidQuiz, setIsValidQuiz) = React.useState(() => true);
  let saveDisabled = () => {
    let hasMethordOfCompletionError =
      switch (methodOfCompletion) {
      | NotSelected => true
      | Evaluated =>
        evaluationCriteria
        |> List.filter(((_, _, selected)) => selected)
        |> List.length == 0
      | VisitLink => hasLinkToCompleteError
      | TakeQuiz => !isValidQuiz
      | MarkAsComplete => false
      };
    title
    |> String.length < 2
    || hasLinkToCompleteError
    || hasMethordOfCompletionError
    || !dirty
    || saving;
  };

  let targetEvaluated = () =>
    switch (methodOfCompletion) {
    | NotSelected => true
    | Evaluated => true
    | VisitLink => false
    | TakeQuiz => false
    | MarkAsComplete => false
    };

  let validNumberOfEvaluationCriteria =
    evaluationCriteria
    |> List.filter(((_, _, selected)) => selected)
    |> List.length != 0;

  let multiSelectPrerequisiteTargetsCB = (key, value, selected) => {
    let oldPT =
      prerequisiteTargets |> List.filter(((item, _, _)) => item !== key);
    setPrerequisiteTargets(_ => [(key, value, selected), ...oldPT]);
    setDirty(_ => true);
  };
  let multiSelectEvaluationCriterionCB = (key, value, selected) => {
    let oldEC =
      evaluationCriteria |> List.filter(((item, _, _)) => item !== key);
    setEvaluationCriteria(_ => [(key, value, selected), ...oldEC]);
    setDirty(_ => true);
  };
  let removeQuizQuestionCB = id => {
    let quiz = quiz |> List.filter(a => a |> QuizQuestion.id !== id);
    setQuiz(_ => quiz);
    setDirty(_ => true);
    setIsValidQuiz(_ => quizValid(quiz));
  };
  let updateQuizQuestionCB = (id, quizQuestion) => {
    let quiz =
      quiz |> List.map(a => a |> QuizQuestion.id == id ? quizQuestion : a);
    setQuiz(_ => quiz);
    setDirty(_ => true);
    setIsValidQuiz(_ => quizValid(quiz));
  };
  let questionCanBeRemoved = quiz |> List.length > 1;
  let handleErrorCB = () => setSaving(_ => !saving);
  let handleResponseCB = json => {
    let id = json |> Json.Decode.(field("id", int));
    let sortIndex = json |> Json.Decode.(field("sortIndex", int));
    let prerequisiteTargets =
      prerequisiteTargets
      |> List.filter(((_, _, selected)) => selected)
      |> List.map(((id, _, _)) => id);

    let evaluationCriteria =
      switch (methodOfCompletion) {
      | Evaluated =>
        evaluationCriteria
        |> List.filter(((_, _, selected)) => selected)
        |> List.map(((id, _, _)) => id)
      | _ => []
      };
    let linkToComplete =
      switch (methodOfCompletion) {
      | VisitLink => Some(linkToComplete)
      | _ => None
      };
    let quiz =
      switch (methodOfCompletion) {
      | TakeQuiz => quiz
      | _ => []
      };
    let newTarget =
      Target.create(
        id,
        targetGroupId,
        title,
        evaluationCriteria,
        prerequisiteTargets,
        quiz,
        linkToComplete,
        sortIndex,
        Live,
      );
    switch (target) {
    | Some(_) =>
      Notification.success("Success", "Target updated successfully")
    | None => Notification.success("Success", "Target created successfully")
    };
    updateTargetCB(newTarget);
  };
  let createTarget = () => setSaving(_ => !saving);

  let updateTarget = targetId => setSaving(_ => !saving);
  let showPrerequisiteTargets = prerequisiteTargets |> List.length > 0;
  let addQuizQuestion = quiz => {
    let lastQuestionId = quiz |> List.rev |> List.hd |> QuizQuestion.id;
    let quiz =
      quiz
      |> List.rev
      |> List.append([QuizQuestion.empty(lastQuestionId + 1)])
      |> List.rev;
    setQuiz(_ => quiz);
    setIsValidQuiz(_ => quizValid(quiz));
    setDirty(_ => true);
  };
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
      <div className={formClasses(saving)}>
        <div className="w-full">
          <ul className="flex flex-wrap max-w-3xl mx-auto mt-4 px-3">
            <li
              onClick={_event => setActiveStep(_ => AddContent)}
              className="w-1/2 border border-b-0 bg-white rounded-tl-lg p-3 text-center font-semibold text-primary-500">
              {"1. Add Content" |> str}
            </li>
            <li
              onClick={_event => setActiveStep(_ => TargetActions)}
              className="w-1/2 mr-auto border border-b-0 bg-white rounded-tr-lg p-3 text-center font-semibold -ml-px">
              {"2. Method of Completion" |> str}
            </li>
          </ul>
          {
            switch (activeStep) {
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
                    className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                    id="title"
                    type_="text"
                    placeholder="Type target title here"
                    value=title
                    onChange=(
                      event =>
                        updateTitle(
                          setTitle,
                          setHasTitleError,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  {
                    hasTitleError ?
                      <div className="drawer-right-form__error-msg">
                        {"not a valid title" |> str}
                      </div> :
                      ReasonReact.null
                  }
                  <MarkDownEditor updateDescriptionCB value="description" />
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
                            items=prerequisiteTargets
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
                            setMethodOfCompletion(_ => Evaluated);
                            setDirty(_ => true);
                          }
                        )
                        className={
                          booleanButtonClasses(
                            methodOfCompletion == Evaluated,
                          )
                        }>
                        {"Yes" |> str}
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            setMethodOfCompletion(_ => MarkAsComplete);
                            setDirty(_ => true);
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
                                    setMethodOfCompletion(_ => MarkAsComplete);
                                    setDirty(_ => true);
                                  }
                                )
                                className={
                                  completionButtonClasses(
                                    methodOfCompletion == MarkAsComplete,
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
                                    setMethodOfCompletion(_ => VisitLink);
                                    setDirty(_ => true);
                                  }
                                )
                                className={
                                  completionButtonClasses(
                                    methodOfCompletion == VisitLink,
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
                                    setMethodOfCompletion(_ => TakeQuiz);
                                    setDirty(_ => true);
                                  }
                                )
                                className={
                                  completionButtonClasses(
                                    methodOfCompletion == TakeQuiz,
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
                    switch (methodOfCompletion) {
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
                          items=evaluationCriteria
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
                          isValidQuiz ?
                            ReasonReact.null :
                            <div className="drawer-right-form__error-msg">
                              {
                                "All questions must be filled in, and all questions should have at least two answers."
                                |> str
                              }
                            </div>
                        }
                        {
                          quiz
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
                              addQuizQuestion(quiz);
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
                          value=linkToComplete
                          onChange=(
                            event =>
                              updateLinkToComplete(
                                setLinkToComplete,
                                setHasLinkToCompleteError,
                                ReactEvent.Form.target(event)##value,
                              )
                          )
                        />
                        {
                          hasLinkToCompleteError ?
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
              className="flex max-w-3xl w-full justify-between items-center px-6 mx-auto">
              {
                switch (activeStep) {
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
                            setVisibility(_ => Live);
                          }
                        )
                        className={booleanButtonClasses(visibility === Live)}>
                        {"Live" |> str}
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            setVisibility(_ => Archived);
                          }
                        )
                        className={
                          booleanButtonClasses(visibility === Archived)
                        }>
                        {"Archived" |> str}
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            setVisibility(_ => Draft);
                          }
                        )
                        className={booleanButtonClasses(visibility === Draft)}>
                        {"Draft" |> str}
                      </button>
                    </div>
                  </div>
                | AddContent => ReasonReact.null
                }
              }
              {
                switch (activeStep) {
                | AddContent =>
                  <div className="w-auto">
                    <button
                      onClick=(_event => setActiveStep(_ => TargetActions))
                      className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
                      {"Next Step" |> str}
                    </button>
                  </div>
                | TargetActions =>
                  switch (target) {
                  | Some(target) =>
                    <div className="w-auto">
                      <button
                        disabled={saveDisabled()}
                        onClick=(_e => updateTarget(target |> Target.id))
                        className="btn btn-primary w-full text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
                        {"Update Target" |> str}
                      </button>
                    </div>

                  | None =>
                    <div className="w-full">
                      <button
                        disabled={saveDisabled()}
                        onClick=(_e => createTarget())
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 shadow rounded focus:outline-none mt-3">
                        {"Create Target" |> str}
                      </button>
                    </div>
                  }
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
        ~evaluationCriteria,
        ~targets,
        ~targetGroupIdsInLevel,
        ~authenticityToken,
        ~updateTargetCB,
        ~hideEditorActionCB,
        _children,
      ) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(
        ~target,
        ~targetGroupId,
        ~evaluationCriteria,
        ~targets,
        ~targetGroupIdsInLevel,
        ~authenticityToken,
        ~updateTargetCB,
        ~hideEditorActionCB,
        (),
      ),
      _children,
    );
};
