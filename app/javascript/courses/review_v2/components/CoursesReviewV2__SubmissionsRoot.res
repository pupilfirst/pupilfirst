let str = React.string

open CoursesReview__Types

type state =
  | Loading
  | Loaded(SubmissionDetails.t)

module SubmissionDetailsQuery = %graphql(
  `
    query SubmissionDetailsQuery($submissionId: ID!) {
      submissionDetails(submissionId: $submissionId) {
        targetId, targetTitle, levelNumber, levelId, inactiveStudents
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
            id, coachName, coachAvatarUrl, coachTitle, createdAt,value
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

let inactiveWarning = submissionDetails =>
  if SubmissionDetails.inactiveStudents(submissionDetails) {
    let warning = if Array.length(SubmissionDetails.students(submissionDetails)) > 1 {
      "This submission is linked to one or more students whose access to the course has ended, or have dropped out."
    } else {
      "This submission is from a student whose access to the course has ended, or has dropped out."
    }

    <div className="border border-yellow-400 rounded bg-yellow-400 py-2 px-3">
      <i className="fas fa-exclamation-triangle" /> <span className="ml-2"> {warning->str} </span>
    </div>
  } else {
    React.null
  }

let closeOverlay = courseId => RescriptReactRouter.push("/courses/" ++ (courseId ++ "/review"))

let headerSection = submissionDetails =>
  <div
    ariaLabel="submissions-overlay-header"
    className="bg-gray-100 border-b border-gray-300 px-3 flex justify-center">
    <div
      className="bg-white border lg:border-transparent p-4 lg:px-6 lg:py-5 flex flex-wrap items-center justify-between rounded-lg shadow w-full">
      <div className="flex">
        <button
          title="Close"
          ariaLabel="submissions-overlay-close"
          onClick={_ => closeOverlay(SubmissionDetails.courseId(submissionDetails))}
          className="flex flex-col items-center justify-center rounded-t-lg lg:rounded-lg leading-tight px-4 py-1 h-8 lg:h-full cursor-pointer border border-b-0 border-gray-400 lg:border-0 lg:shadow lg:border-gray-300 bg-white text-gray-700 hover:text-gray-900 hover:bg-gray-100">
          <Icon className="if i-times-regular text-xl lg:text-2xl mt-1 lg:mt-0" />
          <span className="text-xs hidden lg:inline-block mt-px"> {str("close")} </span>
        </button>
        <div className="pl-4">
          <div className="block text-sm md:pr-2">
            <span className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
              {LevelLabel.format(SubmissionDetails.levelNumber(submissionDetails))->str}
            </span>
            <a
              href={"/targets/" ++ SubmissionDetails.targetId(submissionDetails)}
              target="_blank"
              className="ml-2 font-semibold underline text-gray-900 hover:bg-primary-100 hover:text-primary-600 text-sm md:text-lg">
              {SubmissionDetails.targetTitle(submissionDetails)->str}
            </a>
          </div>
          <div className="text-left mt-1 text-xs text-gray-800">
            {switch SubmissionDetails.teamName(submissionDetails) {
            | Some(teamName) =>
              <span>
                {"Submitted by team: "->str}
                <span className="font-semibold"> {teamName->str} </span>
                {" - "->str}
              </span>
            | None => <span> {"Submitted by "->str} </span>
            }}
            {
              let studentCount = SubmissionDetails.students(submissionDetails)->Array.length

              Js.Array.mapi((student, index) => {
                let commaRequired = index + 1 != studentCount
                <span key={Student.id(student)}>
                  <a
                    className="font-semibold underline"
                    href={"/students/" ++ (student->Student.id ++ "/report")}
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
      <CoursesStudents__TeamCoaches
        tooltipPosition=#Bottom
        defaultAvatarSize="8"
        mdAvatarSize="8"
        title={<span className="mr-2"> {"Assigned Coaches"->str} </span>}
        className="mt-2 flex w-full md:w-auto items-center flex-shrink-0"
        coaches={SubmissionDetails.coaches(submissionDetails)}
      />
    </div>
  </div>

@react.component
let make = (~submissionId) => {
  let (state, setState) = React.useState(() => Loading)

  React.useEffect1(getSubmissionDetails(submissionId, setState), [submissionId])

  <div>
    {switch state {
    | Loaded(submissionDetails) =>
      <div>
        {headerSection(submissionDetails)}
        <div className="container mx-auto max-w-7xl"> {inactiveWarning(submissionDetails)} </div>
        <div className="flex space-x-2 overflow-x-auto px-4">
          {Js.Array.mapi(
            (submission, index) =>
              <CoursesReviewV2__SubmissionInfoCard
                key={SubmissionMeta.id(submission)}
                selected={SubmissionMeta.id(submission) == submissionId}
                submission
                submissionNumber={Array.length(
                  SubmissionDetails.allSubmissions(submissionDetails),
                ) -
                index}
              />,
            SubmissionDetails.allSubmissions(submissionDetails),
          )->React.array}
        </div>
        <CoursesReviewV2__Editor
          overlaySubmission={SubmissionDetails.submission(submissionDetails)}
          teamSubmission={submissionDetails |> SubmissionDetails.students |> Array.length > 1}
          evaluationCriteria={submissionDetails |> SubmissionDetails.evaluationCriteria}
          targetEvaluationCriteriaIds={submissionDetails |> SubmissionDetails.targetEvaluationCriteriaIds}
          reviewChecklist={submissionDetails |> SubmissionDetails.reviewChecklist}
          addGradingCB={_ => ()}
          updateReviewChecklistCB={_ => ()}
          targetId={submissionDetails |> SubmissionDetails.targetId}
        />
      </div>

    | Loading =>
      <div>
        <div className="bg-gray-100 py-4">
          <div className="mx-auto"> {SkeletonLoading.card()} </div>
        </div>
        <div className="mx-auto">
          {SkeletonLoading.heading()}
          {SkeletonLoading.paragraph()}
          {SkeletonLoading.profileCard()}
          {SkeletonLoading.paragraph()}
        </div>
      </div>
    }}
  </div>
}
