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

let t = I18n.t(~scope="components.CurriculumEditor__TargetDetailsEditor")
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

let loadTargetDetails = (targetId, send) =>
  TargetDetailsQuery.make({targetId: targetId})
  |> Js.Promise.then_(result => {
    let targetDetails = TargetDetails.makeFromJs(result["targetDetails"])
    send(SaveTargetDetails(targetDetails))
    Js.Promise.resolve()
  })
  |> ignore

let loadAssignmentDetails = (targetId, send) =>
  AssignmentDetailsQuery.make({targetId: targetId})
  |> Js.Promise.then_(result => {
    switch result["assignmentDetails"] {
    | Some(value) =>
      let assignmentDetails = AssignmentDetails.makeFromJs(value)
      send(SaveAssignmentDetails(assignmentDetails))
    | None => Js.log("no assignment")
    }
    Js.Promise.resolve()
  })
  |> ignore

let defaultChecklist = [
  ChecklistItem.make(~title=t("describe_submission"), ~kind=LongText, ~optional=false),
]

let computeMethodOfCompletion = assignmentDetails => {
  let hasQuiz = assignmentDetails |> AssignmentDetails.quiz |> ArrayUtils.isNotEmpty
  let hasEvaluationCriteria = assignmentDetails.evaluationCriteria |> ArrayUtils.isNotEmpty
  let hasChecklist = assignmentDetails.checklist |> ArrayUtils.isNotEmpty
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
    let checklist =
      assignmentDetails.checklist |> ArrayUtils.isNotEmpty
        ? assignmentDetails.checklist
        : defaultChecklist
    let quiz =
      assignmentDetails.quiz |> ArrayUtils.isNotEmpty
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
    let quiz = Js.Array.concat([QuizQuestion.empty(Js.Date.now() |> Js.Float.toString)], state.quiz)
    {...state, quiz, dirty: true}
  | UpdateQuizQuestion(id, quizQuestion) =>
    let quiz = state.quiz |> Js.Array.map(q => QuizQuestion.id(q) == id ? quizQuestion : q)
    {...state, quiz, dirty: true}
  | RemoveQuizQuestion(id) =>
    let quiz = state.quiz |> Js.Array.filter(q => QuizQuestion.id(q) != id)
    {...state, quiz, dirty: true}
  | UpdateVisibility(visibility) => {...state, visibility, dirty: true}
  | UpdateChecklistItem(indexToChange, newItem) => {
      ...state,
      checklist: state.checklist |> Js.Array.mapi((checklistItem, index) =>
        index == indexToChange ? newItem : checklistItem
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
      checklist: state.checklist |> ChecklistItem.removeItem(index),
      dirty: true,
    }
  | MoveChecklistItemUp(index) => {
      ...state,
      checklist: state.checklist |> ChecklistItem.moveUp(index),
      dirty: true,
    }
  | MoveChecklistItemDown(index) => {
      ...state,
      checklist: state.checklist |> ChecklistItem.moveDown(index),
      dirty: true,
    }
  | CopyChecklistItem(index) => {
      ...state,
      checklist: state.checklist |> ChecklistItem.copy(index),
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
  let updatedPrerequisites =
    state.prerequisiteTargets |> Js.Array.filter(targetId => targetId != Target.id(target))
  send(UpdatePrerequisiteTargets(updatedPrerequisites))
}

module SelectablePrerequisiteTargets = {
  type t = Target.t

  let value = t => t |> Target.title
  let searchString = value
}

module MultiSelectForPrerequisiteTargets = MultiselectInline.Make(SelectablePrerequisiteTargets)

let prerequisiteTargetEditor = (send, eligiblePrerequisiteTargets, state) => {
  let selected =
    eligiblePrerequisiteTargets |> Js.Array.filter(target =>
      state.prerequisiteTargets |> Js.Array.includes(Target.id(target))
    )

  let unselected =
    eligiblePrerequisiteTargets |> Js.Array.filter(target =>
      !(state.prerequisiteTargets |> Js.Array.includes(Target.id(target)))
    )
  eligiblePrerequisiteTargets |> ArrayUtils.isNotEmpty
    ? <div className="mb-6">
        <label
          className="block tracking-wide text-sm font-semibold mb-2" htmlFor="prerequisite_targets">
          <span className="me-2">
            <i className="fas fa-list rtl:rotate-180 text-base" />
          </span>
          {t("prerequisite_targets_label") |> str}
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

let validNumberOfEvaluationCriteria = state => state.evaluationCriteria |> ArrayUtils.isNotEmpty

let setEvaluationCriteriaSearch = (send, value) => send(UpdateEvaluationCriteriaSearchInput(value))

let selectEvaluationCriterion = (send, state, evaluationCriterion) => {
  let updatedEvaluationCriteria = Js.Array.concat(
    [EvaluationCriterion.id(evaluationCriterion)],
    state.evaluationCriteria,
  )

  send(UpdateEvaluationCriteria(updatedEvaluationCriteria))
}

let deselectEvaluationCriterion = (send, state, evaluationCriterion) => {
  let updatedEvaluationCriteria =
    state.evaluationCriteria |> Js.Array.filter(ecId =>
      ecId != EvaluationCriterion.id(evaluationCriterion)
    )

  send(UpdateEvaluationCriteria(updatedEvaluationCriteria))
}
module SelectableEvaluationCriterion = {
  type t = EvaluationCriterion.t

  let value = t => t |> EvaluationCriterion.name
  let searchString = value

  let make = (evaluationCriterion): t => evaluationCriterion
}

module MultiSelectForEvaluationCriteria = MultiselectInline.Make(SelectableEvaluationCriterion)

let evaluationCriteriaEditor = (state, evaluationCriteria, send) => {
  let selected =
    state.evaluationCriteria
    |> Js.Array.map(ecId =>
      evaluationCriteria |> ArrayUtils.unsafeFind(
        ec => EvaluationCriterion.id(ec) == ecId,
        t("could_not_find") ++ " " ++ ecId,
      )
    )
    |> Js.Array.map(SelectableEvaluationCriterion.make)

  let unselected =
    evaluationCriteria
    |> Js.Array.filter(ec =>
      !(state.evaluationCriteria |> Js.Array.includes(EvaluationCriterion.id(ec)))
    )
    |> Js.Array.map(SelectableEvaluationCriterion.make)
  <div id="evaluation_criteria" className="mb-6">
    <label
      className="block tracking-wide text-sm font-semibold me-6 mb-2" htmlFor="evaluation_criteria">
      <span className="me-2">
        <i className="fas fa-list rtl:rotate-180 text-base" />
      </span>
      {t("select_criterion_label") |> str}
    </label>
    <div className="ms-6">
      {validNumberOfEvaluationCriteria(state)
        ? React.null
        : <div className="drawer-right-form__error-msg mb-2">
            {t("select_criterion_warning") |> str}
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

  let id = t => t.targetGroup |> TargetGroup.id

  let label = _t => None

  let value = t =>
    LevelLabel.format(
      ~name=t.targetGroup |> TargetGroup.name,
      t.level |> Level.number |> string_of_int,
    )

  let searchString = t => t |> value

  let color = _t => "orange"

  let level = t => t.level

  let make = (level, targetGroup) => {level, targetGroup}
}

module TargetGroupSelector = MultiselectDropdown.Make(SelectableTargetGroup)

let findLevel = (levels, targetGroupId) =>
  Level.unsafeFind(levels, "TargetDetailsEditor", targetGroupId)

let unselectedTargetGroups = (levels, targetGroups, targetGroupId) =>
  targetGroupId->Belt.Option.mapWithDefault(targetGroups, tgId =>
    targetGroups |> Js.Array.filter(t =>
      t |> TargetGroup.id != tgId && !(t |> TargetGroup.archived)
    )
  ) |> Js.Array.map(t => SelectableTargetGroup.make(findLevel(levels, t |> TargetGroup.levelId), t))

let selectedTargetGroup = (levels, targetGroups, targetGroupId) =>
  switch targetGroupId {
  | Some(targetGroupId) =>
    let targetGroup =
      targetGroupId |> TargetGroup.unsafeFind(
        targetGroups,
        "TargetDetailsEditor.selectedTargetGroup",
      )
    [SelectableTargetGroup.make(findLevel(levels, targetGroup |> TargetGroup.levelId), targetGroup)]
  | None => []
  }

let targetGroupOnSelect = (state, send, targetGroups, selectable) => {
  let newTargetGroupId = selectable |> SelectableTargetGroup.id

  switch state.targetDetails {
  | Some(details) =>
    let oldTargetGroup = TargetGroup.unsafeFind(
      targetGroups,
      "TargetDetailsEditors.targetGroupOnSelect",
      details |> TargetDetails.targetGroupId,
    )

    if (
      selectable
      |> SelectableTargetGroup.level
      |> Level.id == (oldTargetGroup |> TargetGroup.levelId)
    ) {
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
      {t("target_group") |> str}
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

  <div key={index |> string_of_int} className="w-1/3 px-2">
    <button
      onClick={updateMethodOfCompletion(methodOfCompletion |> methodOfCompletionSelection, send)}
      className={methodOfCompletionButtonClasses(selected)}>
      <div className="mb-1">
        <img className="w-12 h-12" src=icon />
      </div>
      <div className="text-center"> {buttonString |> str} </div>
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
        {t("target_method_of_completion_label") |> str}
      </label>
      <div id="method_of_completion" className="flex -mx-2 ps-6 ">
        {[#TakeQuiz, #SubmitForm]
        |> Js.Array.mapi((methodOfCompletion, index) =>
          methodOfCompletionButton(methodOfCompletion, state, send, index)
        )
        |> React.array}
      </div>
    </div>
  </div>

let isValidQuiz = quiz =>
  quiz
  |> Js.Array.filter(quizQuestion => quizQuestion |> QuizQuestion.isValidQuizQuestion != true)
  |> ArrayUtils.isEmpty

let isValidChecklist = checklist =>
  checklist
  |> Js.Array.filter(checklistItem => checklistItem |> ChecklistItem.isValidChecklistItem != true)
  |> ArrayUtils.isEmpty

let addQuizQuestion = (send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(AddQuizQuestion)
}
let updateQuizQuestionCB = (send, id, quizQuestion) => send(UpdateQuizQuestion(id, quizQuestion))

let removeQuizQuestionCB = (send, id) => send(RemoveQuizQuestion(id))
let questionCanBeRemoved = state => state.quiz |> Js.Array.length > 1

let quizEditor = (state, send) =>
  <div>
    <label
      className="block tracking-wide text-sm font-semibold me-6 mb-3" htmlFor="Quiz question 1">
      <span className="me-2">
        <i className="fas fa-list rtl:rotate-180 text-base" />
      </span>
      {t("prepare_quiz") |> str}
    </label>
    <div className="ms-6">
      {isValidQuiz(state.quiz)
        ? React.null
        : <School__InputGroupError message={t("prepare_quiz_error")} active=true />}
      {state.quiz
      |> Js.Array.mapi((quizQuestion, index) =>
        <CurriculumEditor__TargetQuizQuestion
          key={quizQuestion |> QuizQuestion.id}
          questionNumber={index + 1 |> string_of_int}
          quizQuestion
          updateQuizQuestionCB={updateQuizQuestionCB(send)}
          removeQuizQuestionCB={removeQuizQuestionCB(send)}
          questionCanBeRemoved={questionCanBeRemoved(state)}
        />
      )
      |> React.array}
      <button
        onClick={addQuizQuestion(send)}
        className="flex w-full items-center bg-gray-50 border border-dashed border-primary-400 hover:bg-white hover:text-primary-500 hover:shadow-md focus:bg-white focus:text-primary-500 focus:shadow-md rounded-lg p-3 cursor-pointer my-5">
        <i className="fas fa-plus-circle text-lg" />
        <h5 className="font-semibold ms-2"> {t("add_another_question") |> str} </h5>
      </button>
    </div>
  </div>

let hasValidChecklist = checklist => {
  let requiredSteps = checklist |> Js.Array.filter(item => !(item |> ChecklistItem.optional))

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

let isValidTitle = title => title |> String.trim |> String.length > 0

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
      {state.checklist
      |> Js.Array.mapi((checklistItem, index) => {
        let moveChecklistItemUpCB = index > 0 ? Some(() => send(MoveChecklistItemUp(index))) : None

        let moveChecklistItemDownCB =
          index != Js.Array.length(state.checklist) - 1
            ? Some(() => send(MoveChecklistItemDown(index)))
            : None

        <CurriculumEditor__TargetChecklistItemEditor
          checklist=state.checklist
          key={index |> string_of_int}
          checklistItem
          index
          updateChecklistItemCB={newChecklistItem =>
            send(UpdateChecklistItem(index, newChecklistItem))}
          removeChecklistItemCB={() => send(RemoveChecklistItem(index))}
          ?moveChecklistItemUpCB
          ?moveChecklistItemDownCB
          copyChecklistItemCB={() => send(CopyChecklistItem(index))}
        />
      })
      |> React.array}
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
  let targetId = target |> Target.id
  <div>
    <div className="flex items-center mb-6">
      <label className="block tracking-wide text-sm font-semibold me-1" htmlFor="milestone">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {t("target_setting_milestone.label")->str}
      </label>
      <HelpIcon link={t("target_setting_milestone.help_url")} className="me-6">
        {t("target_setting_milestone.help") |> str}
      </HelpIcon>
      <div id="milestone" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          onClick={updateMilestone(true, send)} className={booleanButtonClasses(state.milestone)}>
          {ts("_yes") |> str}
        </button>
        <button
          onClick={updateMilestone(false, send)} className={booleanButtonClasses(!state.milestone)}>
          {ts("_no") |> str}
        </button>
      </div>
    </div>
    {prerequisiteTargetEditor(send, eligiblePrerequisiteTargets(targetId, targets), state)}
    <div className="flex items-center mb-6">
      <label className="block tracking-wide text-sm font-semibold me-6" htmlFor="evaluated">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {t("target_reviewed_by_coach") |> str}
      </label>
      <div id="evaluated" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          onClick={updateMethodOfCompletion(Evaluated, send)}
          className={booleanButtonClasses(targetEvaluated(state.methodOfCompletion))}>
          {ts("_yes") |> str}
        </button>
        <button
          onClick={updateMethodOfCompletion(SubmitForm, send)}
          className={booleanButtonClasses(!targetEvaluated(state.methodOfCompletion))}>
          {ts("_no") |> str}
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
        {t("assignment_discussion.label") |> str}
      </label>
      <HelpIcon link={t("assignment_discussion.help_url")} className="me-6">
        {t("assignment_discussion.help") |> str}
      </HelpIcon>
      <div id="discussion" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          onClick={updateDiscussion(true, send)} className={booleanButtonClasses(state.discussion)}>
          {ts("_yes") |> str}
        </button>
        <button
          onClick={updateDiscussion(false, send)}
          className={booleanButtonClasses(!state.discussion)}>
          {ts("_no") |> str}
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
              <span className="text-sm"> {t("allow_anonymous.anonymous_text") |> str} </span>
            </button>
            <button
              onClick={updateAllowAnonymous(false, send)}
              className={anonymityClasses(!state.allowAnonymous)}>
              <span className="me-4">
                <Icon className="if i-non-anonymous-light text-3xl" />
              </span>
              <span className="text-sm"> {t("allow_anonymous.no_anonymous") |> str} </span>
            </button>
          </div>
        </div>
      : React.null}
    <div className="mb-6">
      <label className="inline-block tracking-wide text-sm font-semibold" htmlFor="role">
        <span className="me-2">
          <i className="fas fa-list rtl:rotate-180 text-base" />
        </span>
        {t("target_role.label") |> str}
      </label>
      <HelpIcon className="ms-1" link={t("target_role.help_url")}>
        {t("target_role.help") |> str}
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
          <span className="text-sm"> {t("submit_individually") |> str} </span>
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
            {t("one_student_team") |> str}
            <br />
            {t("need_submit") |> str}
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
        {t("completion_instructions.label") |> str}
        <span className="ms-1 text-xs font-normal"> {ts("optional_braces") |> str} </span>
      </label>
      <HelpIcon link={t("completion_instructions.help_url")} className="ms-1">
        {t("completion_instructions.help") |> str}
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
    state.evaluationCriteria |> ArrayUtils.isNotEmpty && isValidChecklist(state.checklist)
  | SubmitForm => state.checklist |> ArrayUtils.isNotEmpty && isValidChecklist(state.checklist)
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
    {t("update_target") |> str}
  </button>
}

let quizAnswersAsJsObject = quizAnswers =>
  quizAnswers |> Array.map(qa =>
    UpdateTargetAssignmentQuery.makeInputObjectAssignmentQuizAnswerInput(
      ~answer=AnswerOption.answer(qa),
      ~correctAnswer=AnswerOption.correctAnswer(qa),
      (),
    )
  )

let quizAsJsObject = quiz =>
  quiz |> Array.map(q =>
    UpdateTargetAssignmentQuery.makeInputObjectAssignmentQuizInput(
      ~question=QuizQuestion.question(q),
      ~answerOptions=quizAnswersAsJsObject(QuizQuestion.answerOptions(q)),
      (),
    )
  )

let updateTargetAssignment = (target, state, send, updateTargetCB, targetGroupId, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateSaving)
  let id = target |> Target.id
  let visibilityAsString = state.visibility |> TargetDetails.visibilityAsString

  let visibility = switch state.visibility {
  | Live => Target.Live
  | Archived => Archived
  | Draft => Draft
  }

  let role = state.role->AssignmentDetails.roleAsString
  let quizAsJs =
    state.quiz
    |> Js.Array.filter(question => QuizQuestion.isValidQuizQuestion(question))
    |> quizAsJsObject

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
    ~checklist=checklist |> ChecklistItem.encodeChecklist,
    ~milestone=state.milestone,
    ~archived=!state.hasAssignment,
    ~discussion=state.discussion,
    ~allowAnonymous=state.allowAnonymous,
    (),
  )

  UpdateTargetAssignmentQuery.make(variables)
  |> Js.Promise.then_(result => {
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
  })
  |> ignore
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
                    {t("title") |> str}
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
                  {t("target_has_assignment") |> str}
                </label>
                <div id="has_assignment" className="flex toggle-button__group shrink-0 rounded-lg">
                  <button
                    onClick={updateHasAssignment(true, send)}
                    className={booleanButtonClasses(state.hasAssignment)}>
                    {ts("_yes") |> str}
                  </button>
                  <button
                    onClick={updateHasAssignment(false, send)}
                    className={booleanButtonClasses(!state.hasAssignment)}>
                    {ts("_no") |> str}
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
                    {t("target_visibility") |> str}
                  </label>
                  <div id="visibility" className="flex toggle-button__group shrink-0 rounded-lg">
                    {[TargetDetails.Live, Archived, Draft]
                    |> Js.Array.mapi((visibility, index) =>
                      <button
                        key={index |> string_of_int}
                        onClick={updateVisibility(visibility, send)}
                        className={booleanButtonClasses(
                          switch (state.visibility, visibility) {
                          | (Live, TargetDetails.Live) => true
                          | (Archived, Archived) => true
                          | (Draft, Draft) => true
                          | _anyOtherCombo => false
                          },
                        )}>
                        {switch visibility {
                        | Live => ts("live")
                        | Archived => ts("archived")
                        | Draft => ts("draft")
                        } |> str}
                      </button>
                    )
                    |> React.array}
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
