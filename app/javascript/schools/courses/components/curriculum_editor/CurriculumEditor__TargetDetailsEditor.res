open CurriculumEditor__Types

@bs.module
external markIcon: string = "./images/target-complete-mark-icon.svg"
@bs.module
external linkIcon: string = "./images/target-complete-link-icon.svg"
@bs.module
external quizIcon: string = "./images/target-complete-quiz-icon.svg"

let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetDetailsEditor")

type methodOfCompletion =
  | Evaluated
  | VisitLink
  | TakeQuiz
  | MarkAsComplete

type evaluationCriterion = (int, string, bool)

type state = {
  title: string,
  targetGroupId: option<string>,
  role: TargetDetails.role,
  evaluationCriteria: array<string>,
  prerequisiteTargets: array<string>,
  prerequisiteSearchInput: string,
  evaluationCriteriaSearchInput: string,
  targetGroupSearchInput: string,
  methodOfCompletion: methodOfCompletion,
  quiz: array<QuizQuestion.t>,
  linkToComplete: string,
  dirty: bool,
  saving: bool,
  loading: bool,
  visibility: TargetDetails.visibility,
  checklist: array<ChecklistItem.t>,
  completionInstructions: string,
  targetDetails: option<TargetDetails.t>,
}

type action =
  | SaveTargetDetails(TargetDetails.t)
  | UpdateTitle(string)
  | UpdatePrerequisiteTargets(array<string>)
  | UpdateMethodOfCompletion(methodOfCompletion)
  | UpdateEvaluationCriteria(array<string>)
  | UpdatePrerequisiteSearchInput(string)
  | UpdateEvaluationCriteriaSearchInput(string)
  | UpdateTargetGroupSearchInput(string)
  | UpdateTargetGroup(string)
  | UpdateTargetGroupAndClearPrerequisiteTargets(string)
  | UpdateLinkToComplete(string)
  | UpdateCompletionInstructions(string)
  | UpdateTargetRole(TargetDetails.role)
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

module TargetDetailsQuery = %graphql(
  `
    query TargetDetailsQuery($targetId: ID!) {
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
        checklist
      }
  }
`
)

let loadTargetDetails = (targetId, send) =>
  TargetDetailsQuery.make(~targetId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(result => {
    let targetDetails = TargetDetails.makeFromJs(result["targetDetails"])
    send(SaveTargetDetails(targetDetails))
    Js.Promise.resolve()
  }) |> ignore

let defaultChecklist = [
  ChecklistItem.make(~title="Describe your submission", ~kind=LongText, ~optional=false),
]

let computeMethodOfCompletion = targetDetails => {
  let hasQuiz = targetDetails |> TargetDetails.quiz |> ArrayUtils.isNotEmpty
  let hasEvaluationCriteria = targetDetails.evaluationCriteria |> ArrayUtils.isNotEmpty
  let hasLinkToComplete = switch targetDetails.linkToComplete {
  | Some(_) => true
  | None => false
  }
  switch (hasEvaluationCriteria, hasQuiz, hasLinkToComplete) {
  | (true, _y, _z) => Evaluated
  | (_x, true, _z) => TakeQuiz
  | (_x, _y, true) => VisitLink
  | (false, false, false) => MarkAsComplete
  }
}

let reducer = (state, action) =>
  switch action {
  | SaveTargetDetails(targetDetails) =>
    let methodOfCompletion = computeMethodOfCompletion(targetDetails)
    let checklist =
      targetDetails.checklist |> ArrayUtils.isNotEmpty ? targetDetails.checklist : defaultChecklist
    let quiz =
      targetDetails.quiz |> ArrayUtils.isNotEmpty ? targetDetails.quiz : [QuizQuestion.empty("0")]
    {
      ...state,
      title: targetDetails.title,
      role: targetDetails.role,
      targetGroupId: Some(targetDetails.targetGroupId),
      evaluationCriteria: targetDetails.evaluationCriteria,
      prerequisiteTargets: targetDetails.prerequisiteTargets,
      methodOfCompletion: methodOfCompletion,
      linkToComplete: switch targetDetails.linkToComplete {
      | Some(link) => link
      | None => ""
      },
      quiz: quiz,
      completionInstructions: switch targetDetails.completionInstructions {
      | Some(instructions) => instructions
      | None => ""
      },
      visibility: targetDetails.visibility,
      checklist: checklist,
      loading: false,
      targetDetails: Some(targetDetails),
    }
  | UpdateTitle(title) => {...state, title: title, dirty: true}
  | UpdatePrerequisiteTargets(prerequisiteTargets) => {
      ...state,
      prerequisiteTargets: prerequisiteTargets,
      prerequisiteSearchInput: "",
      dirty: true,
    }
  | UpdatePrerequisiteSearchInput(prerequisiteSearchInput) => {
      ...state,
      prerequisiteSearchInput: prerequisiteSearchInput,
    }
  | UpdateMethodOfCompletion(methodOfCompletion) => {
      ...state,
      methodOfCompletion: methodOfCompletion,
      dirty: true,
    }
  | UpdateEvaluationCriteria(evaluationCriteria) => {
      ...state,
      evaluationCriteria: evaluationCriteria,
      evaluationCriteriaSearchInput: "",
      dirty: true,
    }
  | UpdateEvaluationCriteriaSearchInput(evaluationCriteriaSearchInput) => {
      ...state,
      evaluationCriteriaSearchInput: evaluationCriteriaSearchInput,
    }
  | UpdateLinkToComplete(linkToComplete) => {
      ...state,
      linkToComplete: linkToComplete,
      dirty: true,
    }
  | UpdateCompletionInstructions(instruction) => {
      ...state,
      completionInstructions: instruction,
      dirty: true,
    }
  | UpdateTargetRole(role) => {...state, role: role, dirty: true}
  | AddQuizQuestion =>
    let quiz = Js.Array.concat([QuizQuestion.empty(Js.Date.now() |> Js.Float.toString)], state.quiz)
    {...state, quiz: quiz, dirty: true}
  | UpdateQuizQuestion(id, quizQuestion) =>
    let quiz = state.quiz |> Js.Array.map(q => QuizQuestion.id(q) == id ? quizQuestion : q)
    {...state, quiz: quiz, dirty: true}
  | RemoveQuizQuestion(id) =>
    let quiz = state.quiz |> Js.Array.filter(q => QuizQuestion.id(q) != id)
    {...state, quiz: quiz, dirty: true}
  | UpdateVisibility(visibility) => {...state, visibility: visibility, dirty: true}
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
      targetGroupSearchInput: targetGroupSearchInput,
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
  }

let updateTitle = (send, event) => {
  let title = ReactEvent.Form.target(event)["value"]
  send(UpdateTitle(title))
}

let eligiblePrerequisiteTargets = (targetId, targetGroupId, targets, targetGroups) =>
  targetGroupId->Belt.Option.mapWithDefault([], targetGroupId => {
    let targetGroup =
      targetGroupId |> TargetGroup.unsafeFind(
        targetGroups,
        "TargetDetailsEditor.eligiblePrerequisiteTargets",
      )

    let levelId = targetGroup |> TargetGroup.levelId
    let targetGroupsInSameLevel =
      targetGroups
      |> Js.Array.filter(tg => TargetGroup.levelId(tg) == levelId)
      |> Js.Array.map(TargetGroup.id)

    targets
    |> Js.Array.filter(target => !Target.archived(target))
    |> Js.Array.filter(target =>
      targetGroupsInSameLevel |> Js.Array.includes(Target.targetGroupId(target))
    )
    |> Js.Array.filter(target => Target.id(target) != targetId)
  })

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
          <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
          {t("prerequisite_targets_label") |> str}
        </label>
        <div id="prerequisite_targets" className="mb-6 ml-6">
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
    : ReasonReact.null
}

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button"
  classes ++ (bool ? " toggle-button__button--active" : "")
}

let targetRoleClasses = selected =>
  "w-1/2 target-editor__completion-button relative flex border text-sm font-semibold focus:outline-none rounded px-5 py-4 md:px-8 md:py-5 items-center cursor-pointer text-left " ++ (
    selected
      ? "target-editor__completion-button--selected bg-gray-200 text-primary-500 border-primary-500"
      : "border-gray-400 hover:bg-gray-200 bg-white"
  )

let targetEvaluated = methodOfCompletion =>
  switch methodOfCompletion {
  | Evaluated => true
  | VisitLink => false
  | TakeQuiz => false
  | MarkAsComplete => false
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
        "Could not find selected evaluation criterion with ID " ++ ecId,
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
      className="block tracking-wide text-sm font-semibold mr-6 mb-2" htmlFor="evaluation_criteria">
      <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
      {t("select_criterion_label") |> str}
    </label>
    <div className="ml-6">
      {validNumberOfEvaluationCriteria(state)
        ? React.null
        : <div className="drawer-right-form__error-msg mb-2">
            {t("select_criterion_warning") |> str}
          </div>}
      <MultiSelectForEvaluationCriteria
        placeholder="Search evaluation criteria"
        emptySelectionMessage="No criteria selected"
        allItemsSelectedMessage="You have selected all evaluation criteria!"
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

let updateLinkToComplete = (send, event) =>
  send(UpdateLinkToComplete(ReactEvent.Form.target(event)["value"]))

let updateCompletionInstructions = (send, event) =>
  send(UpdateCompletionInstructions(ReactEvent.Form.target(event)["value"]))

let updateMethodOfCompletion = (methodOfCompletion, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateMethodOfCompletion(methodOfCompletion))
}

let updateTargetRole = (role, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateTargetRole(role))
}

let updateVisibility = (visibility, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateVisibility(visibility))
}

let linkEditor = (state, send) =>
  <div className="mb-6">
    <label className="inline-block tracking-wide text-sm font-semibold" htmlFor="link_to_complete">
      <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
      {"Link to complete" |> str}
    </label>
    <div className="ml-6">
      <input
        className="appearance-none block text-sm w-full bg-white border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-gray-500"
        id="link_to_complete"
        type_="text"
        placeholder="Paste link to complete"
        value=state.linkToComplete
        onChange={updateLinkToComplete(send)}
      />
      {state.linkToComplete |> UrlUtils.isInvalid(false)
        ? <School__InputGroupError message="Enter a valid link" active=true />
        : React.null}
    </div>
  </div>

module SelectableTargetGroup = {
  type t = {
    level: Level.t,
    targetGroup: TargetGroup.t,
  }

  let id = t => t.targetGroup |> TargetGroup.id

  let label = _t => None

  let value = t => LevelLabel.format(~name=(t.targetGroup |> TargetGroup.name), (t.level |> Level.number |> string_of_int))

  let searchString = t => t |> value

  let color = _t => "orange"

  let level = t => t.level

  let make = (level, targetGroup) => {level: level, targetGroup: targetGroup}
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
    <label className="block tracking-wide text-sm font-semibold mr-6 mb-2" htmlFor="target_group">
      <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
      {t("target_group") |> str}
    </label>
    <div className="ml-6">
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
  let defaultClasses = "target-editor__completion-button relative flex flex-col items-center bg-white border border-gray-400 hover:bg-gray-200 text-sm font-semibold focus:outline-none rounded p-4"
  value
    ? defaultClasses ++ " target-editor__completion-button--selected bg-gray-200 text-primary-500 border-primary-500"
    : defaultClasses ++ " opacity-75 text-gray-900"
}

let methodOfCompletionSelection = polyMethodOfCompletion =>
  switch polyMethodOfCompletion {
  | #TakeQuiz => TakeQuiz
  | #VisitLink => VisitLink
  | #MarkAsComplete => MarkAsComplete
  }

let methodOfCompletionButton = (methodOfCompletion, state, send, index) => {
  let buttonString = switch methodOfCompletion {
  | #TakeQuiz => t("take_quiz")
  | #VisitLink => t("visit_link")
  | #MarkAsComplete => t("mark_as_complete")
  }

  let selected = switch (state.methodOfCompletion, methodOfCompletion) {
  | (TakeQuiz, #TakeQuiz) => true
  | (VisitLink, #VisitLink) => true
  | (MarkAsComplete, #MarkAsComplete) => true
  | _anyOtherCombo => false
  }

  let icon = switch methodOfCompletion {
  | #TakeQuiz => quizIcon
  | #VisitLink => linkIcon
  | #MarkAsComplete => markIcon
  }

  <div key={index |> string_of_int} className="w-1/3 px-2">
    <button
      onClick={updateMethodOfCompletion(methodOfCompletion |> methodOfCompletionSelection, send)}
      className={methodOfCompletionButtonClasses(selected)}>
      <div className="mb-1"> <img className="w-12 h-12" src=icon /> </div> {buttonString |> str}
    </button>
  </div>
}

let methodOfCompletionSelector = (state, send) =>
  <div>
    <div className="mb-6">
      <label
        className="block tracking-wide text-sm font-semibold mr-6 mb-3"
        htmlFor="method_of_completion">
        <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
        {t("target_method_of_completion_label") |> str}
      </label>
      <div id="method_of_completion" className="flex -mx-2 pl-6">
        {[#MarkAsComplete, #VisitLink, #TakeQuiz]
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
      className="block tracking-wide text-sm font-semibold mr-6 mb-3" htmlFor="Quiz question 1">
      <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
      {"Prepare the quiz now." |> str}
    </label>
    <div className="ml-6">
      {isValidQuiz(state.quiz)
        ? ReasonReact.null
        : <School__InputGroupError
            message="All questions must be filled in, and all questions should have at least two answers."
            active=true
          />}
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
      |> ReasonReact.array}
      <a
        onClick={addQuizQuestion(send)}
        className="flex items-center bg-gray-200 border border-dashed border-primary-400 hover:bg-white hover:text-primary-500 hover:shadow-md rounded-lg p-3 cursor-pointer my-5">
        <i className="fas fa-plus-circle text-lg" />
        <h5 className="font-semibold ml-2"> {"Add another Question" |> str} </h5>
      </a>
    </div>
  </div>

let doRequiredStepsHaveUniqueTitles = checklist => {
  let requiredSteps = checklist |> Js.Array.filter(item => !(item |> ChecklistItem.optional))

  requiredSteps
  |> Js.Array.map(ChecklistItem.title)
  |> Js.Array.map(String.trim)
  |> ArrayUtils.distinct
  |> Js.Array.length == Js.Array.length(requiredSteps)
}

let isValidTitle = title => title |> String.trim |> String.length > 0

let isValidMethodOfCompletion = state =>
  switch state.methodOfCompletion {
  | TakeQuiz => isValidQuiz(state.quiz)
  | MarkAsComplete => true
  | Evaluated =>
    state.evaluationCriteria |> ArrayUtils.isNotEmpty && isValidChecklist(state.checklist)
  | VisitLink => !(state.linkToComplete |> UrlUtils.isInvalid(false))
  }

let saveDisabled = (
  ~hasValidTitle,
  ~hasValidMethodOfCompletion,
  ~requiredStepsHaveUniqueTitles,
  ~dirty,
  ~saving,
) =>
  !requiredStepsHaveUniqueTitles ||
  (!hasValidTitle ||
  (!hasValidMethodOfCompletion || (!dirty || saving)))

module UpdateTargetQuery = %graphql(
  `
   mutation UpdateTargetMutation($id: ID!, $targetGroupId: ID!, $title: String!, $role: String!, $evaluationCriteria: [ID!]!,$prerequisiteTargets: [ID!]!, $quiz: [TargetQuizInput!]!, $completionInstructions: String, $linkToComplete: String, $visibility: String!, $checklist: JSON! ) {
     updateTarget(id: $id, targetGroupId: $targetGroupId, title: $title, role: $role, evaluationCriteria: $evaluationCriteria,prerequisiteTargets: $prerequisiteTargets, quiz: $quiz, completionInstructions: $completionInstructions, linkToComplete: $linkToComplete, visibility: $visibility, checklist: $checklist  ) {
        sortIndex
       }
     }
   `
)

let updateTargetButton = (
  ~callback,
  ~state,
  ~hasValidTitle,
  ~hasValidMethodOfCompletion,
  ~requiredStepsHaveUniqueTitles,
) => {
  let onClick = Belt.Option.map(state.targetGroupId, callback)
  let disabled =
    !requiredStepsHaveUniqueTitles ||
    (!hasValidTitle ||
    (!hasValidMethodOfCompletion || (!state.dirty || (state.saving || onClick == None))))

  <button
    key="target-actions-step"
    ?onClick
    disabled
    className="btn btn-primary w-full text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
    {t("update_target") |> str}
  </button>
}

let updateTarget = (target, state, send, updateTargetCB, targetGroupId, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateSaving)
  let id = target |> Target.id
  let role = state.role |> TargetDetails.roleAsString
  let visibilityAsString = state.visibility |> TargetDetails.visibilityAsString
  let quizAsJs =
    state.quiz
    |> Js.Array.filter(question => QuizQuestion.isValidQuizQuestion(question))
    |> QuizQuestion.quizAsJsObject

  let (quiz, evaluationCriteria, linkToComplete, checklist) = switch state.methodOfCompletion {
  | Evaluated => ([], state.evaluationCriteria, "", state.checklist)
  | VisitLink => ([], [], state.linkToComplete, [])
  | TakeQuiz => (quizAsJs, [], "", [])
  | MarkAsComplete => ([], [], "", [])
  }

  let visibility = switch state.visibility {
  | Live => Target.Live
  | Archived => Archived
  | Draft => Draft
  }

  UpdateTargetQuery.make(
    ~id,
    ~targetGroupId,
    ~title=state.title,
    ~role,
    ~evaluationCriteria,
    ~prerequisiteTargets=state.prerequisiteTargets,
    ~quiz,
    ~completionInstructions=state.completionInstructions,
    ~linkToComplete,
    ~visibility=visibilityAsString,
    ~checklist=checklist |> ChecklistItem.encodeChecklist,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
    switch result["updateTarget"]["sortIndex"] {
    | Some(sortIndex) =>
      send(ResetEditor)
      updateTargetCB(
        Target.create(~id, ~targetGroupId, ~title=state.title, ~sortIndex, ~visibility),
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
      role: TargetDetails.Student,
      evaluationCriteria: [],
      evaluationCriteriaSearchInput: "",
      prerequisiteTargets: [],
      prerequisiteSearchInput: "",
      methodOfCompletion: Evaluated,
      quiz: [],
      linkToComplete: "",
      dirty: false,
      saving: false,
      loading: true,
      checklist: [],
      visibility: TargetDetails.Draft,
      completionInstructions: "",
      targetGroupSearchInput: "",
      targetDetails: None,
    },
  )
  let targetId = target |> Target.id
  React.useEffect1(() => {
    loadTargetDetails(targetId, send)
    None
  }, [targetId])

  React.useEffect1(() => {
    setDirtyCB(state.dirty)
    None
  }, [state.dirty])

  let requiredStepsHaveUniqueTitles = doRequiredStepsHaveUniqueTitles(state.checklist)
  let hasValidTitle = isValidTitle(state.title)
  let hasValidMethodOfCompletion = isValidMethodOfCompletion(state)

  <div className="pt-6" id="target-properties">
    {state.loading
      ? <div className="max-w-3xl mx-auto px-3">
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.contents())}
        </div>
      : <DisablingCover message="Saving..." disabled=state.saving>
          <div className="mt-2">
            <div className="max-w-3xl mx-auto px-3">
              <div className="mb-6">
                <label
                  className="flex items-center inline-block tracking-wide text-sm font-semibold mb-2"
                  htmlFor="title">
                  <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
                  {"Title" |> str}
                </label>
                <div className="ml-6">
                  <input
                    className="appearance-none block text-sm w-full bg-white border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-gray-500"
                    id="title"
                    type_="text"
                    placeholder={t("target_title_placeholder")}
                    onChange={updateTitle(send)}
                    value=state.title
                  />
                  <School__InputGroupError message="Enter a valid title" active={!hasValidTitle} />
                </div>
              </div>
              {targetGroupEditor(state, targetGroups, levels, send)}
              {prerequisiteTargetEditor(
                send,
                eligiblePrerequisiteTargets(targetId, state.targetGroupId, targets, targetGroups),
                state,
              )}
              <div className="flex items-center mb-6">
                <label
                  className="block tracking-wide text-sm font-semibold mr-6" htmlFor="evaluated">
                  <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
                  {t("target_reviewed_by_coach") |> str}
                </label>
                <div id="evaluated" className="flex toggle-button__group flex-shrink-0 rounded-lg">
                  <button
                    onClick={updateMethodOfCompletion(Evaluated, send)}
                    className={booleanButtonClasses(targetEvaluated(state.methodOfCompletion))}>
                    {"Yes" |> str}
                  </button>
                  <button
                    onClick={updateMethodOfCompletion(MarkAsComplete, send)}
                    className={booleanButtonClasses(!targetEvaluated(state.methodOfCompletion))}>
                    {"No" |> str}
                  </button>
                </div>
              </div>
              {switch state.methodOfCompletion {
              | Evaluated =>
                <div className="mb-6">
                  <label className="tracking-wide text-sm font-semibold" htmlFor="target_checklist">
                    <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
                    {t("target_checklist_label") |> str}
                  </label>
                  <HelpIcon
                    className="ml-1"
                    link="https://docs.pupilfirst.com/#/curriculum_editor?id=defining-steps-to-complete-a-target">
                    {t("target_checklist_help_text") |> str}
                  </HelpIcon>
                  <div className="ml-6 mb-6">
                    {
                      let allowFileKind =
                        state.checklist
                        |> Js.Array.filter(item => item |> ChecklistItem.isFilesKind)
                        |> ArrayUtils.isEmpty

                      state.checklist |> Js.Array.mapi((checklistItem, index) => {
                        let moveChecklistItemUpCB =
                          index > 0 ? Some(() => send(MoveChecklistItemUp(index))) : None

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
                          allowFileKind
                        />
                      }) |> React.array
                    }
                    {state.checklist |> ArrayUtils.isEmpty
                      ? <div
                          className="border border-orange-500 bg-orange-100 text-orange-800 px-2 py-1 rounded my-2 text-sm text-center">
                          <i className="fas fa-info-circle mr-2" />
                          {t("empty_checklist_warning") |> str}
                        </div>
                      : React.null}
                    {state.checklist |> Js.Array.length >= 15
                      ? <div
                          className="border border-orange-500 bg-orange-100 text-orange-800 px-2 py-1 rounded my-2 text-sm text-center">
                          <i className="fas fa-info-circle mr-2" />
                          {t("target_checklist_limit_warning") |> str}
                        </div>
                      : React.null}
                    <button
                      className="flex justify-center items-center w-full rounded-lg border border-dashed border-primary-500 mt-2 p-2 text-sm text-primary-500 focus:outline-none hover:shadow-lg"
                      disabled={state.checklist |> Js.Array.length >= 15}
                      onClick={_ => send(AddNewChecklistItem)}>
                      <PfIcon className="fas fa-plus-circle text-lg" />
                      <span className="font-semibold ml-2"> {"Add a Step" |> str} </span>
                    </button>
                  </div>
                </div>
              | VisitLink
              | TakeQuiz
              | MarkAsComplete => React.null
              }}
              {targetEvaluated(state.methodOfCompletion)
                ? React.null
                : methodOfCompletionSelector(state, send)}
              {switch state.methodOfCompletion {
              | Evaluated => evaluationCriteriaEditor(state, evaluationCriteria, send)
              | MarkAsComplete => React.null
              | TakeQuiz => quizEditor(state, send)
              | VisitLink => linkEditor(state, send)
              }}
              <div className="mb-6">
                <label className="inline-block tracking-wide text-sm font-semibold" htmlFor="role">
                  <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
                  {t("target_role_label") |> str}
                </label>
                <HelpIcon
                  className="ml-1"
                  link="https://docs.pupilfirst.com/#/curriculum_editor?id=setting-the-method-of-completion">
                  {t("target_role_help") |> str}
                </HelpIcon>
                <div id="role" className="flex mt-4 ml-6">
                  <button
                    onClick={updateTargetRole(TargetDetails.Student, send)}
                    className={"mr-4 " ++
                    targetRoleClasses(
                      switch state.role {
                      | TargetDetails.Student => true
                      | Team => false
                      },
                    )}>
                    <span className="mr-4">
                      <Icon className="if i-users-check-light text-3xl" />
                    </span>
                    <span className="text-sm">
                      {"All students must submit individually." |> str}
                    </span>
                  </button>
                  <button
                    onClick={updateTargetRole(TargetDetails.Team, send)}
                    className={targetRoleClasses(
                      switch state.role {
                      | TargetDetails.Team => true
                      | Student => false
                      },
                    )}>
                    <span className="mr-4">
                      <Icon className="if i-user-check-light text-2xl" />
                    </span>
                    <span className="text-sm">
                      {"Only one student in a team" |> str} <br /> {" needs to submit." |> str}
                    </span>
                  </button>
                </div>
              </div>
              <div className="mb-6">
                <label
                  className="tracking-wide text-sm font-semibold" htmlFor="completion-instructions">
                  <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
                  {t("completion_instructions_label") |> str}
                  <span className="ml-1 text-xs font-normal"> {"(optional)" |> str} </span>
                </label>
                <HelpIcon
                  link="https://docs.pupilfirst.com/#/curriculum_editor?id=setting-the-method-of-completion"
                  className="ml-1">
                  {t("completion_instructions_help") |> str}
                </HelpIcon>
                <div className="ml-6">
                  <input
                    className="appearance-none block text-sm w-full bg-white border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-gray-500"
                    id="completion-instructions"
                    type_="text"
                    maxLength=255
                    value=state.completionInstructions
                    onChange={updateCompletionInstructions(send)}
                  />
                </div>
              </div>
            </div>
            <div className="bg-white border-t sticky bottom-0 py-5">
              <div className="flex max-w-3xl mx-auto px-3 justify-between items-center">
                <div className="flex items-center flex-shrink-0">
                  <label
                    className="block tracking-wide text-sm font-semibold mr-3" htmlFor="archived">
                    <span className="mr-2"> <i className="fas fa-list text-base" /> </span>
                    {t("target_visibility") |> str}
                  </label>
                  <div
                    id="visibility" className="flex toggle-button__group flex-shrink-0 rounded-lg">
                    {[TargetDetails.Live, Archived, Draft] |> Js.Array.mapi((visibility, index) =>
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
                        | Live => "Live"
                        | Archived => "Archived"
                        | Draft => "Draft"
                        } |> str}
                      </button>
                    ) |> React.array}
                  </div>
                </div>
                <div className="w-auto">
                  {updateTargetButton(
                    ~callback=updateTarget(target, state, send, updateTargetCB),
                    ~state,
                    ~hasValidTitle,
                    ~hasValidMethodOfCompletion,
                    ~requiredStepsHaveUniqueTitles,
                  )}
                </div>
              </div>
            </div>
          </div>
        </DisablingCover>}
  </div>
}
