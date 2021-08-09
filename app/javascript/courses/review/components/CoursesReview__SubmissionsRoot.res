let str = React.string

let t = I18n.t(~scope="components.CoursesReview__SubmissionsRoot")

open CoursesReview__Types

type state =
  | Loading
  | Loaded(SubmissionDetails.t)

type nextSubmission = DataUnloaded | DataLoading | DataLoaded

module SubmissionDetailsQuery = %graphql(
  `
    query SubmissionDetailsQuery($submissionId: ID!) {
      submissionDetails(submissionId: $submissionId) {
        targetId, targetTitle, levelNumber, levelId, inactiveStudents, createdAt,
        students {
          id
          name
        },
        evaluationCriteria{
          id, name, maxGrade, passGrade, gradeLabels { grade label}
        },
        reviewChecklist{
          title
          result{
            title
            feedback
          }
        },
        targetEvaluationCriteriaIds,
        submission{
          id, evaluatorName, passedAt, createdAt, evaluatedAt
          files{
            url, title, id
          },
          grades {
            evaluationCriterionId, grade
          },
          feedback{
            id, coachName, coachAvatarUrl, coachTitle, createdAt, value
          },
          checklist
        }
        allSubmissions{
          id, passedAt, createdAt, evaluatedAt, feedbackSent
        }
        coaches{
          id, userId, name, title, avatarUrl
        }
        teamName
        courseId
      }
    }
  `
)

module NextSubmissionQuery = %graphql(
  `
    query NextSubmissionQuery($courseId: ID!, $search: String, $targetId: ID, $status: SubmissionStatus, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $coachId: ID, $excludeSubmissionId: ID, $after: String) {
      submissions(courseId: $courseId, search: $search, targetId: $targetId, status: $status, sortDirection: $sortDirection, excludeSubmissionId: $excludeSubmissionId, sortCriterion: $sortCriterion, levelId: $levelId, coachId: $coachId, first: 1, after: $after) {
        nodes {
          id
        }
      }
    }
  `
)

let getSubmissionDetails = (submissionId, setState, ()) => {
  setState(_ => Loading)
  SubmissionDetailsQuery.make(~submissionId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    setState(_ => Loaded(SubmissionDetails.decodeJs(response["submissionDetails"])))
    Js.Promise.resolve()
  })
  |> ignore

  None
}

let getNextSubmission = (setNextSubmission, courseId, filter, submissionId) => {
  setNextSubmission(_ => DataLoading)
  NextSubmissionQuery.make(
    ~courseId,
    ~status=?Filter.tab(filter),
    ~sortDirection=Filter.sortDirection(filter),
    ~sortCriterion=Filter.sortCriterion(filter),
    ~levelId=?Filter.levelId(filter),
    ~coachId=?Filter.coachId(filter),
    ~targetId=?Filter.targetId(filter),
    ~search=?Filter.nameOrEmail(filter),
    ~excludeSubmissionId=?Some(submissionId),
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    setNextSubmission(_ => DataLoaded)
    if ArrayUtils.isEmpty(response["submissions"]["nodes"]) {
      setNextSubmission(_ => DataLoaded)
      Notification.notice(
        t("getNextSubmission.notice.done"),
        t("getNextSubmission.notice.done_description"),
      )
    } else {
      RescriptReactRouter.push(
        "/submissions/" ++
        response["submissions"]["nodes"][0]["id"] ++
        "/review?" ++
        Filter.toQueryString(filter),
      )
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let inactiveWarning = submissionDetails =>
  if SubmissionDetails.inactiveStudents(submissionDetails) {
    let warning = if Array.length(SubmissionDetails.students(submissionDetails)) > 1 {
      t("students_dropped_out_message")
    } else {
      t("student_dropped_out_message")
    }

    <div
      className="border border-yellow-400 rounded bg-yellow-200 py-2 px-3 text-xs md:text-sm md:text-center">
      <i className="fas fa-exclamation-triangle" /> <span className="ml-2"> {warning->str} </span>
    </div>
  } else {
    React.null
  }

let closeOverlay = (courseId, filter) =>
  RescriptReactRouter.push("/courses/" ++ courseId ++ "/review?" ++ Filter.toQueryString(filter))

let reviewNextButton = (
  nextSubmission,
  setNextSubmission,
  courseId,
  filter,
  submissionId,
  className,
) => {
  ReactUtils.nullIf(
    <button
      onClick={_ => getNextSubmission(setNextSubmission, courseId, filter, submissionId)}
      disabled={nextSubmission == DataLoading}
      className>
      {ReactUtils.nullUnless(
        <i className="fas fa-spinner fa-pulse mr-2" />,
        nextSubmission == DataLoading,
      )}
      {str(t("review_next"))}
    </button>,
    nextSubmission == DataLoaded,
  )
}

let headerSection = (nextSubmission, setNextSubmission, submissionDetails, filter, submissionId) =>
  <div
    ariaLabel="submissions-overlay-header"
    className="bg-gray-100 border-b border-gray-300 flex justify-center">
    <div className="bg-white flex justify-between w-full">
      <div className="flex flex-col md:flex-row w-full md:w-auto">
        <div className="flex flex-1 md:flex-none justify-between border-b md:border-0">
          <button
            title={t("close")}
            ariaLabel="submissions-overlay-close"
            onClick={_ => closeOverlay(SubmissionDetails.courseId(submissionDetails), filter)}
            className="flex flex-col items-center justify-center leading-tight px-3 py-2 md:px-5 md:py-4 cursor-pointer border-r bg-white text-gray-700 hover:text-gray-900 hover:bg-gray-100">
            <div className="flex items-center justify-center bg-gray-300 rounded-full w-8 h-8">
              <Icon className="if i-times-regular text-lg lg:text-2xl" />
            </div>
            <span className="sr-only"> {str(t("close"))} </span>
          </button>
          <div className="flex space-x-4">
            <CoursesStudents__TeamCoaches
              tooltipPosition=#Bottom
              defaultAvatarSize="8"
              mdAvatarSize="8"
              title={<span className="hidden"> {t("assigned_coaches")->str} </span>}
              className="flex md:hidden items-center flex-shrink-0"
              coaches={SubmissionDetails.coaches(submissionDetails)}
            />
            {reviewNextButton(
              nextSubmission,
              setNextSubmission,
              SubmissionDetails.courseId(submissionDetails),
              filter,
              submissionId,
              "flex flex-shrink-0 items-center md:hidden border-l text-sm font-semibold px-3 py-2 md:px-5 md:py-4",
            )}
          </div>
        </div>
        <div className="px-4 py-3">
          <div className="block text-sm md:pr-2">
            <span className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
              {LevelLabel.format(SubmissionDetails.levelNumber(submissionDetails))->str}
            </span>
            <a
              href={"/targets/" ++ SubmissionDetails.targetId(submissionDetails)}
              target="_blank"
              className="ml-2 font-semibold underline text-gray-900 hover:bg-primary-100 hover:text-primary-600 text-base">
              {SubmissionDetails.targetTitle(submissionDetails)->str}
            </a>
          </div>
          <div className="text-left mt-1 text-xs text-gray-800">
            {switch SubmissionDetails.teamName(submissionDetails) {
            | Some(teamName) =>
              <span>
                {t("submitted_by_team")->str}
                <span className="font-semibold"> {teamName->str} </span>
                {" - "->str}
              </span>
            | None => <span> {t("submitted_by")->str} </span>
            }}
            {
              let studentCount = SubmissionDetails.students(submissionDetails)->Array.length

              Js.Array.mapi((student, index) => {
                let commaRequired = index + 1 != studentCount
                <span key={Student.id(student)}>
                  <a
                    className="font-semibold underline"
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
      <div className="hidden md:flex flex-shrink-0 space-x-6">
        <CoursesStudents__TeamCoaches
          tooltipPosition=#Bottom
          defaultAvatarSize="8"
          mdAvatarSize="8"
          title={<span className="mr-2"> {t("assigned_coaches")->str} </span>}
          className="flex w-full md:w-auto items-center flex-shrink-0"
          coaches={SubmissionDetails.coaches(submissionDetails)}
        />
        {reviewNextButton(
          nextSubmission,
          setNextSubmission,
          SubmissionDetails.courseId(submissionDetails),
          filter,
          submissionId,
          "flex items-center border-l text-sm font-semibold px-5 py-4",
        )}
      </div>
    </div>
  </div>

let updateSubmission = (setState, submissionDetails, overlaySubmission) => {
  let newSubmissionDetails = SubmissionDetails.updateOverlaySubmission(
    overlaySubmission,
    submissionDetails,
  )

  setState(_ => Loaded(newSubmissionDetails))
}

let updateReviewChecklist = (submissionDetails, setState, reviewChecklist) =>
  setState(_ => Loaded(SubmissionDetails.updateReviewChecklist(reviewChecklist, submissionDetails)))

let currentSubmissionIndex = (submissionId, allSubmissions) => {
  Js.Array.length(allSubmissions) - Js.Array.findIndex(s => {
    SubmissionMeta.id(s) == submissionId
  }, allSubmissions)
}

@react.component
let make = (~submissionId, ~currentUser) => {
  let (state, setState) = React.useState(() => Loading)
  let (nextSubmission, setNextSubmission) = React.useState(() => DataUnloaded)
  let url = RescriptReactRouter.useUrl()
  let filter = Filter.makeFromQueryParams(url.search)
  React.useEffect1(getSubmissionDetails(submissionId, setState), [submissionId])

  <div className="flex-1 md:flex md:flex-col md:overflow-hidden">
    {switch state {
    | Loaded(submissionDetails) =>
      [
        <div key="submission-header">
          <div> {inactiveWarning(submissionDetails)} </div>
          {headerSection(
            nextSubmission,
            setNextSubmission,
            submissionDetails,
            filter,
            submissionId,
          )}
          {ReactUtils.nullIf(
            <div
              className="flex space-x-4 overflow-x-auto px-4 md:px-6 py-2 md:py-3 border-b bg-gray-200">
              {Js.Array.mapi(
                (submission, index) =>
                  <CoursesReview__SubmissionInfoCard
                    key={SubmissionMeta.id(submission)}
                    selected={SubmissionMeta.id(submission) == submissionId}
                    submission
                    submissionNumber={Array.length(
                      SubmissionDetails.allSubmissions(submissionDetails),
                    ) -
                    index}
                    filterString={url.search}
                  />,
                SubmissionDetails.allSubmissions(submissionDetails),
              )->React.array}
            </div>,
            Js.Array.length(SubmissionDetails.allSubmissions(submissionDetails)) == 1,
          )}
        </div>,
        <CoursesReview__Editor
          key="submission-editor"
          overlaySubmission={SubmissionDetails.submission(submissionDetails)}
          teamSubmission={SubmissionDetails.students(submissionDetails)->Js.Array2.length > 1}
          evaluationCriteria={SubmissionDetails.evaluationCriteria(submissionDetails)}
          targetEvaluationCriteriaIds={SubmissionDetails.targetEvaluationCriteriaIds(
            submissionDetails,
          )}
          reviewChecklist={SubmissionDetails.reviewChecklist(submissionDetails)}
          updateSubmissionCB={updateSubmission(setState, submissionDetails)}
          updateReviewChecklistCB={updateReviewChecklist(submissionDetails, setState)}
          targetId={SubmissionDetails.targetId(submissionDetails)}
          number={currentSubmissionIndex(
            submissionId,
            SubmissionDetails.allSubmissions(submissionDetails),
          )}
          currentUser
        />,
      ]->React.array
    | Loading =>
      <div>
        <div className="bg-gray-100 md:px-4">
          <div className="mx-auto"> {SkeletonLoading.card()} </div>
        </div>
        <div className="grid md:grid-cols-2 mt-10 border-t h-full">
          <div className="md:px-4 bg-white">
            {SkeletonLoading.heading()}
            {SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.paragraph())}
          </div>
          <div className="md:px-4 bg-gray-100 border-l">
            {SkeletonLoading.profileCard()}
            {SkeletonLoading.paragraph()}
            {SkeletonLoading.profileCard()}
            {SkeletonLoading.paragraph()}
          </div>
        </div>
      </div>
    }}
  </div>
}
