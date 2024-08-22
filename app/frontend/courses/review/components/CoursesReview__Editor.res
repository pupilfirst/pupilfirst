%%raw(`import "./CoursesReview__Editor.css"`)

let t = I18n.t(~scope="components.CoursesReview__Editor")
let ts = I18n.ts

open CoursesReview__Types
let str = React.string

type status =
  | Passed
  | Grading
  | Unreviewed
  | Rejected

type editor =
  | AssignReviewer
  | GradesEditor
  | ChecklistEditor
  | ReviewedSubmissionEditor(array<Grade.t>)

type nextSubmission = DataUnloaded | DataLoading | DataEmpty | DataLoaded(string)

type state = {
  grades: array<Grade.t>,
  isAcceptable: bool,
  newFeedback: string,
  saving: bool,
  showReport: bool,
  checklist: array<SubmissionChecklistItem.t>,
  note: option<string>,
  editor: editor,
  additonalFeedbackEditorVisible: bool,
  feedbackGenerated: bool,
  nextSubmission: nextSubmission,
  reloadSubmissionReport: bool,
}

type statusColors =
  | Red
  | Orange
  | Green
  | Gray

type action =
  | BeginSaving
  | FinishSaving
  | UpdateFeedback(string)
  | GenerateFeeback(string, editor)
  | UpdateGrades(array<Grade.t>)
  | UpdateIsAcceptable(bool)
  | UpdateChecklist(array<SubmissionChecklistItem.t>)
  | UpdateNote(string)
  | ShowGradesEditor
  | ShowChecklistEditor
  | ShowAdditionalFeedbackEditor
  | FeedbackAfterSave
  | UpdateEditor(editor)
  | FinishGrading(array<Grade.t>)
  | UnassignReviewer
  | ChangeReportVisibility
  | SetNextSubmissionDataEmpty
  | SetNextSubmissionDataLoading
  | SetNextSubmissionDataLoaded(string)

let reducer = (state, action) =>
  switch action {
  | BeginSaving => {...state, saving: true}
  | FinishSaving => {...state, saving: false}
  | UpdateFeedback(newFeedback) => {...state, newFeedback}
  | GenerateFeeback(newFeedback, editor) => {
      ...state,
      newFeedback,
      editor,
      feedbackGenerated: true,
    }
  | UpdateGrades(grades) => {...state, grades}
  | UpdateIsAcceptable(isAcceptable) => {...state, isAcceptable}
  | UpdateChecklist(checklist) => {...state, checklist}
  | UpdateNote(note) => {...state, note: Some(note)}
  | ShowGradesEditor => {...state, editor: GradesEditor}
  | ShowChecklistEditor => {
      ...state,
      editor: ChecklistEditor,
    }
  | ChangeReportVisibility => {...state, showReport: !state.showReport}
  | ShowAdditionalFeedbackEditor => {...state, additonalFeedbackEditorVisible: true}
  | FinishGrading(grades) => {
      ...state,
      editor: ReviewedSubmissionEditor(grades),
      saving: false,
      newFeedback: "",
      note: None,
    }
  | UpdateEditor(editor) => {...state, editor}
  | FeedbackAfterSave => {
      ...state,
      saving: false,
      additonalFeedbackEditorVisible: false,
      newFeedback: "",
    }
  | SetNextSubmissionDataEmpty => {...state, nextSubmission: DataEmpty}
  | SetNextSubmissionDataLoading => {...state, nextSubmission: DataLoading}
  | SetNextSubmissionDataLoaded(id) => {...state, nextSubmission: DataLoaded(id)}
  | UnassignReviewer => {...state, editor: AssignReviewer, saving: false}
  }

module CreateGradingMutation = %graphql(`
    mutation CreateGradingMutation($submissionId: ID!, $feedback: String, $grades: [GradeInput!], $note: String,  $checklist: JSON!) {
      createGrading(submissionId: $submissionId, feedback: $feedback, grades: $grades, note: $note, checklist: $checklist){
        success
      }
    }
  `)

module UndoGradingMutation = %graphql(`
    mutation UndoGradingMutation($submissionId: ID!) {
      undoGrading(submissionId: $submissionId){
        success
      }
    }
  `)

module CreateFeedbackMutation = %graphql(`
    mutation CreateFeedbackMutation($submissionId: ID!, $feedback: String!) {
      createFeedback(submissionId: $submissionId, feedback: $feedback){
        success
      }
    }
  `)

module NextSubmissionQuery = %graphql(`
    query NextSubmissionQuery($courseId: ID!, $search: String, $targetId: ID, $status: SubmissionStatus, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!,  $personalCoachId: ID, $assignedCoachId: ID) {
      submissions(courseId: $courseId, search: $search, targetId: $targetId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, personalCoachId: $personalCoachId, assignedCoachId: $assignedCoachId) {
        nodes {
          id
        }
      }
    }
  `)

module UnassignReviewerMutation = %graphql(`
    mutation UnassignReviewerMutation($submissionId: ID!) {
      unassignReviewer(submissionId: $submissionId){
        success
      }
    }
  `)

module SubmissionReportQuery = %graphql(`
    query SubmissionReportQuery($submissionId: ID!) {
      submissionDetails(submissionId: $submissionId) {
        submissionReports {
          id
          report
          status
          startedAt
          completedAt
          queuedAt
          reporter
          heading
          targetUrl
        }
      }
    }
  `)

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button"
  classes ++ (bool ? " toggle-button__button--active" : "")
}

let updateIsAcceptable = (isAcceptable, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(UpdateIsAcceptable(isAcceptable))
  if !isAcceptable {
    send(UpdateGrades([]))
  }
}

let unassignReviewer = (submissionId, send, updateReviewerCB) => {
  send(BeginSaving)

  UnassignReviewerMutation.fetch({submissionId: submissionId})
  |> Js.Promise.then_((response: UnassignReviewerMutation.t) => {
    if response.unassignReviewer.success {
      updateReviewerCB(None)
      send(UnassignReviewer)
    }
    send(FinishSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(FinishSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let getNextSubmission = (send, courseId, filter) => {
  send(SetNextSubmissionDataLoading)
  NextSubmissionQuery.makeVariables(
    ~courseId,
    ~status=?Filter.tab({...filter, tab: Some(#Pending)}),
    ~sortDirection=Filter.defaultDirection({...filter, sortDirection: Some(#Ascending)}),
    ~sortCriterion=Filter.sortCriterion({...filter, sortCriterion: #SubmittedAt}),
    ~personalCoachId=?Filter.personalCoachId(filter),
    ~assignedCoachId=?Filter.assignedCoachId(filter),
    ~targetId=?Filter.targetId(filter),
    ~search=?Filter.nameOrEmail(filter),
    (),
  )
  |> NextSubmissionQuery.fetch
  |> Js.Promise.then_((response: NextSubmissionQuery.t) => {
    if ArrayUtils.isEmpty(response.submissions.nodes) {
      send(SetNextSubmissionDataEmpty)
    } else {
      send(SetNextSubmissionDataLoaded(response.submissions.nodes[0].id))
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let isReviewDisabled = submissionDetails => {
  SubmissionDetails.reviewable(submissionDetails) == false
}

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

  CreateFeedbackMutation.make({submissionId, feedback})
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

  UndoGradingMutation.fetch({submissionId: submissionId})
  |> Js.Promise.then_((response: UndoGradingMutation.t) => {
    response.undoGrading.success ? DomUtils.reload()->ignore : send(FinishSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let passed = grades => {
  ArrayUtils.isNotEmpty(grades)
}

let trimToOption = s => Js.String.trim(s) == "" ? None : Some(s)
let trimArraytoOption = arr => ArrayUtils.isEmpty(arr) ? None : Some(arr)

let navigationDisabled = state => {
  Js.String2.trim(state.newFeedback) != "" || state.note != None || state.saving
}

let gradeSubmissionQuery = (
  submissionId,
  state,
  send,
  overlaySubmission,
  currentUser,
  updateSubmissionCB,
  courseId,
  filter,
) => {
  send(BeginSaving)
  let feedback = trimToOption(state.newFeedback)
  // let grades = Js.Array.map(g => Grade.asJsType(g), state.grades)

  let grades =
    Js.Array.map(
      g =>
        CreateGradingMutation.makeInputObjectGradeInput(
          ~evaluationCriterionId=Grade.evaluationCriterionId(g),
          ~grade=Grade.value(g),
          (),
        ),
      state.grades,
    )->trimArraytoOption

  let variables = CreateGradingMutation.makeVariables(
    ~submissionId,
    ~feedback?,
    ~note=?Belt.Option.flatMap(state.note, trimToOption),
    ~grades?,
    ~checklist=SubmissionChecklistItem.encodeArray(state.checklist),
    (),
  )

  CreateGradingMutation.fetch(~notify=false, variables)
  |> Js.Promise.then_((response: CreateGradingMutation.t) => {
    response.createGrading.success
      ? {
          updateSubmissionCB(
            OverlaySubmission.update(
              passed(state.grades) ? Some(Js.Date.make()) : None,
              Some(User.name(currentUser)),
              Js.Array.concat(
                Belt.Option.mapWithDefault(feedback, [], f => [makeFeedback(currentUser, f)]),
                OverlaySubmission.feedback(overlaySubmission),
              ),
              state.grades,
              Some(Js.Date.make()),
              state.checklist,
              overlaySubmission,
            ),
          )
          send(FinishGrading(state.grades))
          getNextSubmission(send, courseId, filter)
        }
      : send(FinishSaving)

    Js.Promise.resolve()
  })
  |> ignore
}

let warning = submissionDetails => {
  switch SubmissionDetails.warning(submissionDetails) {
  | None => React.null
  | Some(warning) =>
    <div
      className="border border-yellow-400 rounded bg-yellow-200 py-2 px-3 text-xs md:text-sm md:text-center">
      <i className="fas fa-exclamation-triangle" />
      <span className="ms-2"> {warning->str} </span>
    </div>
  }
}

let closeOverlay = (state, courseId, filter) => {
  let path = "/courses/" ++ courseId ++ "/review?" ++ Filter.toQueryString(filter)

  navigationDisabled(state)
    ? WindowUtils.confirm(
        ~onCancel=() => (),
        t("close_submission_warning"),
        () => RescriptReactRouter.push(path),
      )
    : RescriptReactRouter.push(path)
}

let reviewNextButton = (nextSubmission, filter) => {
  let buttonStyle = "next-submission-button flex w-full items-center justify-center text-sm font-semibold bg-white border-t border-gray-200 px-5 py-4 focus:ring-2 focus:ring-focusColor-500 ring-inset"
  switch nextSubmission {
  | DataLoaded(id) =>
    <Link
      href={"/submissions/" ++ id ++ "/review?" ++ Filter.toQueryString(filter)}
      className={`${buttonStyle} hover:bg-primary-50 hover:text-primary-500`}>
      <p className="pe-2"> {str(t("review_next"))} </p>
      <Icon className="if i-arrow-right-short-light text-lg lg:text-2xl rtl:rotate-180" />
    </Link>
  | DataLoading =>
    <button disabled={true} className=buttonStyle>
      <FaIcon classes="fas fa-spinner fa-pulse me-2" />
    </button>
  | DataEmpty =>
    <div className=buttonStyle>
      <Icon className="if i-check-circle-alt-light text-lg lg:text-2xl" />
      <p className="ps-2 block md:hidden"> {str(t("you_are_done"))} </p>
      <p className="ps-2 hidden md:block"> {str(t("no_more_pending_submissions"))} </p>
    </div>
  | DataUnloaded => React.null
  }
}

let headerSection = (state, submissionDetails, filter) =>
  <div
    ariaLabel="submissions-overlay-header"
    className="bg-gray-50 border-b border-gray-300 flex justify-center">
    <div className="bg-white flex justify-between w-full">
      <div className="flex flex-col md:flex-row w-full md:w-auto">
        <div className="flex flex-1 md:flex-none justify-between border-b md:border-0">
          <button
            title={t("close")}
            ariaLabel="submissions-overlay-close"
            onClick={_ =>
              closeOverlay(state, SubmissionDetails.courseId(submissionDetails), filter)}
            className="flex flex-col items-center justify-center leading-tight px-3 py-2 md:px-5 md:py-4 cursor-pointer border-e bg-white text-gray-600 hover:text-gray-900 hover:bg-gray-50 focus:ring-2 focus:ring-focusColor-500 ring-inset ">
            <div className="flex items-center justify-center bg-gray-100 rounded-full w-8 h-8">
              <Icon className="if i-times-regular text-lg lg:text-2xl" />
            </div>
            <span className="text-xs mt-0.5"> {str(t("close"))} </span>
          </button>
          <div className="flex">
            <CoursesStudents__PersonalCoaches
              tooltipPosition=#Bottom
              defaultAvatarSize="8"
              mdAvatarSize="8"
              title={<span className="hidden"> {t("assigned_coaches")->str} </span>}
              className="flex md:hidden items-center shrink-0"
              coaches={SubmissionDetails.coaches(submissionDetails)}
            />
          </div>
        </div>
        <div className="px-4 py-3 flex flex-col justify-center">
          <div className="block text-sm md:pe-2">
            <a
              href={"/targets/" ++ SubmissionDetails.targetId(submissionDetails)}
              target="_blank"
              className="font-semibold underline text-gray-900 hover:bg-primary-100 hover:text-primary-600 text-base focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500">
              {SubmissionDetails.targetTitle(submissionDetails)->str}
            </a>
          </div>
          <div className="mt-1 text-xs text-gray-800">
            {switch SubmissionDetails.teamName(submissionDetails) {
            | Some(teamName) =>
              <span>
                <span> {t("submitted_by_team")->str} </span>
                <span className="font-semibold"> {teamName->str} </span>
                <span> {" - "->str} </span>
              </span>
            | None => <span> {t("submitted_by")->str} </span>
            }}
            {
              let studentCount = SubmissionDetails.students(submissionDetails)->Array.length

              Js.Array.mapi((student, index) => {
                let commaRequired = index + 1 != studentCount
                <span key={Student.id(student)}>
                  <a
                    className="font-semibold underline focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500"
                    href={"/students/" ++ Student.id(student) ++ "/report"}
                    target="_blank">
                    {Student.name(student)->str}
                  </a>
                  {(commaRequired ? ", " : "")->str}
                </span>
              }, SubmissionDetails.students(submissionDetails))->React.array
            }
          </div>
        </div>
      </div>
      <div className="hidden md:flex shrink-0 gap-6">
        <CoursesStudents__PersonalCoaches
          tooltipPosition=#Bottom
          defaultAvatarSize="8"
          mdAvatarSize="8"
          title={<span className="me-2"> {t("assigned_coaches")->str} </span>}
          className="flex w-full md:w-auto items-center shrink-0"
          coaches={SubmissionDetails.coaches(submissionDetails)}
        />
      </div>
    </div>
  </div>

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
      "in CoursesRevew__Editor"),
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

let gradePillClasses = (selectedGrade, currentGrade, send) => {
  let defaultClasses =
    "course-review-editor__grade-pill shadow-sm border-gray-300 flex items-center justify-center py-1 px-2 text-sm flex-1 font-semibold transition " ++
    switch send {
    | Some(_) =>
      "cursor-pointer hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500 " ++ "hover:bg-green-500 hover:text-white "

    | None => ""
    }

  defaultClasses ++ (
    currentGrade <= selectedGrade
      ? "cursor-default bg-green-500 text-white shadow-lg"
      : "bg-white text-gray-900"
  )
}

let showGradePill = (key, submissionDetails, evaluationCriterion, gradeValue, state, send) =>
  <div
    ariaLabel={"evaluation-criterion-" ++ EvaluationCriterion.id(evaluationCriterion)}
    key={key->string_of_int}
    className="mt-2">
    {gradePillHeader(
      EvaluationCriterion.name(evaluationCriterion),
      gradeValue,
      EvaluationCriterion.gradesAndLabels(evaluationCriterion),
    )}
    <div className="course-review-editor__grade-bar inline-flex w-full text-center mt-1">
      {EvaluationCriterion.gradesAndLabels(evaluationCriterion)
      ->Js.Array2.map(gradeLabel => {
        let gradeLabelGrade = GradeLabel.grade(gradeLabel)

        <button
          key={string_of_int(gradeLabelGrade)}
          onClick={handleGradePillClick(
            EvaluationCriterion.id(evaluationCriterion),
            gradeLabelGrade,
            state,
            send,
          )}
          disabled={isReviewDisabled(submissionDetails)}
          title={GradeLabel.label(gradeLabel)}
          className={gradePillClasses(gradeValue, gradeLabelGrade, send)}>
          {switch send {
          | Some(_) => string_of_int(gradeLabelGrade)->str
          | None => React.null
          }}
        </button>
      })
      ->React.array}
    </div>
  </div>

let showGrades = (grades, evaluationCriteria, submissionDetails, state) =>
  <div>
    {Grade.sort(evaluationCriteria, grades)
    ->Js.Array2.mapi((grade, key) => {
      let gradeEcId = Grade.evaluationCriterionId(grade)
      let ec = ArrayUtils.unsafeFind(
        ec => EvaluationCriterion.id(ec) == gradeEcId,
        "Unable to find evaluation Criterion with id: " ++ (gradeEcId ++ "in CoursesRevew__Editor"),
        evaluationCriteria,
      )

      showGradePill(key, submissionDetails, ec, Grade.value(grade), state, None)
    })
    ->React.array}
  </div>
let renderGradePills = (
  evaluationCriteria,
  targetEvaluationCriteriaIds,
  submissionDetails,
  state,
  send,
) =>
  targetEvaluationCriteriaIds
  ->Js.Array2.mapi((evaluationCriterionId, key) => {
    let ec = ArrayUtils.unsafeFind(
      e => EvaluationCriterion.id(e) == evaluationCriterionId,
      "CoursesRevew__Editor: Unable to find evaluation criterion with id - " ++
      evaluationCriterionId,
      evaluationCriteria,
    )
    let grade =
      state.grades->Js.Array2.find(g =>
        Grade.evaluationCriterionId(g) == EvaluationCriterion.id(ec)
      )
    let gradeValue = switch grade {
    | Some(g) => Grade.value(g)
    | None => 0
    }

    showGradePill(key, submissionDetails, ec, gradeValue, state, Some(send))
  })
  ->React.array

let badgeColorClasses = statusColor => {
  switch statusColor {
  | Red => "bg-red-100 border-red-400"
  | Green => "bg-green-100 border-green-400"
  | Orange => "bg-orange-100 border-orange-400"
  | Gray => "bg-gray-50 border-gray-300"
  }
}

let gradeBadgeClasses = (statusColor, status, badge) =>
  (
    badge
      ? "px-2 py-2 flex justify-center border rounded items-center space-x-2 "
      : "w-12 h-10 p-1 md:w-26 md:h-22 rounded md:rounded-lg border flex justify-center items-center "
  ) ++
  badgeColorClasses(statusColor) ++
  switch status {
  | Grading => "course-review-editor__status-pulse"
  | Passed
  | Rejected => ""
  | Unreviewed => ""
  }

let textColor = statusColor => {
  switch statusColor {
  | Red => "text-red-800"
  | Green => "text-green-800"
  | Orange => "text-orange-800"
  | Gray => "text-gray-800"
  }
}

let submissionReviewStatus = (status, overlaySubmission) => {
  let (text, color) = switch status {
  | Passed => (t("status.completed"), Green)
  | Grading => (t("status.reviewing"), Orange)
  | Rejected => (t("status.rejected"), Red)
  | Unreviewed => (t("status.pending_review"), Gray)
  }
  <div ariaLabel="submission-status" className="hidden md:flex gap-4 justify-end w-3/4">
    <div className="flex items-center">
      {switch OverlaySubmission.evaluatedAt(overlaySubmission) {
      | Some(_date) =>
        <div>
          <div>
            <p className="text-xs text-gray-800"> {t("evaluated_by")->str} </p>
            <p className="text-xs font-semibold">
              {switch OverlaySubmission.evaluatorName(overlaySubmission) {
              | Some(name) => name->str
              | None => <em> {t("deleted_coach")->str} </em>
              }}
            </p>
          </div>
        </div>
      | None => React.null
      }}
      <div className="flex justify-center ms-2 md:ms-4">
        <div className={gradeBadgeClasses(color, status, true)}>
          {switch status {
          | Passed => <Icon className="if i-badge-check-solid text-xl text-green-500" />
          | Grading => <Icon className="if i-writing-pad-solid text-xl text-orange-300" />
          | Rejected => <FaIcon classes="fas fa-exclamation-triangle text-xl text-red-500" />
          | Unreviewed => <Icon className="if i-eye-solid text-xl text-gray-400" />
          }}
          <p className={"text-xs font-semibold " ++ textColor(color)}> {text->str} </p>
        </div>
      </div>
    </div>
  </div>
}

let submissionStatusIcon = (status, overlaySubmission) => {
  let (text, color) = switch status {
  | Passed => (t("status.completed"), Green)
  | Grading => (t("status.reviewing"), Orange)
  | Rejected => (t("status.rejected"), Red)
  | Unreviewed => (t("status.pending_review"), Gray)
  }
  <div
    ariaLabel="submission-status"
    className="flex flex-1 flex-col items-center justify-center md:border-s mt-4 md:mt-0">
    <div
      className="flex flex-col-reverse md:flex-row items-start md:items-stretch justify-center w-full md:ps-6">
      {switch OverlaySubmission.evaluatedAt(overlaySubmission) {
      | Some(date) =>
        <div
          className="bg-gray-50 block md:flex flex-col w-full justify-between rounded-lg pt-3 me-2 mt-4 md:mt-0">
          <div>
            <p className="text-xs px-3"> {"Evaluated By"->str} </p>
            <p className="text-sm font-semibold px-3 pb-3">
              {switch OverlaySubmission.evaluatorName(overlaySubmission) {
              | Some(name) => name->str
              | None => <em> {t("deleted_coach")->str} </em>
              }}
            </p>
          </div>
          <div
            className="text-xs bg-gray-300 flex items-center rounded-b-lg px-3 py-2 md:px-3 md:py-1">
            {t(
              ~variables=[("evaluated_at", DateFns.format(date, "MMMM d, yyyy"))],
              "evaluated_at",
            )->str}
          </div>
        </div>
      | None => React.null
      }}
      <div
        className="w-full md:w-26 flex gap-1 flex-row md:flex-col md:items-center justify-center">
        <div className={gradeBadgeClasses(color, status, false)}>
          {switch status {
          | Passed => <Icon className="if i-badge-check-solid text-xl md:text-5xl text-green-500" />
          | Grading =>
            <Icon className="if i-writing-pad-solid text-xl md:text-5xl text-orange-300" />
          | Rejected =>
            <FaIcon classes="fas fa-exclamation-triangle text-xl md:text-4xl text-red-500" />
          | Unreviewed => <Icon className="if i-eye-solid text-xl md:text-4xl text-gray-400" />
          }}
        </div>
        <p
          className={`text-xs flex items-center justify-center md:block text-center w-full border rounded px-1 py-px font-semibold ${badgeColorClasses(
              color,
            )} ${textColor(color)}`}>
          {text->str}
        </p>
      </div>
    </div>
  </div>
}

let gradeSubmission = (
  submissionId,
  state,
  send,
  updateSubmissionCB,
  status,
  currentUser,
  overlaySubmission,
  event,
  courseId,
  filter,
) => {
  ReactEvent.Mouse.preventDefault(event)
  switch status {
  | Passed =>
    gradeSubmissionQuery(
      submissionId,
      state,
      send,
      overlaySubmission,
      currentUser,
      updateSubmissionCB,
      courseId,
      filter,
    )
  | Grading
  | Unreviewed
  | Rejected =>
    gradeSubmissionQuery(
      submissionId,
      state,
      send,
      overlaySubmission,
      currentUser,
      updateSubmissionCB,
      courseId,
      filter,
    )
  }
}

let reviewButtonDisabled = status =>
  switch status {
  | Passed => false
  | Grading
  | Rejected => false
  | Unreviewed => true
  }

let computeStatus = (
  overlaySubmission,
  selectedGrades,
  isAcceptable,
  evaluationCriteria,
  targetEvaluationCriteriaIds,
) => {
  let currentGradingCriteria =
    evaluationCriteria->Js.Array2.filter(criterion =>
      Array.mem(EvaluationCriterion.id(criterion), targetEvaluationCriteriaIds)
    )
  switch (
    OverlaySubmission.evaluatedAt(overlaySubmission),
    ArrayUtils.isNotEmpty(OverlaySubmission.grades(overlaySubmission)),
  ) {
  | (Some(_), true) => Passed
  | (Some(_), false) => Rejected
  | (_, _) =>
    if isAcceptable {
      if selectedGrades == [] {
        Unreviewed
      } else if Array.length(selectedGrades) != Array.length(currentGradingCriteria) {
        Grading
      } else {
        Passed
      }
    } else {
      Rejected
    }
  }
}

let submitButtonText = (isAcceptable, feedback, grades) =>
  switch (isAcceptable, feedback != "", ArrayUtils.isNotEmpty(grades)) {
  | (false, false, false) => t("reject_submission")
  | (false, true, false) => t("reject_submission_and_send_feedback")
  | (false, true, true)
  | (false, false, true)
  | (true, false, true) =>
    t("save_grades")
  | (true, false, false) => t("save_grades")
  | (true, true, false)
  | (true, true, true) =>
    t("save_grades_and_send_feedback")
  }

let noteForm = (submissionDetails, overlaySubmission, teamSubmission, note, send) =>
  switch OverlaySubmission.grades(overlaySubmission) {
  | [] =>
    let (noteAbout, additionalHelp) = teamSubmission
      ? (t("team"), t("team_notice"))
      : (t("student"), "")

    let help =
      <HelpIcon className="ms-1">
        {t(
          ~variables=[("note_about", noteAbout), ("additional_help", additionalHelp)],
          "help_text",
        )->str}
      </HelpIcon>

    let textareaId = "note-for-submission-" ++ OverlaySubmission.id(overlaySubmission)

    <div>
      <div className="font-medium text-sm flex items-start md:items-center">
        <Icon className="if i-long-text-light text-gray-800 text-base mt-1 md:mt-0.5" />
        {switch note {
        | Some(_) =>
          <span className="ms-2 md:ms-4 tracking-wide">
            <label htmlFor=textareaId> {t("write_a_note")->str} </label>
            help
          </span>
        | None =>
          <div className="ms-2 md:ms-4 tracking-wide w-full flex items-center">
            <div>
              <span> {t("note_help", ~variables=[("noteAbout", noteAbout)])->str} </span>
              help
            </div>
            <button
              className="btn btn-default btn-small ms-4"
              disabled={isReviewDisabled(submissionDetails)}
              onClick={_ => send(UpdateNote(""))}>
              <i className="far fa-edit" />
              <span className="ps-2"> {t("write_a_note")->str} </span>
            </button>
          </div>
        }}
      </div>
      {switch note {
      | Some(note) =>
        <div className="ms-6 md:ms-7 mt-2">
          <MarkdownEditor
            maxLength=10000
            textareaId
            value=note
            onChange={value => send(UpdateNote(value))}
            profile=Markdown.Permissive
            placeholder={t("note_placeholder")}
          />
        </div>
      | None => React.null
      }}
    </div>
  | _someGrades => React.null
  }

let feedbackGenerator = (
  submissionDetails,
  reviewChecklist,
  state,
  ~showAddFeedbackEditor=true,
  send,
) => {
  <div className="px-4 md:px-6 pt-4 space-y-8">
    <div>
      <div className="flex h-7 items-end">
        <h5 className="font-medium text-sm flex items-center">
          <PfIcon
            className="if i-check-square-alt-light text-gray-800 text-base md:text-lg inline-block"
          />
          <span className="ms-2 md:ms-3 tracking-wide"> {t("review_checklist")->str} </span>
        </h5>
      </div>
      <div className="mt-2 md:ms-8">
        <button
          disabled={isReviewDisabled(submissionDetails)}
          className="bg-primary-100 flex gap-3 items-center justify-between px-4 py-3 border border-dashed border-gray-600 rounded-md w-full font-semibold text-sm text-primary-500 hover:bg-gray-300 hover:text-primary-600 hover:border-primary-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 transition"
          onClick={_ => send(ShowChecklistEditor)}>
          <span>
            {(
              ArrayUtils.isEmpty(reviewChecklist)
                ? t("create_review_checklist")
                : t("show_review_checklist")
            )->str}
          </span>
          <FaIcon classes="fas fa-arrow-right rtl:rotate-180" />
        </button>
      </div>
    </div>
    {showAddFeedbackEditor
      ? <div className="course-review__feedback-editor text-sm">
          <h5 className="font-medium text-sm flex items-center">
            <PfIcon
              className="if i-comment-alt-light text-gray-800 text-base md:text-lg inline-block"
            />
            <span className="ms-2 md:ms-3 tracking-wide"> {t("add_your_feedback")->str} </span>
          </h5>
          {ReactUtils.nullUnless(
            <div
              className="inline-flex items-center bg-green-200 mt-2 md:ms-8 text-green-800 px-2 py-1 rounded-md">
              <Icon className="if i-check-circle-solid text-green-700 text-base" />
              <span className="ps-2 text-sm font-semibold">
                {t("feedback_generated_text")->str}
              </span>
            </div>,
            state.feedbackGenerated,
          )}
          <div className="mt-2 md:ms-8" ariaLabel="feedback">
            <MarkdownEditor
              onChange={feedback => send(UpdateFeedback(feedback))}
              value=state.newFeedback
              profile=Markdown.Permissive
              maxLength=10000
              disabled={isReviewDisabled(submissionDetails)}
              placeholder={t("feedback_placeholder")}
            />
          </div>
        </div>
      : React.null}
  </div>
}

let showFeedback = feedback =>
  <div className="divide-y space-y-6 md:ms-8"> {Js.Array.mapi((f, index) =>
      <Spread props={"data-title": "feedback-section"} key={index->string_of_int}>
        <div>
          <div className="pt-6">
            <div className="flex">
              <div
                className="shrink-0 w-10 h-10 bg-gray-300 rounded-full overflow-hidden me-4 object-cover">
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
                  <p className="block md:inline-flex text-xs text-gray-800 md:ms-2 leading-tight">
                    {("(" ++ (Feedback.coachTitle(f) ++ ")"))->str}
                  </p>
                </div>
                <p className="text-xs leading-tight font-semibold inline-block text-gray-800">
                  {Feedback.createdAtPretty(f)->str}
                </p>
              </div>
            </div>
            <div className="md:ms-14">
              <MarkdownBlock
                className="pt-1 text-sm" profile=Markdown.Permissive markdown={Feedback.value(f)}
              />
            </div>
          </div>
        </div>
      </Spread>
    , ArrayUtils.copyAndSort(
      (x, y) => DateFns.differenceInSeconds(Feedback.createdAt(y), Feedback.createdAt(x)),
      feedback,
    ))->React.array} </div>

let showSubmissionStatus = status => {
  let (text, classes) = switch status {
  | Passed => (t("status.completed"), "bg-green-100 text-green-800")
  | Rejected => (t("status.rejected"), "bg-red-100 text-red-700")
  | Unreviewed
  | Grading => (t("status.pending_review"), "bg-yellow-100 text-yellow-800 ")
  }
  <div
    ariaLabel="submission-leftpane-status"
    className={"font-semibold px-2 py-px rounded " ++ classes}>
    <p> {text->str} </p>
  </div>
}

let updateReviewChecklist = (cb, send, checklist) => {
  if ArrayUtils.isEmpty(checklist) {
    send(ShowGradesEditor)
  }

  cb(checklist)
}

let updateReviewer = (cb, send, reviewer) => {
  cb(reviewer)
  send(ShowGradesEditor)
}

let pageTitle = (number, submissionDetails) => {
  let studentOrTeamName = switch SubmissionDetails.teamName(submissionDetails) {
  | Some(teamName) => teamName
  | None =>
    Js.Array2.map(SubmissionDetails.students(submissionDetails), Student.name)->Js.Array2.joinWith(
      ", ",
    )
  }

  t(
    ~variables=[
      ("submission_number", string_of_int(number)),
      ("target_title", SubmissionDetails.targetTitle(submissionDetails)),
      ("name", studentOrTeamName),
    ],
    "page_title",
  )
}

let loadSubmissionReport = (submissionId, updateSubmissionReportCB) => {
  SubmissionReportQuery.make({submissionId: submissionId})
  |> Js.Promise.then_(response => {
    let updatedReports =
      response["submissionDetails"]["submissionReports"]->Js.Array2.map(SubmissionReport.makeFromJS)

    updateSubmissionReportCB(updatedReports)

    Js.Promise.resolve()
  })
  |> ignore
}

let reloadSubmissionReport = (submissionId, reports, updateSubmissionReportCB) => {
  let shouldReload =
    reports
    ->Js.Array2.filter(report =>
      switch SubmissionReport.status(report) {
      | Queued | InProgress => true
      | Error | Failure | Success => false
      }
    )
    ->ArrayUtils.isNotEmpty

  if shouldReload {
    loadSubmissionReport(submissionId, updateSubmissionReportCB)
  }
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
  ~submissionDetails,
  ~submissionId,
  ~updateReviewerCB,
  ~submissionReports,
  ~updateSubmissionReportCB,
  ~submissionReportPollTime,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      grades: [],
      isAcceptable: true,
      newFeedback: "",
      saving: false,
      showReport: false,
      note: None,
      checklist: OverlaySubmission.checklist(overlaySubmission),
      editor: OverlaySubmission.evaluatedAt(overlaySubmission) == None
        ? Belt.Option.mapWithDefault(SubmissionDetails.reviewer(submissionDetails), false, r =>
            UserProxy.userId(Reviewer.user(r)) == User.id(currentUser)
          ) ||
          isReviewDisabled(submissionDetails)
            ? GradesEditor
            : AssignReviewer
        : ReviewedSubmissionEditor(OverlaySubmission.grades(overlaySubmission)),
      additonalFeedbackEditorVisible: false,
      feedbackGenerated: false,
      nextSubmission: DataUnloaded,
      reloadSubmissionReport: false,
    },
  )

  let newFeedbackRef = React.useRef(state.newFeedback)

  React.useEffect0(() => {
    open Webapi.Dom

    let handleBeforeUnload = event => {
      if newFeedbackRef.current != "" {
        Event.preventDefault(event)
        DomUtils.Event.setReturnValue(event, "")
      }
    }

    Window.addEventListener(window, "beforeunload", handleBeforeUnload)

    let removeEventListener = () => {
      Window.removeEventListener(window, "beforeunload", handleBeforeUnload)
    }

    Some(removeEventListener)
  })

  React.useEffect1(() => {
    newFeedbackRef.current = state.newFeedback
    None
  }, [state.newFeedback])

  let status = computeStatus(
    overlaySubmission,
    state.grades,
    state.isAcceptable,
    evaluationCriteria,
    targetEvaluationCriteriaIds,
  )

  let updateChecklistCB = switch OverlaySubmission.grades(overlaySubmission) {
  | [] => Some(checklist => send(UpdateChecklist(checklist)))
  | _ => None
  }

  let findEditor = (evaluatedAt, overlaySubmission) => {
    switch evaluatedAt {
    | None =>
      Belt.Option.mapWithDefault(SubmissionDetails.reviewer(submissionDetails), false, r =>
        UserProxy.userId(Reviewer.user(r)) == User.id(currentUser)
      ) ||
      isReviewDisabled(submissionDetails)
        ? GradesEditor
        : AssignReviewer
    | Some(_) => ReviewedSubmissionEditor(OverlaySubmission.grades(overlaySubmission))
    }
  }

  React.useEffect0(() => {
    ArrayUtils.isNotEmpty(submissionReports)
      ? {
          let intervalId = Js.Global.setInterval(
            () => reloadSubmissionReport(submissionId, submissionReports, updateSubmissionReportCB),
            submissionReportPollTime * 1000,
          )
          Some(() => Js.Global.clearInterval(intervalId))
        }
      : None
  })

  let url = RescriptReactRouter.useUrl()
  let filter = Filter.makeFromQueryParams(url.search)

  {
    [
      <Helmet key="helmet">
        <title> {str(pageTitle(number, submissionDetails))} </title>
      </Helmet>,
      <div key="submission-header">
        <div> {warning(submissionDetails)} </div>
        {headerSection(state, submissionDetails, filter)}
        {ReactUtils.nullIf(
          <div className="flex gap-4 overflow-x-auto px-4 md:px-6 py-2 md:py-3 border-b bg-gray-50">
            {Js.Array2.mapi(SubmissionDetails.allSubmissions(submissionDetails), (
              submission,
              index,
            ) =>
              <CoursesReview__SubmissionInfoCard
                key={SubmissionMeta.id(submission)}
                selected={SubmissionMeta.id(submission) == submissionId}
                submission
                submissionNumber={Array.length(
                  SubmissionDetails.allSubmissions(submissionDetails),
                ) -
                index}
                filterString={url.search}
              />
            )->React.array}
          </div>,
          Js.Array.length(SubmissionDetails.allSubmissions(submissionDetails)) == 1,
        )}
      </div>,
      <DisablingCover
        key="submission-editor"
        containerClasses="flex flex-col lg:flex-row flex-1 gap-6 md:gap-0 md:overflow-y-auto"
        disabled=state.saving>
        <div className="lg:w-1/2 w-full bg-white md:border-e relative lg:overflow-y-auto">
          <div
            className="flex items-center px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 h-16">
            <div className="flex flex-1 items-center justify-between">
              <div>
                <p className="font-semibold">
                  {t(~variables=[("number", string_of_int(number))], "submission_number")->str}
                </p>
                <p
                  className="text-gray-800 text-xs"
                  title={OverlaySubmission.createdAt(overlaySubmission)->DateFns.formatPreset(
                    ~year=true,
                    ~time=true,
                    (),
                  )}>
                  {overlaySubmission
                  ->OverlaySubmission.createdAt
                  ->DateFns.formatPreset(~year=true, ())
                  ->str}
                </p>
              </div>
              <div className="text-sm"> {showSubmissionStatus(status)} </div>
            </div>
          </div>
          <div className="p-4 md:p-6 md:pb-20">
            <SubmissionChecklistShow checklist=state.checklist updateChecklistCB />
          </div>
          {submissionReports
          ->Js.Array2.map(report => <CoursesReview__SubmissionReportShow key=report.id report />)
          ->React.array}
        </div>
        <div className="lg:w-1/2 w-full lg:overflow-y-auto">
          {switch state.editor {
          | AssignReviewer =>
            <div>
              <div
                className="flex items-center justify-between px-4 md:px-6 py-3 bg-white border-b border-t lg:border-t-0 sticky top-0 z-50 md:h-16">
                <p className="font-semibold"> {str(t("review"))} </p>
              </div>
              {feedbackGenerator(
                submissionDetails,
                reviewChecklist,
                state,
                ~showAddFeedbackEditor=false,
                send,
              )}
              <CoursesReview__ReviewerManager
                submissionDetails
                updateReviewerCB={updateReviewer(updateReviewerCB, send)}
                submissionId
              />
            </div>

          | GradesEditor =>
            <div>
              <div
                className="flex items-center justify-between px-4 md:px-6 py-3 bg-white border-b border-t lg:border-t-0 sticky top-0 z-50 md:h-16">
                <p className="font-semibold"> {str(t("review"))} </p>
              </div>
              {ReactUtils.nullIf(
                <div className="px-4 py-4 border-b border-gray-300" ariaLabel="Assigned to">
                  <div
                    className="flex items-center justify-between px-3 py-2 rounded-md bg-gray-50">
                    {switch SubmissionDetails.reviewer(submissionDetails) {
                    | Some(reviewer) =>
                      <div>
                        <div>
                          <p className="text-xs text-gray-800"> {t("assigned_to")->str} </p>
                          <p className="text-xs font-semibold">
                            {UserProxy.name(Reviewer.user(reviewer))->str}
                          </p>
                        </div>
                      </div>
                    | None => React.null
                    }}
                    <div className="flex justify-center ms-2 md:ms-4">
                      <button
                        onClick={_ => unassignReviewer(submissionId, send, updateReviewerCB)}
                        className="btn btn-small bg-red-100 text-red-800 hover:bg-red-200 focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500">
                        <Icon className="if i-times-regular" />
                        <span className="ms-2"> {t("remove_assignment")->str} </span>
                      </button>
                    </div>
                  </div>
                </div>,
                isReviewDisabled(submissionDetails),
              )}
              {feedbackGenerator(submissionDetails, reviewChecklist, state, send)}
              <div className="w-full px-4 md:px-6 pt-8 space-y-8">
                {noteForm(submissionDetails, overlaySubmission, teamSubmission, state.note, send)}
                <div className="flex items-start md:items-center">
                  <label
                    className="tracking-wide text-sm font-semibold flex me-4"
                    htmlFor="is_acceptable">
                    <Icon
                      className="if i-long-text-light text-gray-800 text-base mt-1 md:mt-0.5 if-w-14 rtlFlip if-h-16"
                    />
                    <span className="ms-2 md:ms-4 tracking-wide w-full">
                      {t("submission_acceptable")->str}
                    </span>
                  </label>
                  <div id="is_acceptable" className="flex toggle-button__group shrink-0 rounded-lg">
                    <button
                      onClick={updateIsAcceptable(true, send)}
                      className={booleanButtonClasses(state.isAcceptable)}>
                      {ts("_yes") |> str}
                    </button>
                    <button
                      onClick={updateIsAcceptable(false, send)}
                      className={booleanButtonClasses(!state.isAcceptable)}>
                      {ts("_no") |> str}
                    </button>
                  </div>
                </div>
                {switch state.isAcceptable {
                | true =>
                  <div>
                    <h5 className="font-medium text-sm flex items-center">
                      <Icon className="if i-tachometer-light text-gray-800 text-base" />
                      <span className="ms-2 md:ms-3 tracking-wide"> {t("grade_card")->str} </span>
                    </h5>
                    <div className="flex md:flex-row flex-col md:ms-8 rounded-lg mt-2">
                      <div className="w-full">
                        <div className="space-y-6 max-w-2xl">
                          {renderGradePills(
                            evaluationCriteria,
                            targetEvaluationCriteriaIds,
                            submissionDetails,
                            state,
                            send,
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                | false =>
                  <div className="md:ps-8 text-sm w-full">
                    <p className="bg-gray-100 rounded-lg p-4">
                      <span className="font-semibold"> {t("rejection_help_note_title")->str} </span>
                      {t("rejection_help_note")->str}
                    </p>
                  </div>
                }}
              </div>
              <div
                className="flex gap-4 overflow-x-auto bg-white md:bg-gray-50 border-t px-4 md:px-6 py-2 md:py-4 mt-4 md:mt-8">
                <button
                  disabled={reviewButtonDisabled(status)}
                  className="btn btn-primary btn-large w-full border border-green-600 md:ms-8"
                  onClick={event =>
                    gradeSubmission(
                      OverlaySubmission.id(overlaySubmission),
                      state,
                      send,
                      updateSubmissionCB,
                      status,
                      currentUser,
                      overlaySubmission,
                      event,
                      SubmissionDetails.courseId(submissionDetails),
                      filter,
                    )}>
                  {submitButtonText(state.isAcceptable, state.newFeedback, state.grades)->str}
                </button>
              </div>
              {ReactUtils.nullIf(
                <div className="p-4 md:p-6">
                  <h5 className="font-medium text-sm flex items-center">
                    <PfIcon
                      className="if i-comment-alt-light text-gray-800 text-base md:text-lg inline-block"
                    />
                    <span className="ms-2 md:ms-3 tracking-wide"> {t("feedback")->str} </span>
                  </h5>
                  {showFeedback(OverlaySubmission.feedback(overlaySubmission))}
                </div>,
                ArrayUtils.isEmpty(OverlaySubmission.feedback(overlaySubmission)),
              )}
            </div>

          | ChecklistEditor =>
            <div>
              <CoursesReview__Checklist
                reviewChecklist
                updateFeedbackCB={feedback =>
                  send(
                    GenerateFeeback(
                      feedback,
                      findEditor(
                        OverlaySubmission.evaluatedAt(overlaySubmission),
                        overlaySubmission,
                      ),
                    ),
                  )}
                feedback=state.newFeedback
                updateReviewChecklistCB={updateReviewChecklist(updateReviewChecklistCB, send)}
                targetId
                cancelCB={_ =>
                  send(
                    UpdateEditor(
                      findEditor(
                        OverlaySubmission.evaluatedAt(overlaySubmission),
                        overlaySubmission,
                      ),
                    ),
                  )}
                overlaySubmission
                submissionDetails
              />
            </div>

          | ReviewedSubmissionEditor(grades) =>
            <div>
              <div
                className="flex items-center justify-between px-4 md:px-6 py-3 bg-white border-b border-t lg:border-t-0 sticky top-0 z-50 md:h-16">
                <div>
                  <p className="font-semibold"> {str(t("review"))} </p>
                  {Belt.Option.mapWithDefault(
                    OverlaySubmission.evaluatedAt(overlaySubmission),
                    React.null,
                    date =>
                      <p className="text-gray-800 text-xs">
                        {date->DateFns.format("MMMM d, yyyy")->str}
                      </p>,
                  )}
                </div>
                {submissionReviewStatus(status, overlaySubmission)}
              </div>
              <div className="w-full p-4 md:p-6">
                {switch (OverlaySubmission.evaluatedAt(overlaySubmission), status) {
                | (Some(_), Passed) =>
                  <div className="flex items-center justify-between">
                    <h5 className="font-medium text-sm flex items-center">
                      <Icon className="if i-tachometer-light text-gray-800 text-base" />
                      <span className="ms-2 md:ms-3 tracking-wide"> {t("grade_card")->str} </span>
                    </h5>
                    <div>
                      <div>
                        <button
                          onClick={_ =>
                            WindowUtils.confirm(t("undo_grade_warning"), () =>
                              OverlaySubmission.id(overlaySubmission)->undoGrading(send)
                            )}
                          disabled={isReviewDisabled(submissionDetails)}
                          className="btn btn-small bg-red-100 text-red-800 hover:bg-red-200 focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500">
                          <i className="fas fa-undo" />
                          <span className="ms-2"> {t("undo_grading")->str} </span>
                        </button>
                      </div>
                    </div>
                  </div>
                | (Some(_), Rejected) =>
                  <div
                    className="flex flex-col md:flex-row md:items-center justify-between bg-red-50 rounded-lg p-4">
                    <div>
                      <p className="text-sm font-semibold">
                        {t("undo_rejection_notice_title")->str}
                      </p>
                      <div>
                        <span className="text-sm">
                          {switch OverlaySubmission.evaluatorName(overlaySubmission) {
                          | Some(name) => name->str
                          | None => <em> {t("deleted_coach")->str} </em>
                          }}
                        </span>
                        <span className="text-sm"> {t("undo_rejection_notice")->str} </span>
                      </div>
                    </div>
                    <div>
                      <button
                        onClick={_ =>
                          WindowUtils.confirm(t("undo_rejection_warning"), () =>
                            OverlaySubmission.id(overlaySubmission)->undoGrading(send)
                          )}
                        disabled={isReviewDisabled(submissionDetails)}
                        className="btn btn-small mt-2 md:mt-0 bg-red-100 md:bg-red-50 text-red-800 hover:bg-red-200 focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500">
                        <i className="fas fa-undo" />
                        <span className="ms-2"> {t("undo_rejection")->str} </span>
                      </button>
                    </div>
                  </div>
                | (None, Passed)
                | (None, Rejected)
                | (_, Grading)
                | (_, Unreviewed) => React.null
                }}
                <div className="flex md:flex-row flex-col md:ms-8 bg-gray-50 mt-2">
                  <div className="w-full">
                    {showGrades(grades, evaluationCriteria, submissionDetails, state)}
                  </div>
                  <div className="block md:hidden">
                    {submissionStatusIcon(status, overlaySubmission)}
                  </div>
                </div>
              </div>
              {ReactUtils.nullUnless(
                <div>
                  {feedbackGenerator(submissionDetails, reviewChecklist, state, send)}
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
                      {t("share_feedback")->str}
                    </button>
                  </div>
                </div>,
                state.additonalFeedbackEditorVisible,
              )}
              <div className="p-4 md:p-6 pb-18 md:pb-20">
                <h5 className="font-medium text-sm flex items-center">
                  <PfIcon
                    className="if i-comment-alt-light text-gray-800 text-base md:text-lg inline-block"
                  />
                  <span className="ms-2 md:ms-3 tracking-wide"> {t("feedback")->str} </span>
                </h5>
                {ReactUtils.nullIf(
                  <div className="py-4 md:ms-8 text-center">
                    <button
                      onClick={_ => send(ShowAdditionalFeedbackEditor)}
                      disabled={isReviewDisabled(submissionDetails)}
                      className="bg-primary-100 flex items-center justify-center px-4 py-3 border border-dashed border-primary-500 rounded-md w-full font-semibold text-sm text-primary-600 hover:bg-white hover:text-primary-500 hover:shadow-lg hover:border-primary-300 focus:outline-none transition cursor-pointer focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500">
                      <Icon className="if i-plus-regular" />
                      <p className="ps-2">
                        {switch OverlaySubmission.feedback(overlaySubmission) {
                        | [] => t("add_feedback")
                        | _ => t("add_another_feedback")
                        }->str}
                      </p>
                    </button>
                  </div>,
                  state.additonalFeedbackEditorVisible,
                )}
                {showFeedback(OverlaySubmission.feedback(overlaySubmission))}
              </div>
            </div>
          }}
          <div className="fixed bottom-0 inset-x-0 z-10">
            <div> {reviewNextButton(state.nextSubmission, filter)} </div>
          </div>
        </div>
      </DisablingCover>,
    ]->React.array
  }
}
