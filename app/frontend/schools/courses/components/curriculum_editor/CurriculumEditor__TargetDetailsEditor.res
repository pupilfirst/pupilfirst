open CurriculumEditor__Types

@module("./images/target-complete-mark-icon.svg")
external markIcon: string = "default"
@module("./images/target-complete-link-icon.svg")
external linkIcon: string = "default"
@module("./images/target-complete-quiz-icon.svg")
external quizIcon: string = "default"
@module("./images/target-complete-form-icon.svg")
external formIcon: string = "default"

let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetDetailsEditor", ...)
let ts = I18n.ts

type methodOfCompletion =
  | Evaluated
  | TakeQuiz
  | SubmitForm
  | NoAssignment

type evaluationCriterion = (int, string, bool)

type state = {
  title: string,
  targetGroupId: option<string>,
  role: AssignmentDetails.role,
  evaluationCriteria: array<string>,
  prerequisiteTargets: array<string>,
  prerequisiteSearchInput: string,
  evaluationCriteriaSearchInput: string,
  targetGroupSearchInput: string,
  methodOfCompletion: methodOfCompletion,
  quiz: array<QuizQuestion.t>,
  dirty: bool,
  saving: bool,
  loading: bool,
  visibility: TargetDetails.visibility,
  checklist: array<ChecklistItem.t>,
  completionInstructions: string,
  targetDetails: option<TargetDetails.t>,
  assignmentDetails: option<AssignmentDetails.t>,
  milestone: bool,
  hasAssignment: bool,
  discussion: bool,
  allowAnonymous: bool,
}

type action =
  | SaveTargetDetails(TargetDetails.t)
  | SaveAssignmentDetails(AssignmentDetails.t)
  | UpdateTitle(string)
  | UpdatePrerequisiteTargets(array<string>)
  | UpdateMethodOfCompletion(methodOfCompletion)
  | UpdateEvaluationCriteria(array<string>)
  | UpdatePrerequisiteSearchInput(string)
  | UpdateEvaluationCriteriaSearchInput(string)
  | UpdateTargetGroupSearchInput(string)
  | UpdateTargetGroup(string)
  | UpdateTargetGroupAndClearPrerequisiteTargets(string)
  | UpdateCompletionInstructions(string)
  | UpdateAssignmentRole(AssignmentDetails.role)
  | AddQuizQuestion
  | UpdateQuizQuestion(QuizQuestion.id, QuizQuestion.t)
  | RemoveQuizQuestion(QuizQuestion.id)
  | UpdateVisibility(TargetDetails.visibility)
  | UpdateChecklistItem(int, ChecklistItem.t)
  | AddNewChecklistItem
  | RemoveChecklistItem(int)
  | MoveChecklistItemUp(int)
  | MoveChecklistItemDown(int)
  | CopyChecklistItem(int)
  | UpdateSaving
  | ClearTargetGroupId
  | ResetEditor
  | UpdateMilestone(bool)
  | UpdateHasAssignment(bool)
  | UpdateDiscussion(bool)
  | UpdateAllowAnonymous(bool)

module TargetDetailsQuery = %graphql(`
    query TargetDetailsQuery($targetId: ID!) {
      targetDetails(targetId: $targetId) {
        title
        targetGroupId
        visibility
      }
  }
`)

module AssignmentDetailsQuery = %graphql(`
    query AssignmentDetailsQuery($targetId: ID!) {
      assignmentDetails(targetId: $targetId) {
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
        role
        checklist
        milestone
        archived
        discussion
        allowAnonymous
      }
  }
`)

let loadTargetDetails = (targetId, send) => ignore(Js.Promise.then_(result => {
      let targetDetails = TargetDetails.makeFromJs(result["targetDetails"])
      send(SaveTargetDetails(targetDetails))
      Js.Promise.resolve()
    }, TargetDetailsQuery.make({targetId: targetId})))

let loadAssignmentDetails = (targetId, send) => ignore(Js.Promise.then_(result => {
      switch result["assignmentDetails"] {
      | Some(value) =>
        let assignmentDetails = AssignmentDetails.makeFromJs(value)
        send(SaveAssignmentDetails(assignmentDetails))
      | None => Js.log("no assignment")
      }
      Js.Promise.resolve()
    }, AssignmentDetailsQuery.make({targetId: targetId})))

let defaultChecklist = [
  ChecklistItem.make(~title=t("describe_submission"), ~kind=LongText, ~optional=false),
]

let computeMethodOfCompletion = assignmentDetails => {
  let hasQuiz = ArrayUtils.isNotEmpty(AssignmentDetails.quiz(assignmentDetails))
  let hasEvaluationCriteria = ArrayUtils.isNotEmpty(assignmentDetails.evaluationCriteria)
  let hasChecklist = ArrayUtils.isNotEmpty(assignmentDetails.checklist)
  switch (hasEvaluationCriteria, hasQuiz, hasChecklist) {
  | (true, _y, _z) => Evaluated
  | (_x, true, _z) => TakeQuiz
  | (_x, _y, true) => SubmitForm
  | (false, false, false) => NoAssignment
  }
}

let reducer = (state, action) =>
  switch action {
  | SaveTargetDetails(targetDetails) => {
      ...state,
      title: targetDetails.title,
      targetGroupId: Some(targetDetails.targetGroupId),
      visibility: targetDetails.visibility,
      loading: false,
      targetDetails: Some(targetDetails),
    }
  | SaveAssignmentDetails(assignmentDetails) =>
    let methodOfCompletion = computeMethodOfCompletion(assignmentDetails)
    let checklist = ArrayUtils.isNotEmpty(assignmentDetails.checklist)
      ? assignmentDetails.checklist
      : defaultChecklist
    let quiz = ArrayUtils.isNotEmpty(assignmentDetails.quiz)
      ? assignmentDetails.quiz
      : [QuizQuestion.empty("0")]
    {
      ...state,
      role: assignmentDetails.role,
      evaluationCriteria: assignmentDetails.evaluationCriteria,
      prerequisiteTargets: assignmentDetails.prerequisiteTargets,
      methodOfCompletion,
      quiz,
      completionInstructions: switch assignmentDetails.completionInstructions {
      | Some(instructions) => instructions
      | None => ""
      },
      checklist,
      loading: false,
      assignmentDetails: Some(assignmentDetails),
      milestone: assignmentDetails.milestone,
      hasAssignment: !assignmentDetails.archived,
      discussion: assignmentDetails.discussion,
      allowAnonymous: assignmentDetails.allowAnonymous,
    }
  | UpdateTitle(title) => {...state, title, dirty: true}
  | UpdatePrerequisiteTargets(prerequisiteTargets) => {
      ...state,
      prerequisiteTargets,
      prerequisiteSearchInput: "",
      dirty: true,
    }
  | UpdatePrerequisiteSearchInput(prerequisiteSearchInput) => {
      ...state,
      prerequisiteSearchInput,
    }
  | UpdateMethodOfCompletion(methodOfCompletion) => {
      ...state,
      methodOfCompletion,
      dirty: true,
    }
  | UpdateEvaluationCriteria(evaluationCriteria) => {
      ...state,
      evaluationCriteria,
      evaluationCriteriaSearchInput: "",
      dirty: true,
    }
  | UpdateEvaluationCriteriaSearchInput(evaluationCriteriaSearchInput) => {
      ...state,
      evaluationCriteriaSearchInput,
    }
  | UpdateCompletionInstructions(instruction) => {
      ...state,
      completionInstructions: instruction,
      dirty: true,
    }
  | UpdateAssignmentRole(role) => {...state, role, dirty: true}
  | AddQuizQuestion =>
    let quiz = Js.Array.concat([QuizQuestion.empty(Js.Float.toString(Js.Date.now()))], state.quiz)
    {...state, quiz, dirty: true}
  | UpdateQuizQuestion(id, quizQuestion) =>
    let quiz = Js.Array.map(q => QuizQuestion.id(q) == id ? quizQuestion : q, state.quiz)
    {...state, quiz, dirty: true}
  | RemoveQuizQuestion(id) =>
    let quiz = Js.Array.filter(q => QuizQuestion.id(q) != id, state.quiz)
    {...state, quiz, dirty: true}
  | UpdateVisibility(visibility) => {...state, visibility, dirty: true}
  | UpdateChecklistItem(indexToChange, newItem) => {
      ...state,
      checklist: Js.Array.mapi(
        (checklistItem, index) => index == indexToChange ? newItem : checklistItem,
        state.checklist,
      ),
      dirty: true,
    }
  | AddNewChecklistItem => {
      ...state,
      checklist: Js.Array.concat([ChecklistItem.longText], state.checklist),
      dirty: true,
    }
  | RemoveChecklistItem(index) => {
      ...state,
      checklist: ChecklistItem.removeItem(index, state.checklist),
      dirty: true,
    }
  | MoveChecklistItemUp(index) => {
      ...state,
      checklist: ChecklistItem.moveUp(index, state.checklist),
      dirty: true,
    }
  | MoveChecklistItemDown(index) => {
      ...state,
      checklist: ChecklistItem.moveDown(index, state.checklist),
      dirty: true,
    }
  | CopyChecklistItem(index) => {
      ...state,
      checklist: ChecklistItem.copy(index, state.checklist),
      dirty: true,
    }
  | UpdateSaving => {...state, saving: !state.saving}
  | ResetEditor => {...state, saving: false, dirty: false}
  | UpdateTargetGroupSearchInput(targetGroupSearchInput) => {
      ...state,
      targetGroupSearchInput,
    }
  | UpdateTargetGroup(targetGroupId) => {
      ...state,
      targetGroupId: Some(targetGroupId),
      dirty: true,
      targetGroupSearchInput: "",
    }
  | UpdateTargetGroupAndClearPrerequisiteTargets(targetGroupId) => {
      ...state,
      targetGroupId: Some(targetGroupId),
      dirty: true,
      targetGroupSearchInput: "",
      prerequisiteTargets: [],
    }
  | ClearTargetGroupId => {...state, targetGroupId: None, dirty: true}
  | UpdateMilestone(milestone) => {...state, milestone, dirty: true}
  | UpdateHasAssignment(hasAssignment) => {
      ...state,
      hasAssignment,
      dirty: true,
    }
  | UpdateDiscussion(discussion) => {
      ...state,
      discussion,
      dirty: true,
    }
  | UpdateAllowAnonymous(allowAnonymous) => {
      ...state,
      allowAnonymous,
      dirty: true,
    }
  }

let updateTitle = (send, event) => {
  let title = ReactEvent.Form.target(event)["value"]
  send(UpdateTitle(title))
}

let eligiblePrerequisiteTargets = (targetId, targets) => {
  targets
  ->Js.Array2.filter(target => Target.hasAssignment(target))
  ->Js.Array2.filter(target => !Target.archived(target))
  ->Js.Array2.filter(target => Target.id(target) != targetId)
}

let setPrerequisiteSearch = (send, value) => send(UpdatePrerequisiteSearchInput(value))

let selectPrerequisiteTarget = (send, state, target) => {
  let updatedPrerequisites = Js.Array.concat([Target.id(target)], state.prerequisiteTargets)
  send(UpdatePrerequisiteTargets(updatedPrerequisites))
}

let deSelectPrerequisiteTarget = (send, state, target) => {
  let updatedPrerequisites = Js.Array.filter(
    targetId => targetId != Target.id(target),
    state.prerequisiteTargets,
  )
  send(UpdatePrerequisiteTargets(updatedPrerequisites))
}

module SelectablePrerequisiteTargets = {
  type t = Target.t

  let value = t => Target.title(t)
  let searchString = value
}

module MultiSelectForPrerequisiteTargets = MultiselectInline.Make(SelectablePrerequisiteTargets)

let prerequisiteTargetEditor = (send, eligiblePrerequisiteTargets, state) => {
  let selected = Js.Array.filter(
    target => Js.Array.includes(Target.id(target), state.prerequisiteTargets),
    eligiblePrerequisiteTargets,
  )

  let unselected = Js.Array.filter(
    target => !Js.Array.includes(Target.id(target), state.prerequisiteTargets),
    eligiblePrerequisiteTargets,
  )
  ArrayUtils.isNotEmpty(eligiblePrerequisiteTargets)
    ? <div className="mb-6">
        <label
          className="block tracking-wide text-sm font-semibold mb-2" htmlFor="prerequisite_targets">
          <span className="me-2">
            <i className="fas fa-list rtl:rotate-180 text-base" />
          </span>
          {str(t("prerequisite_targets_label"))}
        </label>
        <div id="prerequisite_targets" className="mb-6 ms-6">
          <MultiSelectForPrerequisiteTargets
            placeholder={t("search_targets")}
            emptySelectionMessage={t("no_targets_selected")}
            allItemsSelectedMessage={t("selected_all_targets")}
            selected
            unselected
            onChange={setPrerequisiteSearch(send)}
            value=state.prerequisiteSearchInput
            onSelect={selectPrerequisiteTarget(send, state)}
            onDeselect={deSelectPrerequisiteTarget(send, state)}
          />
        </div>
      </div>
    : React.null
}

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button"
  classes ++ (bool ? " toggle-button__button--active" : "")
}

let targetRoleClasses = selected =>
  "w-1/2 target-editor__completion-button relative flex border text-sm font-semibold focus:outline-none rounded px-5 py-4 md:px-8 md:py-5 items-center cursor-pointer  focus:outline-none focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 " ++ (
    selected
      ? "target-editor__completion-button--selected bg-gray-50 text-primary-500 border-primary-500"
      : "border-gray-300 hover:bg-gray-50 bg-white"
  )

let anonymityClasses = selected =>
  "w-1/2 target-editor__completion-button relative flex border text-sm font-semibold focus:outline-none rounded px-5 py-4 md:px-8 md:py-5 items-center cursor-pointer  focus:outline-none focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 " ++ (
    selected
      ? "target-editor__completion-button--selected bg-gray-50 text-primary-500 border-primary-500"
      : "border-gray-300 hover:bg-gray-50 bg-white"
  )

let targetEvaluated = methodOfCompletion =>
  switch methodOfCompletion {
  | Evaluated => true
  | TakeQuiz => false
  | SubmitForm => false
  | NoAssignment => false
  }

let validNumberOfEvaluationCriteria = state => ArrayUtils.isNotEmpty(state.evaluationCriteria)

let setEvaluationCriteriaSearch = (send, value) => send(UpdateEvaluationCriteriaSearchInput(value))

let selectEvaluationCriterion = (send, state, evaluationCriterion) => {
  let updatedEvaluationCriteria = Js.Array.concat(
    [EvaluationCriterion.id(evaluationCriterion)],
    state.evaluationCriteria,
  )

  send(UpdateEvaluationCriteria(updatedEvaluationCriteria))
}

let deselectEvaluationCriterion = (send, state, evaluationCriterion) => {
  let updatedEvaluationCriteria = Js.Array.filter(
    ecId => ecId != EvaluationCriterion.id(evaluationCriterion),
    state.evaluationCriteria,
  )

  send(UpdateEvaluationCriteria(updatedEvaluationCriteria))
}
module SelectableEvaluationCriterion = {
  type t = EvaluationCriterion.t

  let value = t => EvaluationCriterion.name(t)
  let searchString = value

  let make = (evaluationCriterion): t => evaluationCriterion
}

module MultiSelectForEvaluationCriteria = MultiselectInline.Make(SelectableEvaluationCriterion)

let evaluationCriteriaEditor = (state, evaluationCriteria, send) => {
  let selected = Js.Array.map(
    SelectableEvaluationCriterion.make,
    Js.Array.map(
      ecId =>
        ArrayUtils.unsafeFind(
          ec => EvaluationCriterion.id(ec) == ecId,
          t("could_not_find") ++ " " ++ ecId,
          evaluationCriteria,
        ),
      state.evaluationCriteria,
    ),
  )

  let unselected = Js.Array.map(
    SelectableEvaluationCriterion.make,
    Js.Array.filter(
      ec => !Js.Array.includes(EvaluationCriterion.id(ec), state.evaluationCriteria),
      evaluationCriteria,
    ),
  )
  <div id="evaluation_criteria" className="mb-6">
    <label
      className="block tracking-wide text-sm font-semibold me-6 mb-2" htmlFor="evaluation_criteria">
      <span className="me-2">
        <i className="fas fa-list rtl:rotate-180 text-base" />
      </span>
      {str(t("select_criterion_label"))}
    </label>
    <div className="ms-6">
      {validNumberOfEvaluationCriteria(state)
        ? React.null
        : <div className="drawer-right-form__error-msg mb-2">
            {str(t("select_criterion_warning"))}
          </div>}
      <MultiSelectForEvaluationCriteria
        placeholder={t("search_criteria_placeholder")}
        emptySelectionMessage={t("search_criteria_empty")}
        allItemsSelectedMessage={t("search_criteria_all")}
        selected
        unselected
        onChange={setEvaluationCriteriaSearch(send)}
        value=state.evaluationCriteriaSearchInput
        onSelect={selectEvaluationCriterion(send, state)}
        onDeselect={deselectEvaluationCriterion(send, state)}
      />
    </div>
  </div>
}

let updateCompletionInstructions = (send, event) =>
  send(UpdateCompletionInstructions(ReactEvent.Form.target(event)["value"]))

let updateMethodOfCompletion = (methodOfCompletion, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateMethodOfCompletion(methodOfCompletion))
}

let updateHasAssignment = (hasAssignment, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateHasAssignment(hasAssignment))
}

let updateDiscussion = (discussion, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateDiscussion(discussion))
}

let updateAllowAnonymous = (allowAnonymous, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateAllowAnonymous(allowAnonymous))
}

let updateMilestone = (milestone, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateMilestone(milestone))
}

let updateAssignmentRole = (role, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateAssignmentRole(role))
}

let updateVisibility = (visibility, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateVisibility(visibility))
}

module SelectableTargetGroup = {
  type t = {
    level: Level.t,
    targetGroup: TargetGroup.t,
  }

  let id = t => TargetGroup.id(t.targetGroup)

  let label = _t => None

  let value = t =>
    LevelLabel.format(~name=TargetGroup.name(t.targetGroup), string_of_int(Level.number(t.level)))

  let searchString = t => value(t)

  let color = _t => "orange"

  let level = t => t.level

  let make = (level, targetGroup) => {level, targetGroup}
}

module TargetGroupSelector = MultiselectDropdown.Make(SelectableTargetGroup)

let findLevel = (levels, targetGroupId) =>
  Level.unsafeFind(levels, "TargetDetailsEditor", targetGroupId)

let unselectedTargetGroups = (levels, targetGroups, targetGroupId) =>
  Js.Array.map(
    t => SelectableTargetGroup.make(findLevel(levels, TargetGroup.levelId(t)), t),
    targetGroupId->Belt.Option.mapWithDefault(targetGroups, tgId =>
      Js.Array.filter(t => TargetGroup.id(t) != tgId && !TargetGroup.archived(t), targetGroups)
    ),
  )

let selectedTargetGroup = (levels, targetGroups, targetGroupId) =>
  switch targetGroupId {
  | Some(targetGroupId) =>
    let targetGroup = TargetGroup.unsafeFind(
      targetGroups,
      "TargetDetailsEditor.selectedTargetGroup",
      targetGroupId,
    )
    [SelectableTargetGroup.make(findLevel(levels, TargetGroup.levelId(targetGroup)), targetGroup)]
  | None => []
  }

let targetGroupOnSelect = (state, send, targetGroups, selectable) => {
  let newTargetGroupId = SelectableTargetGroup.id(selectable)

  switch state.targetDetails {
  | Some(details) =>
    let oldTargetGroup = TargetGroup.unsafeFind(
      targetGroups,
      "TargetDetailsEditors.targetGroupOnSelect",
      TargetDetails.targetGroupId(details),
    )

    if Level.id(SelectableTargetGroup.level(selectable)) == TargetGroup.levelId(oldTargetGroup) {
      send(UpdateTargetGroup(newTargetGroupId))
    } else {
      send(UpdateTargetGroupAndClearPrerequisiteTargets(newTargetGroupId))
    }
  | None => send(UpdateTargetGroup(newTargetGroupId))
  }
}

let targetGroupEditor = (state, targetGroups, levels, send) =>
  <div id="target_group_id" className="mb-6">
    <label className="block tracking-wide text-sm font-semibold me-6 mb-2" htmlFor="target_group">
      <span className="me-2">
        <i className="fas fa-list rtl:rotate-180 text-base" />
      </span>
      {str(t("target_group"))}
    </label>
    <div className="ms-6">
      <TargetGroupSelector
        id="target_group"
        unselected={unselectedTargetGroups(levels, targetGroups, state.targetGroupId)}
        selected={selectedTargetGroup(levels, targetGroups, state.targetGroupId)}
        onSelect={targetGroupOnSelect(state, send, targetGroups)}
        onDeselect={_ => send(ClearTargetGroupId)}
        value=state.targetGroupSearchInput
        onChange={searchString => send(UpdateTargetGroupSearchInput(searchString))}
      />
      {switch state.targetGroupId {
      | Some(_) => React.null
      | None => <School__InputGroupError message={t("choose_target_group")} active=true />
      }}
    </div>
  </div>

let methodOfCompletionButtonClasses = value => {
  let defaultClasses = "target-editor__completion-button relative flex flex-col items-center bg-white border hover:bg-gray-50 text-sm font-semibold focus:outline-none focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 rounded p-4"
  value
    ? defaultClasses ++ " target-editor__completion-button--selected bg-gray-50 text-primary-500 border-primary-500"
    : defaultClasses ++ " border-gray-300 opacity-75 text-gray-900"
}

let methodOfCompletionSelection = polyMethodOfCompletion =>
  switch polyMethodOfCompletion {
  | #TakeQuiz => TakeQuiz
  | #SubmitForm => SubmitForm
  }

let methodOfCompletionButton = (methodOfCompletion, state, send, index) => {
  let buttonString = switch methodOfCompletion {
  | #TakeQuiz => t("take_quiz")
  | #SubmitForm => t("submit_form")
  }

  let selected = switch (state.methodOfCompletion, methodOfCompletion) {
  | (TakeQuiz, #TakeQuiz) => true
  | (SubmitForm, #SubmitForm) => true
  | _anyOtherCombo => false
  }

  let icon = switch methodOfCompletion {
  | #TakeQuiz => quizIcon
  | #SubmitForm => formIcon
  }

  <div key={string_of_int(index)} className="w-1/3 px-2">
    <button
      onClick={updateMethodOfCompletion(methodOfCompletionSelection(methodOfCompletion), send)}
      className={methodOfCompletionButtonClasses(selected)}>
      <div className="mb-1">
        <img className="w-12 h-12" src=icon />
      </div>
      <div className="text-center"> {str(buttonString)} </div>
    </button>
  </div>
}

let methodOfCompletionSelector = (state, send) =>
  <div>
    <div className="mb-6">
      <label
        className="block tracking-wide text-sm font-semibold me-6 mb-3"
        htmlFor="method_of_completion">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {str(t("target_method_of_completion_label"))}
      </label>
      <div id="method_of_completion" className="flex -mx-2 ps-6 ">
        {React.array(
          Js.Array.mapi(
            (methodOfCompletion, index) =>
              methodOfCompletionButton(methodOfCompletion, state, send, index),
            [#TakeQuiz, #SubmitForm],
          ),
        )}
      </div>
    </div>
  </div>

let isValidQuiz = quiz =>
  ArrayUtils.isEmpty(
    Js.Array.filter(quizQuestion => QuizQuestion.isValidQuizQuestion(quizQuestion) != true, quiz),
  )

let isValidChecklist = checklist =>
  ArrayUtils.isEmpty(
    Js.Array.filter(
      checklistItem => ChecklistItem.isValidChecklistItem(checklistItem) != true,
      checklist,
    ),
  )

let addQuizQuestion = (send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(AddQuizQuestion)
}
let updateQuizQuestionCB = (send, id, quizQuestion) => send(UpdateQuizQuestion(id, quizQuestion))

let removeQuizQuestionCB = (send, id) => send(RemoveQuizQuestion(id))
let questionCanBeRemoved = state => Js.Array.length(state.quiz) > 1

let quizEditor = (state, send) =>
  <div>
    <label
      className="block tracking-wide text-sm font-semibold me-6 mb-3" htmlFor="Quiz question 1">
      <span className="me-2">
        <i className="fas fa-list rtl:rotate-180 text-base" />
      </span>
      {str(t("prepare_quiz"))}
    </label>
    <div className="ms-6">
      {isValidQuiz(state.quiz)
        ? React.null
        : <School__InputGroupError message={t("prepare_quiz_error")} active=true />}
      {React.array(
        Js.Array.mapi(
          (quizQuestion, index) =>
            <CurriculumEditor__TargetQuizQuestion
              key={QuizQuestion.id(quizQuestion)}
              questionNumber={string_of_int(index + 1)}
              quizQuestion
              updateQuizQuestionCB={updateQuizQuestionCB(send)}
              removeQuizQuestionCB={removeQuizQuestionCB(send)}
              questionCanBeRemoved={questionCanBeRemoved(state)}
            />,
          state.quiz,
        ),
      )}
      <button
        onClick={addQuizQuestion(send)}
        className="flex w-full items-center bg-gray-50 border border-dashed border-primary-400 hover:bg-white hover:text-primary-500 hover:shadow-md focus:bg-white focus:text-primary-500 focus:shadow-md rounded-lg p-3 cursor-pointer my-5">
        <i className="fas fa-plus-circle text-lg" />
        <h5 className="font-semibold ms-2"> {str(t("add_another_question"))} </h5>
      </button>
    </div>
  </div>

let hasValidChecklist = checklist => {
  let requiredSteps = Js.Array.filter(item => !ChecklistItem.optional(item), checklist)

  let hasUniqueTitles =
    requiredSteps
    ->Js.Array2.map(ChecklistItem.title)
    ->Js.Array2.map(String.trim)
    ->ArrayUtils.distinct
    ->Js.Array.length == Js.Array.length(requiredSteps)

  let multiChoiceSteps = checklist->Js.Array2.filter(item =>
    switch ChecklistItem.kind(item) {
    | MultiChoice(_, _) => true
    | _ => false
    }
  )

  let hasValidChoices = multiChoiceSteps->Js.Array2.every(item =>
    switch ChecklistItem.kind(item) {
    | MultiChoice(choices, _) =>
      choices->Js.Array2.map(String.trim)->ArrayUtils.distinct->Js.Array.length ==
        Js.Array.length(choices)
    | _ => false
    }
  )

  hasUniqueTitles && hasValidChoices
}

let isValidTitle = title => String.length(String.trim(title)) > 0

let formEditor = (state, send) => {
  let status = targetEvaluated(state.methodOfCompletion)

  <div className="mb-6">
    <label className="tracking-wide text-sm font-semibold" htmlFor="target_checklist">
      <span className="me-2">
        <i className="fas fa-list rtl:rotate-180 text-base" />
      </span>
      {status ? t("target_checklist.label")->str : t("target_checklist.form_label")->str}
    </label>
    {status
      ? <HelpIcon className="ms-1" link={t("target_checklist.help_url")}>
          {t("target_checklist.help")->str}
        </HelpIcon>
      : <HelpIcon className="ms-1"> {t("target_checklist.form_help")->str} </HelpIcon>}
    <div className="ms-6 mb-6">
      {React.array(Js.Array.mapi((checklistItem, index) => {
          let moveChecklistItemUpCB =
            index > 0 ? Some(() => send(MoveChecklistItemUp(index))) : None

          let moveChecklistItemDownCB =
            index != Js.Array.length(state.checklist) - 1
              ? Some(() => send(MoveChecklistItemDown(index)))
              : None

          <CurriculumEditor__TargetChecklistItemEditor
            checklist=state.checklist
            key={string_of_int(index)}
            checklistItem
            index
            updateChecklistItemCB={newChecklistItem =>
              send(UpdateChecklistItem(index, newChecklistItem))}
            removeChecklistItemCB={() => send(RemoveChecklistItem(index))}
            ?moveChecklistItemUpCB
            ?moveChecklistItemDownCB
            copyChecklistItemCB={() => send(CopyChecklistItem(index))}
          />
        }, state.checklist))}
      {ArrayUtils.isEmpty(state.checklist)
        ? <div
            className="border border-orange-500 bg-orange-100 text-orange-800 px-2 py-1 rounded my-2 text-sm text-center">
            <i className="fas fa-info-circle me-2" />
            {t("empty_questions_warning")->str}
          </div>
        : React.null}
      {Js.Array.length(state.checklist) >= 25
        ? <div
            className="border border-orange-500 bg-orange-100 text-orange-800 px-2 py-1 rounded my-2 text-sm text-center">
            <i className="fas fa-info-circle me-2" />
            {t("target_checklist.form_limit_warning")->str}
          </div>
        : React.null}
      <button
        className="flex justify-center bg-white items-center w-full rounded-lg border border-dashed border-primary-500 mt-2 p-2 text-sm text-primary-500 hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-focusColor-500"
        disabled={Js.Array.length(state.checklist) >= 25}
        onClick={_ => send(AddNewChecklistItem)}>
        <PfIcon className="fas fa-plus-circle text-lg" />
        <span className="font-semibold ms-2"> {t("add_another_question")->str} </span>
      </button>
    </div>
  </div>
}

let assignmentEditor = (state, send, target, targets, evaluationCriteria) => {
  let targetId = Target.id(target)
  <div>
    <div className="flex items-center mb-6">
      <label className="block tracking-wide text-sm font-semibold me-1" htmlFor="milestone">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {t("target_setting_milestone.label")->str}
      </label>
      <HelpIcon link={t("target_setting_milestone.help_url")} className="me-6">
        {str(t("target_setting_milestone.help"))}
      </HelpIcon>
      <div id="milestone" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          onClick={updateMilestone(true, send)} className={booleanButtonClasses(state.milestone)}>
          {str(ts("_yes"))}
        </button>
        <button
          onClick={updateMilestone(false, send)} className={booleanButtonClasses(!state.milestone)}>
          {str(ts("_no"))}
        </button>
      </div>
    </div>
    {prerequisiteTargetEditor(send, eligiblePrerequisiteTargets(targetId, targets), state)}
    <div className="flex items-center mb-6">
      <label className="block tracking-wide text-sm font-semibold me-6" htmlFor="evaluated">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {str(t("target_reviewed_by_coach"))}
      </label>
      <div id="evaluated" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          onClick={updateMethodOfCompletion(Evaluated, send)}
          className={booleanButtonClasses(targetEvaluated(state.methodOfCompletion))}>
          {str(ts("_yes"))}
        </button>
        <button
          onClick={updateMethodOfCompletion(SubmitForm, send)}
          className={booleanButtonClasses(!targetEvaluated(state.methodOfCompletion))}>
          {str(ts("_no"))}
        </button>
      </div>
    </div>
    {switch state.methodOfCompletion {
    | NoAssignment
    | TakeQuiz => React.null
    | SubmitForm => React.null
    | Evaluated => formEditor(state, send)
    }}
    {targetEvaluated(state.methodOfCompletion)
      ? React.null
      : methodOfCompletionSelector(state, send)}
    {switch state.methodOfCompletion {
    | NoAssignment
    | Evaluated =>
      evaluationCriteriaEditor(state, evaluationCriteria, send)
    | TakeQuiz => quizEditor(state, send)
    | SubmitForm => formEditor(state, send)
    }}
    <div className="flex items-center mb-6">
      <label className="block tracking-wide text-sm font-semibold me-1.5" htmlFor="discussion">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {str(t("assignment_discussion.label"))}
      </label>
      <HelpIcon link={t("assignment_discussion.help_url")} className="me-6">
        {str(t("assignment_discussion.help"))}
      </HelpIcon>
      <div id="discussion" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          onClick={updateDiscussion(true, send)} className={booleanButtonClasses(state.discussion)}>
          {str(ts("_yes"))}
        </button>
        <button
          onClick={updateDiscussion(false, send)}
          className={booleanButtonClasses(!state.discussion)}>
          {str(ts("_no"))}
        </button>
      </div>
    </div>
    {state.discussion
      ? <div className="mb-6">
          <label
            className="inline-block tracking-wide text-sm font-semibold" htmlFor="allowAnonymous">
            <span className="me-2">
              <i className="fas fa-list rtl:rotate-180 text-base" />
            </span>
            {t("allow_anonymous.title")->str}
          </label>
          <HelpIcon className="ms-1"> {t("allow_anonymous.subtitle")->str} </HelpIcon>
          <div id="allowAnonymous" className="flex mt-4 ms-6">
            <button
              onClick={updateAllowAnonymous(true, send)}
              className={"me-4 " ++ anonymityClasses(state.allowAnonymous)}>
              <span className="me-4">
                <Icon className="if i-anonymous-light text-3xl" />
              </span>
              <span className="text-sm"> {str(t("allow_anonymous.anonymous_text"))} </span>
            </button>
            <button
              onClick={updateAllowAnonymous(false, send)}
              className={anonymityClasses(!state.allowAnonymous)}>
              <span className="me-4">
                <Icon className="if i-non-anonymous-light text-3xl" />
              </span>
              <span className="text-sm"> {str(t("allow_anonymous.no_anonymous"))} </span>
            </button>
          </div>
        </div>
      : React.null}
    <div className="mb-6">
      <label className="inline-block tracking-wide text-sm font-semibold" htmlFor="role">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {str(t("target_role.label"))}
      </label>
      <HelpIcon className="ms-1" link={t("target_role.help_url")}>
        {str(t("target_role.help"))}
      </HelpIcon>
      <div id="role" className="flex mt-4 ms-6">
        <button
          onClick={updateAssignmentRole(AssignmentDetails.Student, send)}
          className={"me-4 " ++
          targetRoleClasses(
            switch state.role {
            | AssignmentDetails.Student => true
            | Team => false
            },
          )}>
          <span className="me-4">
            <Icon className="if i-users-check-light text-3xl" />
          </span>
          <span className="text-sm"> {str(t("submit_individually"))} </span>
        </button>
        <button
          onClick={updateAssignmentRole(AssignmentDetails.Team, send)}
          className={targetRoleClasses(
            switch state.role {
            | AssignmentDetails.Team => true
            | Student => false
            },
          )}>
          <span className="me-4">
            <Icon className="if i-user-check-light text-2xl" />
          </span>
          <span className="text-sm">
            {str(t("one_student_team"))}
            <br />
            {str(t("need_submit"))}
          </span>
        </button>
      </div>
    </div>
    <div className="mb-6">
      <label className="tracking-wide text-sm font-semibold" htmlFor="completion-instructions">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {t("github_action.title")->str}
        <span className="ms-1 text-xs font-normal"> {ts("optional_braces")->str} </span>
      </label>
      <HelpIcon link={t("github_action.help_url")} className="ms-1">
        {t("github_action.help_description")->str}
      </HelpIcon>
      <div className="ms-6 mt-4">
        <a
          href={`/school/targets/${Target.id(target)}/action`}
          className="btn btn-subtle flex max-w-min gap-3">
          <PfIcon className="if i-external-link-light if-fw" />
          {t("github_action.button_text")->str}
        </a>
      </div>
    </div>
    <div className="mb-6">
      <label className="tracking-wide text-sm font-semibold" htmlFor="completion-instructions">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {str(t("completion_instructions.label"))}
        <span className="ms-1 text-xs font-normal"> {str(ts("optional_braces"))} </span>
      </label>
      <HelpIcon link={t("completion_instructions.help_url")} className="ms-1">
        {str(t("completion_instructions.help"))}
      </HelpIcon>
      <div className="ms-6">
        <input
          className="appearance-none block text-sm w-full bg-white border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          id="completion-instructions"
          type_="text"
          maxLength=255
          value=state.completionInstructions
          onChange={updateCompletionInstructions(send)}
        />
      </div>
    </div>
  </div>
}

let isValidMethodOfCompletion = state =>
  switch state.methodOfCompletion {
  | TakeQuiz => isValidQuiz(state.quiz)
  | Evaluated =>
    ArrayUtils.isNotEmpty(state.evaluationCriteria) && isValidChecklist(state.checklist)
  | SubmitForm => ArrayUtils.isNotEmpty(state.checklist) && isValidChecklist(state.checklist)
  | NoAssignment => true
  }

module UpdateTargetAssignmentQuery = %graphql(`
   mutation UpdateTargetAssignmentMutation($id: ID!, $targetGroupId: ID!, $title: String!, $visibility: String!, $targetId: ID!, $role: String!, $evaluationCriteria: [ID!]!,$prerequisiteTargets: [ID!]!, $quiz: [AssignmentQuizInput!]!, $completionInstructions: String, $checklist: JSON!, $milestone: Boolean!, $archived: Boolean, $discussion: Boolean!, $allowAnonymous: Boolean ) {
     updateTarget(id: $id, targetGroupId: $targetGroupId, title: $title, visibility: $visibility)    {
        sortIndex
       }
     updateAssignment(targetId: $targetId, role: $role, evaluationCriteria: $evaluationCriteria,prerequisiteTargets: $prerequisiteTargets, quiz: $quiz, completionInstructions: $completionInstructions, checklist: $checklist, milestone: $milestone, archived: $archived, discussion: $discussion, allowAnonymous: $allowAnonymous)    {
        id
       }
     }
   `)

let updateTargetButton = (
  ~callback,
  ~state,
  ~hasValidTitle,
  ~hasValidMethodOfCompletion,
  ~hasValidChecklist,
) => {
  let onClick = Belt.Option.map(state.targetGroupId, callback)
  let disabled = if state.hasAssignment {
    !hasValidChecklist ||
    (!hasValidTitle ||
    (!hasValidMethodOfCompletion || (!state.dirty || (state.saving || onClick == None))))
  } else {
    !hasValidTitle || (!state.dirty || (state.saving || onClick == None))
  }

  <button
    key="target-actions-step"
    ?onClick
    disabled
    className="btn btn-primary w-full text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
    {str(t("update_target"))}
  </button>
}

let quizAnswersAsJsObject = quizAnswers =>
  Array.map(
    qa =>
      UpdateTargetAssignmentQuery.makeInputObjectAssignmentQuizAnswerInput(
        ~answer=AnswerOption.answer(qa),
        ~correctAnswer=AnswerOption.correctAnswer(qa),
        (),
      ),
    quizAnswers,
  )

let quizAsJsObject = quiz =>
  Array.map(
    q =>
      UpdateTargetAssignmentQuery.makeInputObjectAssignmentQuizInput(
        ~question=QuizQuestion.question(q),
        ~answerOptions=quizAnswersAsJsObject(QuizQuestion.answerOptions(q)),
        (),
      ),
    quiz,
  )

let updateTargetAssignment = (target, state, send, updateTargetCB, targetGroupId, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateSaving)
  let id = Target.id(target)
  let visibilityAsString = TargetDetails.visibilityAsString(state.visibility)

  let visibility = switch state.visibility {
  | Live => Target.Live
  | Archived => Archived
  | Draft => Draft
  }

  let role = state.role->AssignmentDetails.roleAsString
  let quizAsJs = quizAsJsObject(
    Js.Array.filter(question => QuizQuestion.isValidQuizQuestion(question), state.quiz),
  )

  let (quiz, evaluationCriteria, checklist) = switch state.methodOfCompletion {
  | Evaluated => ([], state.evaluationCriteria, state.checklist)
  | TakeQuiz => (quizAsJs, [], [])
  | SubmitForm => ([], [], state.checklist)
  | NoAssignment => ([], [], [])
  }

  let variables = UpdateTargetAssignmentQuery.makeVariables(
    ~id,
    ~targetGroupId,
    ~title=state.title,
    ~visibility=visibilityAsString,
    ~targetId=id,
    ~role,
    ~evaluationCriteria,
    ~prerequisiteTargets=state.prerequisiteTargets,
    ~quiz,
    ~completionInstructions=state.completionInstructions,
    ~checklist=ChecklistItem.encodeChecklist(checklist),
    ~milestone=state.milestone,
    ~archived=!state.hasAssignment,
    ~discussion=state.discussion,
    ~allowAnonymous=state.allowAnonymous,
    (),
  )

  ignore(Js.Promise.then_(result => {
      switch result["updateTarget"]["sortIndex"] {
      | Some(sortIndex) =>
        send(ResetEditor)
        updateTargetCB(
          Target.create(
            ~id,
            ~targetGroupId,
            ~title=state.title,
            ~sortIndex,
            ~visibility,
            ~hasAssignment=state.hasAssignment,
            ~milestone=state.milestone,
          ),
        )
      | None => send(UpdateSaving)
      }

      Js.Promise.resolve()
    }, UpdateTargetAssignmentQuery.make(variables)))
  ()
}

@react.component
let make = (
  ~target,
  ~targets,
  ~targetGroups,
  ~levels,
  ~evaluationCriteria,
  ~updateTargetCB,
  ~setDirtyCB,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      title: "",
      targetGroupId: None,
      role: AssignmentDetails.Student,
      evaluationCriteria: [],
      evaluationCriteriaSearchInput: "",
      prerequisiteTargets: [],
      prerequisiteSearchInput: "",
      methodOfCompletion: Evaluated,
      quiz: [],
      dirty: false,
      saving: false,
      loading: true,
      checklist: [],
      visibility: TargetDetails.Draft,
      completionInstructions: "",
      targetGroupSearchInput: "",
      targetDetails: None,
      assignmentDetails: None,
      milestone: false,
      hasAssignment: false,
      discussion: false,
      allowAnonymous: false,
    },
  )
  let targetId = target->Target.id
  React.useEffect1(() => {
    loadTargetDetails(targetId, send)
    loadAssignmentDetails(targetId, send)
    None
  }, [targetId])

  React.useEffect1(() => {
    setDirtyCB(state.dirty)
    None
  }, [state.dirty])

  let hasValidChecklist = hasValidChecklist(state.checklist)
  let hasValidTitle = isValidTitle(state.title)
  let hasValidMethodOfCompletion = isValidMethodOfCompletion(state)

  <div className="pt-6 h-full" id="target-properties">
    {state.loading
      ? <div className="max-w-3xl mx-auto px-3">
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.contents())}
        </div>
      : <DisablingCover message={ts("saving")} disabled=state.saving>
          <div className="mt-2 min-h-screen flex flex-col justify-between ">
            <div className="max-w-3xl w-full mx-auto px-3">
              <div>
                <div className="mb-6">
                  <label
                    className="items-center inline-block tracking-wide text-sm font-semibold mb-2"
                    htmlFor="title">
                    <span className="me-2">
                      <i className="fas fa-list rtl:rotate-180 text-base" />
                    </span>
                    {str(t("title"))}
                  </label>
                  <div className="ms-6">
                    <input
                      autoFocus=true
                      className="appearance-none block text-sm w-full bg-white border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                      id="title"
                      type_="text"
                      placeholder={t("target_title_placeholder")}
                      onChange={updateTitle(send)}
                      value=state.title
                    />
                    <School__InputGroupError
                      message={t("enter_valid_title")} active={!hasValidTitle}
                    />
                  </div>
                </div>
                {targetGroupEditor(state, targetGroups, levels, send)}
              </div>
              <div className="flex items-center mb-6">
                <label
                  className="block tracking-wide text-sm font-semibold me-6"
                  htmlFor="has_assignment">
                  <span className="me-2">
                    <i className="fas fa-list rtl:rotate-180 text-base" />
                  </span>
                  {str(t("target_has_assignment"))}
                </label>
                <div id="has_assignment" className="flex toggle-button__group shrink-0 rounded-lg">
                  <button
                    onClick={updateHasAssignment(true, send)}
                    className={booleanButtonClasses(state.hasAssignment)}>
                    {str(ts("_yes"))}
                  </button>
                  <button
                    onClick={updateHasAssignment(false, send)}
                    className={booleanButtonClasses(!state.hasAssignment)}>
                    {str(ts("_no"))}
                  </button>
                </div>
              </div>
              {switch state.hasAssignment {
              | false => React.null
              | true => assignmentEditor(state, send, target, targets, evaluationCriteria)
              }}
            </div>
            <div className="bg-white border-t sticky bottom-0 py-5">
              <div className="flex max-w-3xl mx-auto px-3 justify-between items-center">
                <div className="flex items-center shrink-0">
                  <label
                    className="block tracking-wide text-sm font-semibold me-3" htmlFor="archived">
                    <span className="me-2">
                      <i className="fas fa-list rtl:rotate-180 text-base" />
                    </span>
                    {str(t("target_visibility"))}
                  </label>
                  <div id="visibility" className="flex toggle-button__group shrink-0 rounded-lg">
                    {React.array(Js.Array.mapi((visibility, index) =>
                        <button
                          key={string_of_int(index)}
                          onClick={updateVisibility(visibility, send)}
                          className={booleanButtonClasses(
                            switch (state.visibility, visibility) {
                            | (Live, TargetDetails.Live) => true
                            | (Archived, Archived) => true
                            | (Draft, Draft) => true
                            | _anyOtherCombo => false
                            },
                          )}>
                          {str(
                            switch visibility {
                            | Live => ts("live")
                            | Archived => ts("archived")
                            | Draft => ts("draft")
                            },
                          )}
                        </button>
                      , [TargetDetails.Live, Archived, Draft]))}
                  </div>
                </div>
                <div className="w-auto">
                  {updateTargetButton(
                    ~callback=updateTargetAssignment(target, state, send, updateTargetCB),
                    ~state,
                    ~hasValidTitle,
                    ~hasValidMethodOfCompletion,
                    ~hasValidChecklist,
                  )}
                </div>
              </div>
            </div>
          </div>
        </DisablingCover>}
  </div>
}
