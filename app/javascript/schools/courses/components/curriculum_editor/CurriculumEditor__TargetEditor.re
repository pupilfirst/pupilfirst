[@bs.config {jsx: 3}];

exception SetPayloadCalledWithoutMethodOfCompletion;

[%bs.raw {|require("./CurriculumEditor__TargetEditor.css")|}];

open CurriculumEditor__Types;

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
  contentBlocks: list(ContentBlock.t),
  versions: array(string),
  selectedVersion: string,
  previewMode: bool,
  methodOfCompletion,
  quiz: list(QuizQuestion.t),
  linkToComplete: string,
  hasTitleError: bool,
  hasLinktoCompleteError: bool,
  isValidQuiz: bool,
  dirty: bool,
  saving: bool,
  activeStep,
  visibility: Target.visibility,
  contentEditorDirty: bool,
  completionInstructions: string,
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
  | UpdateVisibility(Target.visibility)
  | UpdateContentEditorDirty(bool)
  | UpdateContentBlocks(list(ContentBlock.t), array(string))
  | SwitchPreviewMode
  | LoadOldVersion(list(ContentBlock.t), string, array(string))
  | SelectVersion(string)
  | UpdateVersions(array(string))
  | UpdateCompletionInstructions(string);

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

let cacheCurrentEvaluationCriteria = (evaluationCriteria, target) => {
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

let cachePrerequisiteTargets = (targets, target) => {
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

let setPayload = (state, authenticityToken) => {
  let payload = Js.Dict.empty();
  let targetData = Js.Dict.empty();

  let prerequisiteTargetIds =
    state.prerequisiteTargets
    |> List.filter(((_, _, selected)) => selected == true)
    |> List.map(((key, _, _)) => key);

  let visibility =
    switch (state.visibility) {
    | Live => "live"
    | Archived => "archived"
    | Draft => "draft"
    };

  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );

  Js.Dict.set(targetData, "title", state.title |> Js.Json.string);

  Js.Dict.set(
    targetData,
    "prerequisite_target_ids",
    prerequisiteTargetIds |> Json.Encode.(list(int)),
  );

  Js.Dict.set(targetData, "visibility", visibility |> Js.Json.string);

  Js.Dict.set(
    targetData,
    "completion_instructions",
    state.completionInstructions |> Js.Json.string,
  );

  let (evaluationCriteriaIds, linkToComplete, quiz) =
    switch (state.methodOfCompletion) {
    | NotSelected =>
      Rollbar.error(
        "TargetEditor.setPayload was called when methodOfCompletion was NotSelected",
      );
      Notification.error(
        "Error!",
        "Something went wrong. Please reload the page before trying again.",
      );
      raise(SetPayloadCalledWithoutMethodOfCompletion);
    | Evaluated =>
      let evaluationCriteriaIds =
        state.evaluationCriteria
        |> List.filter(((_, _, selected)) => selected == true)
        |> List.map(((key, _, _)) => key);

      (evaluationCriteriaIds, "", []);
    | VisitLink => ([], state.linkToComplete, [])
    | TakeQuiz => ([], "", state.quiz)
    | MarkAsComplete => ([], "", [])
    };

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
  classes ++ (bool ? " toggle-button__button--active" : "");
};

let completionButtonClasses = value => {
  let defaultClasses = "target-editor__completion-button relative flex flex-col items-center bg-white border border-gray-400 hover:bg-gray-200 text-sm font-semibold focus:outline-none rounded p-4";
  value ?
    defaultClasses
    ++ " target-editor__completion-button--selected bg-gray-200 text-primary-500 border-primary-500" :
    defaultClasses ++ " opacity-75 text-gray-900";
};

let formClasses = value => {
  let defaultClasses = "drawer-right-form bg-white w-full ";
  value ? defaultClasses ++ "opacity-50" : defaultClasses;
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateTitle(title, hasTitleError) => {...state, title, hasTitleError}
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
      dirty:
        switch (methodOfCompletion) {
        | NotSelected => false
        | VisitLink => state.linkToComplete |> String.length > 0
        | Evaluated
        | TakeQuiz
        | MarkAsComplete => true
        },
    }
  | AddQuizQuestion =>
    let quiz =
      state.quiz
      |> List.rev
      |> List.append([
           QuizQuestion.empty(Js.Date.now() |> Js.Float.toString),
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
  | UpdateVisibility(visibility) => {...state, visibility, dirty: true}
  | UpdateCompletionInstructions(completionInstructions) => {
      ...state,
      completionInstructions,
      dirty: true,
    }
  | UpdateContentEditorDirty(contentEditorDirty) => {
      ...state,
      contentEditorDirty,
    }
  | UpdateContentBlocks(contentBlocks, versions) => {
      ...state,
      contentBlocks,
      versions,
      selectedVersion:
        switch (versions) {
        | [||] => ""
        | versions => versions[0]
        },
      previewMode: contentBlocks |> List.length > 0 ? true : false,
    }
  | LoadOldVersion(contentBlocks, selectedVersion, versions) => {
      ...state,
      contentBlocks,
      selectedVersion,
      versions,
      previewMode: true,
    }
  | SelectVersion(selectedVersion) => {
      ...state,
      selectedVersion,
      previewMode: true,
    }
  | SwitchPreviewMode => {...state, previewMode: !state.previewMode}
  | UpdateVersions(versions) => {
      ...state,
      versions,
      selectedVersion: versions[0],
    }
  };

let handleEditorClosure = (hideEditorActionCB, state) =>
  switch (state.contentEditorDirty || state.dirty) {
  | false => hideEditorActionCB()
  | true =>
    Webapi.Dom.window
    |> Webapi.Dom.Window.confirm(
         " There are unsaved changes! Are you sure you want to close the editor?",
       ) ?
      hideEditorActionCB() : ()
  };

module ContentBlocksQuery = [%graphql
  {|
    query($targetId: ID!, $versionOn: Date ) {
      contentBlocks(targetId: $targetId, versionOn: $versionOn) {
        id
        blockType
        sortIndex
        content {
          ... on ImageBlock {
            caption
            url
            filename
          }
          ... on FileBlock {
            title
            url
            filename
          }
          ... on MarkdownBlock {
            markdown
          }
          ... on EmbedBlock {
            url
            embedCode
          }
        }
      }
      versions(targetId: $targetId)
  }
|}
];

module RestoreContentVersionMutation = [%graphql
  {|
   mutation($targetId: ID!, $versionOn: Date!) {
    restoreContentVersion(targetId: $targetId, versionOn: $versionOn) {
       success
     }
   }
   |}
];

let loadContentBlocks = (target, send, selectedVersion, authenticityToken, ()) => {
  let targetId = target |> Target.id;
  let versionOn = Belt.Option.map(selectedVersion, Js.Json.string);
  let response =
    ContentBlocksQuery.make(~targetId, ~versionOn?, ())
    |> GraphqlQuery.sendQuery(authenticityToken, ~notify=true);
  response
  |> Js.Promise.then_(result => {
       let contentBlocks =
         result##contentBlocks
         |> Js.Array.map(rawContentBlock => {
              let id = rawContentBlock##id;
              let sortIndex = rawContentBlock##sortIndex;
              let blockType =
                switch (rawContentBlock##content) {
                | `MarkdownBlock(content) =>
                  ContentBlock.Markdown(content##markdown)
                | `FileBlock(content) =>
                  File(content##url, content##title, content##filename)
                | `ImageBlock(content) =>
                  Image(content##url, content##caption)
                | `EmbedBlock(content) =>
                  Embed(content##url, content##embedCode)
                };
              ContentBlock.make(id, blockType, sortIndex);
            })
         |> Array.to_list;
       let versions =
         result##versions
         |> Array.map(version => version |> Json.Decode.string);
       switch (versionOn) {
       | Some(versionOn) =>
         send(
           LoadOldVersion(
             contentBlocks,
             versionOn |> Json.Decode.string,
             versions,
           ),
         )
       | None => send(UpdateContentBlocks(contentBlocks, versions))
       };
       Js.Promise.resolve();
     })
  |> ignore;
  None;
};

let currentDateString = () => Js.Date.make() |> DateFns.format("YYYY-MM-DD");

let handleRestoreVersionCB =
    (target, send, state, authenticityToken, versionOn) =>
  Webapi.Dom.window
  |> Webapi.Dom.Window.confirm(
       "Are you sure you want to set this as the current version?",
     ) ?
    {
      let targetId = Target.id(target);
      RestoreContentVersionMutation.make(~targetId, ~versionOn, ())
      |> GraphqlQuery.sendQuery(authenticityToken, ~notify=true)
      |> Js.Promise.then_(response => {
           response##restoreContentVersion##success ?
             send(
               UpdateVersions(
                 Array.append([|currentDateString()|], state.versions),
               ),
             ) :
             ();
           Js.Promise.resolve();
         })
      |> ignore;
    } :
    ();

let addNewVersionCB = (dispatch, versions) =>
  dispatch(UpdateVersions(versions));

let selectVersionCB =
    (target, state, send, authenticityToken, selectedVersion) =>
  selectedVersion == state.versions[0] ?
    loadContentBlocks(target, send, None, authenticityToken, ()) |> ignore :
    (
      switch (state.contentEditorDirty) {
      | false =>
        loadContentBlocks(
          target,
          send,
          Some(selectedVersion),
          authenticityToken,
          (),
        )
      | true =>
        Webapi.Dom.window
        |> Webapi.Dom.Window.confirm(
             "There are unsaved changes in the current version! Are you sure you want to switch version?",
           ) ?
          loadContentBlocks(
            target,
            send,
            Some(selectedVersion),
            authenticityToken,
            (),
          ) :
          None
      }
    )
    |> ignore;

let switchViewModeCB = (send, ()) => send(SwitchPreviewMode);

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
  let initialState = {
    title: target |> Target.title,
    evaluationCriteria:
      cacheCurrentEvaluationCriteria(evaluationCriteria, target),
    prerequisiteTargets:
      cachePrerequisiteTargets(
        eligibleTargets(targets, targetGroupIdsInLevel),
        target,
      ),
    contentBlocks: [],
    versions: [||],
    selectedVersion: "",
    quiz: handleQuiz(target),
    linkToComplete:
      switch (target |> Target.linkToComplete) {
      | Some(linkToComplete) => linkToComplete
      | None => ""
      },
    methodOfCompletion: handleMethodOfCompletion(target),
    hasTitleError: false,
    hasLinktoCompleteError: false,
    previewMode: true,
    dirty: false,
    isValidQuiz: true,
    saving: false,
    activeStep: AddContent,
    visibility: target |> Target.visibility,
    contentEditorDirty: false,
    completionInstructions:
      target |> Target.completionInstructions |> OptionUtils.toString,
  };

  let (state, dispatch) = React.useReducer(reducer, initialState);

  React.useEffect1(
    loadContentBlocks(target, dispatch, None, authenticityToken),
    [|target |> Target.id|],
  );

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
  let updateContentEditorDirtyCB = contentEditorDirty =>
    dispatch(UpdateContentEditorDirty(contentEditorDirty));
  let questionCanBeRemoved = state.quiz |> List.length > 1;
  let handleErrorCB = () => dispatch(UpdateSaving);
  let handleResponseCB = (closeEditor, dispatch, _json) => {
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
        ~id=target |> Target.id,
        ~targetGroupId,
        ~title=state.title,
        ~evaluationCriteria,
        ~prerequisiteTargets,
        ~quiz,
        ~linkToComplete,
        ~sortIndex=target |> Target.sortIndex,
        ~visibility=state.visibility,
        ~completionInstructions=Some(state.completionInstructions),
      );
    Notification.success("Success", "Target updated successfully");
    updateTargetCB(newTarget, closeEditor);
    closeEditor ? () : dispatch(UpdateSaving);
  };

  let updateTarget = (closeEditor, targetId) => {
    dispatch(UpdateSaving);
    let payload = setPayload(state, authenticityToken);
    let url = "/school/targets/" ++ targetId;
    Api.update(
      url,
      payload,
      handleResponseCB(closeEditor, dispatch),
      handleErrorCB,
    );
  };
  let showPrerequisiteTargets = state.prerequisiteTargets |> List.length > 0;
  <div>
    <div className="blanket" />
    <div className="drawer-right drawer-right-large">
      <div className="drawer-right__close absolute">
        <button
          id="target-editor-close"
          title="close"
          onClick={_ => handleEditorClosure(hideEditorActionCB, state)}
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div
        id="target-editor-scroll-container"
        className={formClasses(state.saving)}>
        <div className="w-full">
          <div className="bg-gray-200 w-full pt-6">
            <ul
              className="flex flex-wrap w-full max-w-3xl mx-auto px-3 -mb-px">
              <li
                onClick={_event => dispatch(UpdateActiveStep(AddContent))}
                className={
                  "target-editor__tab-item cursor-pointer "
                  ++ (
                    state.activeStep == AddContent ?
                      "target-editor__tab-item--selected" : ""
                  )
                }>
                <span className="target-editor__tab-item-step-number">
                  {"1" |> str}
                </span>
                <span className="ml-2"> {"Add Content" |> str} </span>
              </li>
              <li
                onClick={_event => dispatch(UpdateActiveStep(TargetActions))}
                className={
                  "target-editor__tab-item cursor-pointer -ml-px "
                  ++ (
                    state.activeStep == TargetActions ?
                      "target-editor__tab-item--selected" : ""
                  )
                }>
                <span className="target-editor__tab-item-step-number">
                  {"2" |> str}
                </span>
                <span className="ml-2"> {"Method of Completion" |> str} </span>
              </li>
            </ul>
          </div>
          <div className="bg-white" id="target-content-and-properties">
            <div
              className={
                "mx-auto bg-white border-t border-gray-400 "
                ++ (
                  switch (state.activeStep) {
                  | AddContent => ""
                  | TargetActions => "hidden"
                  }
                )
              }>
              <div className="max-w-3xl py-6 px-3 mx-auto">
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
                    value={state.title}
                    onChange={
                      event =>
                        updateTitle(
                          dispatch,
                          ReactEvent.Form.target(event)##value,
                        )
                    }
                  />
                  {
                    state.title != (target |> Target.title)
                    && !state.hasTitleError ?
                      <button
                        onClick={
                          _e => updateTarget(false, target |> Target.id)
                        }
                        className="btn btn-success">
                        {"Update" |> str}
                      </button> :
                      React.null
                  }
                </div>
                {
                  state.hasTitleError ?
                    <div className="drawer-right-form__error-msg">
                      {"not a valid title" |> str}
                    </div> :
                    ReasonReact.null
                }
                {
                  state.versions |> Array.length > 0 ?
                    <CurriculumEditor__TargetVersionSelector
                      selectVersionCB={
                        selectVersionCB(
                          target,
                          state,
                          dispatch,
                          authenticityToken,
                        )
                      }
                      versions={state.versions}
                      selectedVersion={state.selectedVersion}
                      previewMode={state.previewMode}
                      switchViewModeCB={switchViewModeCB(dispatch)}
                      handleRestoreVersionCB={
                        handleRestoreVersionCB(
                          target,
                          dispatch,
                          state,
                          authenticityToken,
                        )
                      }
                    /> :
                    React.null
                }
                <CurriculumEditor__TargetContentEditor
                  key={target |> Target.id}
                  target
                  previewMode={state.previewMode}
                  addNewVersionCB={addNewVersionCB(dispatch)}
                  contentBlocks={state.contentBlocks}
                  updateContentEditorDirtyCB
                  authenticityToken
                />
              </div>
            </div>
            <div
              className={
                "mx-auto bg-white border-t border-gray-400 "
                ++ (
                  switch (state.activeStep) {
                  | AddContent => "hidden"
                  | TargetActions => ""
                  }
                )
              }>
              <div className="max-w-3xl py-6 px-3 mx-auto">
                {
                  showPrerequisiteTargets ?
                    <div>
                      <label
                        className="block tracking-wide text-sm font-semibold mb-2"
                        htmlFor="prerequisite_targets">
                        {"Any prerequisite targets?" |> str}
                      </label>
                      <div id="prerequisite_targets" className="mb-6">
                        <School__SelectBox
                          items={
                            state.prerequisiteTargets
                            |> School__SelectBox.convertOldItems
                          }
                          selectCB={
                            multiSelectPrerequisiteTargetsCB
                            |> School__SelectBox.convertOldCallback
                          }
                        />
                      </div>
                    </div> :
                    ReasonReact.null
                }
                <div className="flex items-center mb-6">
                  <label
                    className="block tracking-wide text-sm font-semibold mr-6"
                    htmlFor="evaluated">
                    {"Is this target reviewed by a faculty?" |> str}
                  </label>
                  <div
                    id="evaluated"
                    className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden">
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          dispatch(UpdateMethodOfCompletion(Evaluated));
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
                          dispatch(UpdateMethodOfCompletion(MarkAsComplete));
                        }
                      }
                      className={booleanButtonClasses(!targetEvaluated())}>
                      {"No" |> str}
                    </button>
                  </div>
                </div>
                <div className="mb-6">
                  <label
                    className="block tracking-wide text-sm font-semibold mr-6"
                    htmlFor="completion-instructions">
                    {
                      "Do you have any completion instructions for the student?"
                      |> str
                    }
                    <span className="ml-1 text-xs font-normal">
                      {"(optional)" |> str}
                    </span>
                  </label>
                  <div className="text-xs mt-1 text-gray-800">
                    {
                      "These instructions will be displayed close to where students complete the target."
                      |> str
                    }
                  </div>
                  <input
                    className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                    id="completion-instructions"
                    type_="text"
                    maxLength=255
                    placeholder="Do these specific things to complete this target!"
                    value={state.completionInstructions}
                    onChange={
                      event =>
                        dispatch(
                          UpdateCompletionInstructions(
                            ReactEvent.Form.target(event)##value,
                          ),
                        )
                    }
                  />
                </div>
                {
                  targetEvaluated() ?
                    ReasonReact.null :
                    <div>
                      <div className="mb-6">
                        <label
                          className="block tracking-wide text-sm font-semibold mr-6 mb-3"
                          htmlFor="method_of_completion">
                          {
                            "How do you want the student to complete the target?"
                            |> str
                          }
                        </label>
                        <div id="method_of_completion" className="flex -mx-2">
                          <div className="w-1/3 px-2">
                            <button
                              onClick={
                                _event => {
                                  ReactEvent.Mouse.preventDefault(_event);
                                  dispatch(
                                    UpdateMethodOfCompletion(MarkAsComplete),
                                  );
                                }
                              }
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
                              onClick={
                                _event => {
                                  ReactEvent.Mouse.preventDefault(_event);
                                  dispatch(
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
                              {"Visit a link to complete the target." |> str}
                            </button>
                          </div>
                          <div className="w-1/3 px-2">
                            <button
                              onClick={
                                _event => {
                                  ReactEvent.Mouse.preventDefault(_event);
                                  dispatch(
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
                        className="block tracking-wide text-sm font-semibold mr-6 mb-2"
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
                        items={
                          state.evaluationCriteria
                          |> School__SelectBox.convertOldItems
                        }
                        selectCB={
                          multiSelectEvaluationCriterionCB
                          |> School__SelectBox.convertOldCallback
                        }
                      />
                    </div>
                  | MarkAsComplete => ReasonReact.null
                  | TakeQuiz =>
                    <div>
                      <h3
                        className="block tracking-wide font-semibold mb-2"
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
                               key={quizQuestion |> QuizQuestion.id}
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
                        className="flex items-center bg-gray-200 border border-dashed border-primary-400 hover:bg-white hover:text-primary-500 hover:shadow-md rounded-lg p-3 cursor-pointer my-5">
                        <i className="fas fa-plus-circle text-lg" />
                        <h5 className="font-semibold mt-2">
                          {"Add another Question" |> str}
                        </h5>
                      </a>
                    </div>
                  | VisitLink =>
                    <div className="mt-5">
                      <label
                        className="inline-block tracking-wide text-sm font-semibold"
                        htmlFor="link_to_complete">
                        {"Link to complete" |> str}
                      </label>
                      <span> {"*" |> str} </span>
                      <input
                        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
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
          </div>
          <div className="bg-white pt-4 pb-6">
            <div
              className="flex max-w-3xl w-full justify-between items-center px-3 mx-auto">
              {
                switch (state.activeStep) {
                | TargetActions =>
                  <div className="flex items-center flex-shrink-0">
                    <label
                      className="block tracking-wide text-sm font-semibold mr-3"
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
                  <div className="w-full flex items-center justify-end">
                    {
                      state.contentEditorDirty ?
                        <div
                          className="w-full flex items-center bg-orange-100 border border-orange-400 rounded py-2 px-3 mr-4 text-orange-800 font-semibold">
                          <i className="fas fa-exclamation-triangle" />
                          <span className="ml-2">
                            {"You have unsaved changes in this step" |> str}
                          </span>
                        </div> :
                        React.null
                    }
                    <button
                      key="add-content-step"
                      onClick=(
                        _event => dispatch(UpdateActiveStep(TargetActions))
                      )
                      className="btn btn-large btn-primary">
                      <span className="mr-2"> {"Next Step" |> str} </span>
                      <i className="fas fa-arrow-right text-sm" />
                    </button>
                  </div>
                | TargetActions =>
                  <div className="w-auto">
                    <button
                      key="target-actions-step"
                      disabled={saveDisabled(state)}
                      onClick=(_e => updateTarget(true, target |> Target.id))
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