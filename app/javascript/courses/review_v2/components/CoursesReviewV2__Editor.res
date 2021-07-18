%bs.raw(`require("./CoursesReview__Editor.css")`)

open CoursesReview__Types
let str = React.string

type status =
  | Graded(bool)
  | Grading
  | Ungraded

type editor =
  | GradesEditor
  | ChecklistEditor
  | ReviewedSubmissionEditor(array<Grade.t>)

type state = {
  grades: array<Grade.t>,
  newFeedback: string,
  saving: bool,
  checklist: array<SubmissionChecklistItem.t>,
  note: option<string>,
  editor: editor,
  additonalFeedbackEditorVisible: bool,
}

type action =
  | BeginSaving
  | FinishSaving
  | UpdateFeedback(string)
  | GenerateFeeback(string, editor)
  | UpdateGrades(array<Grade.t>)
  | UpdateChecklist(array<SubmissionChecklistItem.t>)
  | UpdateNote(string)
  | ShowGradesEditor
  | ShowChecklistEditor
  | ShowAdditionalFeedbackEditor
  | FeedbackAfterSave
  | UpdateEditor(editor)
  | FinishGrading(array<Grade.t>)

let reducer = (state, action) =>
  switch action {
  | BeginSaving => {...state, saving: true}
  | FinishSaving => {...state, saving: false}
  | UpdateFeedback(newFeedback) => {...state, newFeedback: newFeedback}
  | GenerateFeeback(newFeedback, editor) => {...state, newFeedback: newFeedback, editor: editor}
  | UpdateGrades(grades) => {...state, grades: grades}
  | UpdateChecklist(checklist) => {...state, checklist: checklist}
  | UpdateNote(note) => {...state, note: Some(note)}
  | ShowGradesEditor => {...state, editor: GradesEditor}
  | ShowChecklistEditor => {...state, editor: ChecklistEditor}
  | ShowAdditionalFeedbackEditor => {...state, additonalFeedbackEditorVisible: true}
  | FinishGrading(grades) => {...state, editor: ReviewedSubmissionEditor(grades), saving: false}
  | UpdateEditor(editor) => {...state, editor: editor}
  | FeedbackAfterSave => {
      ...state,
      saving: false,
      additonalFeedbackEditorVisible: false,
      newFeedback: "",
    }
  }

module CreateGradingMutation = %graphql(
  `
    mutation CreateGradingMutation($submissionId: ID!, $feedback: String, $grades: [GradeInput!]!, $note: String,  $checklist: JSON!) {
      createGrading(submissionId: $submissionId, feedback: $feedback, grades: $grades, note: $note, checklist: $checklist){
        success
      }
    }
  `
)

module UndoGradingMutation = %graphql(
  `
    mutation UndoGradingMutation($submissionId: ID!) {
      undoGrading(submissionId: $submissionId){
        success
      }
    }
  `
)

module CreateFeedbackMutation = %graphql(
  `
    mutation CreateFeedbackMutation($submissionId: ID!, $feedback: String!) {
      createFeedback(submissionId: $submissionId, feedback: $feedback){
        success
      }
    }
  `
)
let makeFeedback = (user, feedback) => {
  Feedback.make(
    ~coachName=Some(User.name(user)),
    ~coachAvatarUrl=User.avatarUrl(user),
    ~coachTitle=User.title(user),
    ~createdAt=Js.Date.make(),
    ~value=feedback,
  )
}
let createFeedback = (
  submissionId,
  feedback,
  send,
  overlaySubmission,
  user,
  updateSubmissionCB,
) => {
  send(BeginSaving)

  CreateFeedbackMutation.make(~submissionId, ~feedback, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["createFeedback"]["success"]
      ? {
          updateSubmissionCB(
            OverlaySubmission.updateFeedback(
              Js.Array.concat(
                [makeFeedback(user, feedback)],
                OverlaySubmission.feedback(overlaySubmission),
              ),
              overlaySubmission,
            ),
          )

          send(FeedbackAfterSave)
        }
      : send(FinishSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let undoGrading = (submissionId, send) => {
  send(BeginSaving)

  UndoGradingMutation.make(~submissionId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["undoGrading"]["success"] ? DomUtils.reload() |> ignore : send(FinishSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let passed = (grades, evaluationCriteria) => Js.Array.filter(g => {
    let passGrade = EvaluationCriterion.passGrade(
      ArrayUtils.unsafeFind(
        ec => EvaluationCriterion.id(ec) == Grade.evaluationCriterionId(g),
        "CoursesReview__GradeCard: Unable to find evaluation criterion with id - " ++
        Grade.evaluationCriterionId(g),
        evaluationCriteria,
      ),
    )

    Grade.value(g) < passGrade
  }, grades)->ArrayUtils.isEmpty

let trimToOption = s => Js.String.trim(s) == "" ? None : Some(s)

let gradeSubmissionQuery = (
  submissionId,
  state,
  send,
  evaluationCriteria,
  overlaySubmission,
  user,
  updateSubmissionCB,
) => {
  send(BeginSaving)
  let feedback = trimToOption(state.newFeedback)
  let grades = Js.Array.map(g => Grade.asJsType(g), state.grades)

  CreateGradingMutation.make(
    ~submissionId,
    ~feedback?,
    ~note=?Belt.Option.flatMap(state.note, trimToOption),
    ~grades,
    ~checklist=SubmissionChecklistItem.encodeArray(state.checklist),
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["createGrading"]["success"]
      ? {
          updateSubmissionCB(
            OverlaySubmission.update(
              passed(state.grades, evaluationCriteria) ? Some(Js.Date.make()) : None,
              Some("Foo"),
              Js.Array.concat(
                Belt.Option.mapWithDefault(feedback, [], f => [makeFeedback(user, f)]),
                OverlaySubmission.feedback(overlaySubmission),
              ),
              state.grades,
              Some(Js.Date.make()),
              state.checklist,
              overlaySubmission,
            ),
          )
          send(FinishGrading(state.grades))
        }
      : send(FinishSaving)

    Js.Promise.resolve()
  })
  |> ignore
}

let updateGrading = (grade, state, send) => {
  let newGrades = Js.Array.concat(
    [grade],
    Js.Array.filter(
      g => Grade.evaluationCriterionId(g) != Grade.evaluationCriterionId(grade),
      state.grades,
    ),
  )

  send(UpdateGrades(newGrades))
}

let handleGradePillClick = (evaluationCriterionId, value, state, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  switch send {
  | Some(send) => updateGrading(Grade.make(~evaluationCriterionId, ~value), state, send)
  | None => ()
  }
}

let findEvaluationCriterion = (evaluationCriteria, evaluationCriterionId) =>
  switch Js.Array.find(
    ec => EvaluationCriterion.id(ec) == evaluationCriterionId,
    evaluationCriteria,
  ) {
  | Some(ec) => ec
  | None =>
    Rollbar.error(
      "Unable to find evaluation Criterion with id: " ++
      (evaluationCriterionId ++
      "in CoursesRevew__GradeCard"),
    )
    evaluationCriteria[0]
  }

let gradePillHeader = (evaluationCriteriaName, selectedGrade, gradeLabels) =>
  <div className="flex justify-between">
    <p className="text-xs font-semibold"> {evaluationCriteriaName->str} </p>
    <p className="text-xs font-semibold">
      {(selectedGrade->string_of_int ++
        ("/" ++
        GradeLabel.maxGrade(Array.to_list(gradeLabels))->string_of_int))->str}
    </p>
  </div>

let gradePillClasses = (selectedGrade, currentGrade, passgrade, send) => {
  let defaultClasses =
    "course-review-editor__grade-pill border-gray-400 py-1 px-2 text-sm flex-1 font-semibold " ++
    switch send {
    | Some(_) =>
      "cursor-pointer hover:shadow-lg focus:outline-none " ++ (
        currentGrade >= passgrade
          ? "hover:bg-green-500 hover:text-white "
          : "hover:bg-red-500 hover:text-white "
      )

    | None => ""
    }

  defaultClasses ++ (
    currentGrade <= selectedGrade
      ? switch selectedGrade >= passgrade {
        | true => "bg-green-500 text-white shadow-lg"
        | false => "bg-red-500 text-white shadow-lg"
        }
      : "bg-white text-gray-900"
  )
}

let showGradePill = (key, evaluationCriterion, gradeValue, passGrade, state, send) =>
  <div
    ariaLabel={"evaluation-criterion-" ++ EvaluationCriterion.id(evaluationCriterion)}
    key={key |> string_of_int}
    className="mt-2">
    {gradePillHeader(
      evaluationCriterion |> EvaluationCriterion.name,
      gradeValue,
      evaluationCriterion |> EvaluationCriterion.gradesAndLabels,
    )}
    <div className="course-review-editor__grade-bar inline-flex w-full text-center mt-1">
      {evaluationCriterion |> EvaluationCriterion.gradesAndLabels |> Array.map(gradeLabel => {
        let gradeLabelGrade = gradeLabel |> GradeLabel.grade

        <button
          key={string_of_int(gradeLabelGrade)}
          onClick={handleGradePillClick(
            evaluationCriterion |> EvaluationCriterion.id,
            gradeLabelGrade,
            state,
            send,
          )}
          title={GradeLabel.label(gradeLabel)}
          className={gradePillClasses(gradeValue, gradeLabelGrade, passGrade, send)}>
          {switch send {
          | Some(_) => string_of_int(gradeLabelGrade)->str
          | None => React.null
          }}
        </button>
      }) |> React.array}
    </div>
  </div>

let showGrades = (grades, evaluationCriteria, state) =>
  <div> {grades |> Grade.sort(evaluationCriteria) |> Array.mapi((key, grade) => {
      let gradeEcId = Grade.evaluationCriterionId(grade)
      let ec =
        evaluationCriteria |> ArrayUtils.unsafeFind(
          ec => ec |> EvaluationCriterion.id == gradeEcId,
          "Unable to find evaluation Criterion with id: " ++
          (gradeEcId ++
          "in CoursesRevew__GradeCard"),
        )

      showGradePill(key, ec, grade |> Grade.value, ec |> EvaluationCriterion.passGrade, state, None)
    }) |> React.array} </div>
let renderGradePills = (evaluationCriteria, targetEvaluationCriteriaIds, state, send) =>
  targetEvaluationCriteriaIds |> Array.mapi((key, evaluationCriterionId) => {
    let ec =
      evaluationCriteria |> ArrayUtils.unsafeFind(
        e => e |> EvaluationCriterion.id == evaluationCriterionId,
        "CoursesReview__GradeCard: Unable to find evaluation criterion with id - " ++
        evaluationCriterionId,
      )
    let grade =
      state.grades |> Js.Array.find(g =>
        g |> Grade.evaluationCriterionId == (ec |> EvaluationCriterion.id)
      )
    let gradeValue = switch grade {
    | Some(g) => g |> Grade.value
    | None => 0
    }

    let passGrade = ec |> EvaluationCriterion.passGrade

    showGradePill(key, ec, gradeValue, passGrade, state, Some(send))
  }) |> React.array
let gradeStatusClasses = (color, status) =>
  "w-12 h-10 p-1 mr-2 md:mr-0 md:w-26 md:h-22 rounded md:rounded-lg border flex justify-center items-center bg-" ++
  (color ++
  ("-100 " ++
  ("border-" ++
  (color ++
  ("-400 " ++
  switch status {
  | Grading => "course-review-editor__status-pulse"
  | Graded(_)
  | Ungraded => ""
  })))))

let gradeBadgeClasses = (color, status) =>
  "px-2 py-2 space-x-2 flex justify-center border rounded items-center bg-" ++
  (color ++
  ("-100 " ++
  ("border-" ++
  (color ++
  ("-400 " ++
  switch status {
  | Grading => "course-review-editor__status-pulse"
  | Graded(_)
  | Ungraded => ""
  })))))

let submissionReviewStatus = (status, overlaySubmission) => {
  let (text, color) = switch status {
  | Graded(passed) => passed ? ("Completed", "green") : ("Rejected", "red")
  | Grading => ("Reviewing", "orange")
  | Ungraded => ("Pending Review", "gray")
  }
  <div ariaLabel="submission-status" className="hidden md:flex space-x-4 justify-end w-3/4">
    <div className="flex items-center">
      {switch (overlaySubmission |> OverlaySubmission.evaluatedAt, status) {
      | (Some(date), Graded(_)) =>
        <div>
          <div>
            <p className="text-xs text-gray-800"> {"Evaluated By" |> str} </p>
            <p className="text-xs font-semibold">
              {switch overlaySubmission |> OverlaySubmission.evaluatorName {
              | Some(name) => name |> str
              | None => <em> {"Deleted Coach" |> str} </em>
              }}
            </p>
          </div>
          // <div
          //   className="text-xs bg-gray-300 flex items-center rounded-b-lg px-3 py-2 md:px-3 md:py-1">
          //   {"on " ++ date->DateFns.format("MMMM d, yyyy") |> str}
          // </div>
        </div>
      | (None, Graded(_))
      | (_, Grading)
      | (_, Ungraded) => React.null
      }}
      <div className="flex justify-center ml-2 md:ml-4">
        <div className={gradeBadgeClasses(color, status)}>
          {switch status {
          | Graded(passed) =>
            passed
              ? <Icon className="if i-badge-check-solid text-xl text-green-500" />
              : <FaIcon classes="fas fa-exclamation-triangle text-xl text-red-500" />
          | Grading => <Icon className="if i-writing-pad-solid text-xl text-orange-300" />
          | Ungraded => <Icon className="if i-eye-solid text-xl text-gray-400" />
          }}
          <p className={"text-xs font-semibold " ++ ("text-" ++ (color ++ "-800 "))}>
            {text |> str}
          </p>
        </div>
      </div>
    </div>
  </div>
}

let submissionStatusIcon = (status, overlaySubmission, send) => {
  let (text, color) = switch status {
  | Graded(passed) => passed ? ("Completed", "green") : ("Rejected", "red")
  | Grading => ("Reviewing", "orange")
  | Ungraded => ("Pending Review", "gray")
  }
  <div
    ariaLabel="submission-status"
    className="flex flex-1 flex-col items-center justify-center md:border-l mt-4 md:mt-0">
    <div
      className="flex flex-col-reverse md:flex-row items-start md:items-stretch justify-center w-full md:pl-6">
      {switch (overlaySubmission |> OverlaySubmission.evaluatedAt, status) {
      | (Some(date), Graded(_)) =>
        <div
          className="bg-gray-200 block md:flex flex-col w-full justify-between rounded-lg pt-3 mr-2 mt-4 md:mt-0">
          <div>
            <p className="text-xs px-3"> {"Evaluated By" |> str} </p>
            <p className="text-sm font-semibold px-3 pb-3">
              {switch overlaySubmission |> OverlaySubmission.evaluatorName {
              | Some(name) => name |> str
              | None => <em> {"Deleted Coach" |> str} </em>
              }}
            </p>
          </div>
          <div
            className="text-xs bg-gray-300 flex items-center rounded-b-lg px-3 py-2 md:px-3 md:py-1">
            {"on " ++ date->DateFns.format("MMMM d, yyyy") |> str}
          </div>
        </div>
      | (None, Graded(_))
      | (_, Grading)
      | (_, Ungraded) => React.null
      }}
      <div className="w-full md:w-26 flex flex-row md:flex-col md:items-center justify-center">
        <div className={gradeStatusClasses(color, status)}>
          {switch status {
          | Graded(passed) =>
            passed
              ? <Icon className="if i-badge-check-solid text-xl md:text-5xl text-green-500" />
              : <FaIcon classes="fas fa-exclamation-triangle text-xl md:text-4xl text-red-500" />
          | Grading =>
            <Icon className="if i-writing-pad-solid text-xl md:text-5xl text-orange-300" />
          | Ungraded => <Icon className="if i-eye-solid text-xl md:text-4xl text-gray-400" />
          }}
        </div>
        <p
          className={"text-xs flex items-center justify-center md:block text-center w-full border rounded px-1 py-px font-semibold md:mt-1 " ++
          ("border-" ++
          (color ++
          ("-400 " ++
          ("bg-" ++ (color ++ ("-100 " ++ ("text-" ++ (color ++ "-800 "))))))))}>
          {text |> str}
        </p>
      </div>
    </div>
  </div>
}

let gradeSubmission = (
  submissionId,
  state,
  send,
  evaluationCriteria,
  updateSubmissionCB,
  status,
  user,
  overlaySubmission,
  event,
) => {
  event |> ReactEvent.Mouse.preventDefault
  switch status {
  | Graded(_) =>
    gradeSubmissionQuery(
      submissionId,
      state,
      send,
      evaluationCriteria,
      overlaySubmission,
      user,
      updateSubmissionCB,
    )
  | Grading
  | Ungraded => ()
  }
}

let reviewButtonDisabled = status =>
  switch status {
  | Graded(_) => false
  | Grading
  | Ungraded => true
  }

let computeStatus = (
  overlaySubmission,
  selectedGrades,
  evaluationCriteria,
  targetEvaluationCriteriaIds,
) => {
  let currentGradingCriteria =
    evaluationCriteria |> Js.Array.filter(criterion =>
      targetEvaluationCriteriaIds |> Array.mem(EvaluationCriterion.id(criterion))
    )
  switch (
    overlaySubmission |> OverlaySubmission.passedAt,
    overlaySubmission |> OverlaySubmission.grades |> ArrayUtils.isNotEmpty,
  ) {
  | (Some(_), _) => Graded(true)
  | (None, true) => Graded(false)
  | (_, _) =>
    if selectedGrades == [] {
      Ungraded
    } else if selectedGrades |> Array.length != (currentGradingCriteria |> Array.length) {
      Grading
    } else {
      Graded(passed(selectedGrades, currentGradingCriteria))
    }
  }
}

let submitButtonText = (feedback, grades) =>
  switch (feedback != "", grades |> ArrayUtils.isNotEmpty) {
  | (false, false)
  | (false, true) => "Save grades"
  | (true, false)
  | (true, true) => "Save grades & send feedback"
  }

let noteForm = (overlaySubmission, teamSubmission, note, send) =>
  switch overlaySubmission |> OverlaySubmission.grades {
  | [] =>
    let (noteAbout, additionalHelp) = teamSubmission
      ? (
          "team",
          " This submission is from a team, so a note added here will be posted to the report of all students in the team.",
        )
      : ("student", "")

    let help =
      <HelpIcon className="ml-1">
        {"Notes can be used to keep track of a " ++
        (noteAbout ++
        ("'s progress. These notes are shown only to coaches in a student's report." ++
        additionalHelp)) |> str}
      </HelpIcon>

    let textareaId = "note-for-submission-" ++ (overlaySubmission |> OverlaySubmission.id)

    <div className="text-sm">
      <p className="font-semibold text-sm flex">
        <Icon className="if i-long-text-light text-gray-800 text-base" />
        {switch note {
        | Some(_) =>
          <span className="ml-2 md:ml-4 tracking-wide">
            <label htmlFor=textareaId> {"Write a Note" |> str} </label> help
          </span>
        | None =>
          <div className="ml-2 md:ml-4 tracking-wide w-full">
            <div>
              <span>
                {"Would you like to write a note about this " ++ (noteAbout ++ "?") |> str}
              </span>
              help
            </div>
            <button className="btn btn-default mt-2" onClick={_ => send(UpdateNote(""))}>
              <i className="far fa-edit" /> <p className="pl-2"> {"Write a Note" |> str} </p>
            </button>
          </div>
        }}
      </p>
      {switch note {
      | Some(note) =>
        <div className="ml-6 md:ml-7 mt-2">
          <MarkdownEditor
            maxLength=10000
            textareaId
            value=note
            onChange={value => send(UpdateNote(value))}
            profile=Markdown.Permissive
            placeholder="Did you notice something while reviewing this submission?"
          />
        </div>
      | None => React.null
      }}
    </div>
  | _someGrades => React.null
  }

let feedbackGenerator = (state, send) => {
  <div className="px-4 md:px-6 pt-4 space-y-8">
    <div>
      <div className="flex h-7 items-end">
        <h5 className="font-semibold text-sm flex items-center">
          <PfIcon
            className="if i-check-square-alt-light text-gray-800 text-base md:text-lg inline-block"
          />
          <span className="ml-2 md:ml-3 tracking-wide"> {"Review Checklist"->str} </span>
        </h5>
      </div>
      <div className="mt-2 md:ml-8">
        <button
          className="bg-primary-100 flex items-center justify-between px-4 py-3 border border-dashed border-gray-600 rounded-md w-full text-left font-semibold text-sm text-primary-500 hover:bg-gray-300 hover:text-primary-600 hover:border-primary-300 focus:outline-none transition"
          onClick={_ => send(ShowChecklistEditor)}>
          <span> {"Show Review Checklist"->str} </span> <FaIcon classes="fas fa-arrow-right" />
        </button>
      </div>
    </div>
    <div className="course-review__feedback-editor text-sm">
      <h5 className="font-semibold text-sm flex items-center">
        <PfIcon
          className="if i-comment-alt-light text-gray-800 text-base md:text-lg inline-block"
        />
        <span className="ml-2 md:ml-3 tracking-wide"> {"Add Your Feedback"->str} </span>
      </h5>
      <div
        className="inline-flex items-center bg-green-200 mt-2 md:ml-8 text-green-800 px-2 py-1 rounded-md">
        <Icon className="if i-check-circle-solid text-green-700 text-base inline-block" />
        <p className="pl-2 text-sm font-semibold">
          {"Feedback generated from review checklist." |> str}
        </p>
      </div>
      <div className="mt-2 md:ml-8" ariaLabel="feedback">
        <MarkdownEditor
          onChange={feedback => send(UpdateFeedback(feedback))}
          value=state.newFeedback
          profile=Markdown.Permissive
          maxLength=10000
          placeholder="This feedback will be emailed to students when you finish grading."
        />
      </div>
    </div>
  </div>
}

let showFeedback = feedback => Js.Array.mapi((f, index) =>
    <div key={index->string_of_int}>
      <div className="pt-6">
        <div className="flex">
          <div
            className="flex-shrink-0 w-10 h-10 bg-gray-300 rounded-full overflow-hidden mr-3 object-cover">
            {switch Feedback.coachAvatarUrl(f) {
            | Some(avatarUrl) => <img src=avatarUrl />
            | None => <Avatar name={Feedback.coachName(f)} />
            }}
          </div>
          <div>
            <div className="flex flex-col md:flex-row">
              <p className="font-semibold text-sm leading-tight inline-flex">
                {Feedback.coachName(f)->str}
              </p>
              <p className="block md:inline-flex text-xs text-gray-800 md:ml-2 leading-tight">
                {("(" ++ (Feedback.coachTitle(f) ++ ")"))->str}
              </p>
            </div>
            <p className="text-xs leading-tight font-semibold inline-block text-gray-800">
              {Feedback.createdAtPretty(f)->str}
            </p>
          </div>
        </div>
        <div>
          <MarkdownBlock
            className="pt-1 text-sm" profile=Markdown.Permissive markdown={Feedback.value(f)}
          />
        </div>
      </div>
    </div>
  , ArrayUtils.copyAndSort(
    (x, y) => DateFns.differenceInSeconds(Feedback.createdAt(y), Feedback.createdAt(x)),
    feedback,
  ))->React.array

let showSubmissionStatus = status => {
  let (text, classes) = switch status {
  | Graded(passed) =>
    passed ? ("Completed", "bg-green-100 text-green-800") : ("Rejected", "bg-red-100 text-red-700")
  | Ungraded
  | Grading => ("Pending Review", "bg-yellow-100 text-yellow-800 ")
  }
  <div className={"font-semibold px-2 py-px rounded " ++ classes}> <p> {text->str} </p> </div>
}

@react.component
let make = (
  ~overlaySubmission,
  ~teamSubmission,
  ~evaluationCriteria,
  ~reviewChecklist,
  ~updateSubmissionCB,
  ~updateReviewChecklistCB,
  ~targetId,
  ~targetEvaluationCriteriaIds,
  ~currentUser,
  ~number,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      grades: [],
      newFeedback: "",
      saving: false,
      note: None,
      checklist: OverlaySubmission.checklist(overlaySubmission),
      editor: ArrayUtils.isEmpty(OverlaySubmission.grades(overlaySubmission))
        ? GradesEditor
        : ReviewedSubmissionEditor(OverlaySubmission.grades(overlaySubmission)),
      additonalFeedbackEditorVisible: false,
    },
  )

  let status = computeStatus(
    overlaySubmission,
    state.grades,
    evaluationCriteria,
    targetEvaluationCriteriaIds,
  )

  let updateChecklistCB = switch OverlaySubmission.grades(overlaySubmission) {
  | [] => Some(checklist => send(UpdateChecklist(checklist)))
  | _ => None
  }

  let pending = ArrayUtils.isEmpty(OverlaySubmission.grades(overlaySubmission))

  let findEditor = (pending, overlaySubmission) => {
    pending ? GradesEditor : ReviewedSubmissionEditor(OverlaySubmission.grades(overlaySubmission))
  }

  <DisablingCover
    containerClasses="flex flex-col md:flex-row flex-1 space-y-6 md:space-y-0 md:overflow-y-auto"
    disabled=state.saving>
    <div className="md:w-1/2 w-full bg-white md:border-r relative md:overflow-y-auto">
      <div className="flex items-center px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 h-16">
        <div className="flex flex-1 items-center justify-between">
          <div>
            <p className="font-semibold"> {str("Submission " ++ string_of_int(number))} </p>
            <p className="text-gray-800 text-xs">
              {overlaySubmission
              ->OverlaySubmission.createdAt
              ->DateFns.formatPreset(~year=true, ())
              ->str}
            </p>
          </div>
          <p className="text-sm"> {showSubmissionStatus(status)} </p>
        </div>
      </div>
      <div className="p-4 md:p-6">
        <SubmissionChecklistShow checklist=state.checklist updateChecklistCB pending />
      </div>
    </div>
    <div className="md:w-1/2 w-full md:overflow-y-auto">
      {switch state.editor {
      | GradesEditor =>
        <div>
          <div
            className="flex items-center justify-between px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 md:h-16">
            <p className="font-semibold"> {str("Review")} </p>
          </div>
          {feedbackGenerator(state, send)}
          <div className="w-full px-4 md:px-6 pt-8 space-y-8">
            {noteForm(overlaySubmission, teamSubmission, state.note, send)}
            <div>
              <h5 className="font-semibold text-sm flex items-center">
                <Icon className="if i-tachometer-light text-gray-800 text-base" />
                <span className="ml-2 md:ml-3 tracking-wide"> {"Grade Card"->str} </span>
              </h5>
              <div className="flex md:flex-row flex-col md:ml-8 rounded-lg mt-2">
                <div className="w-full md:w-9/12">
                  <div className="md:pr-8">
                    {renderGradePills(evaluationCriteria, targetEvaluationCriteriaIds, state, send)}
                  </div>
                </div>
                {submissionStatusIcon(status, overlaySubmission, send)}
              </div>
            </div>
          </div>
          <div className="flex justify-end bg-white md:bg-gray-100 border-t px-4 py-2 md:py-4 mt-4">
            <button
              disabled={reviewButtonDisabled(status)}
              className="btn btn-success btn-large w-full md:w-auto border border-green-600"
              onClick={gradeSubmission(
                OverlaySubmission.id(overlaySubmission),
                state,
                send,
                evaluationCriteria,
                updateSubmissionCB,
                status,
                currentUser,
                overlaySubmission,
              )}>
              {submitButtonText(state.newFeedback, state.grades)->str}
            </button>
          </div>
        </div>

      | ChecklistEditor =>
        <div>
          <CoursesReview__Checklist
            reviewChecklist
            updateFeedbackCB={feedback =>
              send(GenerateFeeback(feedback, findEditor(pending, overlaySubmission)))}
            feedback=state.newFeedback
            updateReviewChecklistCB
            targetId
            cancelCB={_ => send(UpdateEditor(findEditor(pending, overlaySubmission)))}
          />
        </div>

      | ReviewedSubmissionEditor(grades) =>
        <div>
          <div
            className="flex items-center justify-between px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 md:h-16">
            <p className="font-semibold"> {str("Review")} </p>
            {submissionReviewStatus(status, overlaySubmission)}
          </div>
          <div className="w-full p-4 md:p-6">
            <div className="flex items-center justify-between">
              <h5 className="font-semibold text-sm flex items-center">
                <Icon className="if i-tachometer-light text-gray-800 text-base" />
                <span className="ml-2 md:ml-3 tracking-wide"> {"Grade Card"->str} </span>
              </h5>
              <div>
                {switch (OverlaySubmission.evaluatedAt(overlaySubmission), status) {
                | (Some(_), Graded(_)) =>
                  <div>
                    <button
                      onClick={_ =>
                        WindowUtils.confirm(
                          "Are you sure you want to remove these grades? This will return the submission to a 'Pending Review' state.",
                          () => OverlaySubmission.id(overlaySubmission)->undoGrading(send),
                        )}
                      className="btn btn-small bg-red-100 text-red-800 hover:bg-red-200">
                      <i className="fas fa-undo" />
                      <span className="ml-2"> {"Undo Grading" |> str} </span>
                    </button>
                  </div>
                | (None, Graded(_))
                | (_, Grading)
                | (_, Ungraded) => React.null
                }}
              </div>
            </div>
            <div className="flex md:flex-row flex-col md:ml-8 bg-gray-100 mt-2">
              <div className="w-full"> {showGrades(grades, evaluationCriteria, state)} </div>
              <div className="block md:hidden">
                {submissionStatusIcon(status, overlaySubmission, send)}
              </div>
            </div>
          </div>
          {state.additonalFeedbackEditorVisible
            ? <div>
                {feedbackGenerator(state, send)}
                <div className="flex justify-end px-4 md:px-6 py-4">
                  <button
                    disabled={state.newFeedback == "" || state.saving}
                    className="btn btn-success border border-green-600 w-full md:w-auto"
                    onClick={_ =>
                      createFeedback(
                        OverlaySubmission.id(overlaySubmission),
                        state.newFeedback,
                        send,
                        overlaySubmission,
                        currentUser,
                        updateSubmissionCB,
                      )}>
                    {"Share Feedback"->str}
                  </button>
                </div>
              </div>
            : <div className="p-4 md:p-6 md:ml-8 text-center">
                <button
                  onClick={_ => send(ShowAdditionalFeedbackEditor)}
                  className="bg-primary-100 flex items-center justify-center px-4 py-3 border border-dashed border-primary-500 rounded-md w-full font-semibold text-sm text-primary-600 hover:bg-white hover:text-primary-500 hover:shadow-lg hover:border-primary-300 focus:outline-none transition cursor-pointer">
                  <Icon className="if i-plus-regular" />
                  <p className="pl-2">
                    {switch OverlaySubmission.feedback(overlaySubmission) {
                    | [] => "Add feedback"
                    | _ => "Add another feedback"
                    }->str}
                  </p>
                </button>
              </div>}
          <div className="p-4 md:p-6">
            <h5 className="font-semibold text-sm flex items-center">
              <PfIcon
                className="if i-comment-alt-light text-gray-800 text-base md:text-lg inline-block"
              />
              <span className="ml-2 md:ml-3 tracking-wide"> {"Feedback"->str} </span>
            </h5>
            <div className="divide-y space-y-6 md:ml-8">
              {showFeedback(OverlaySubmission.feedback(overlaySubmission))}
            </div>
          </div>
        </div>
      }}
    </div>
  </DisablingCover>
}
