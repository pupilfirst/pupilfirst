let str = React.string

open CoursesReview__Types

type state =
  | Loading
  | Loaded(SubmissionDetails.t)

module UserProxyFragment = UserProxy.Fragment
module SubmissionDetailsQuery = %graphql(`
    query SubmissionDetailsQuery($submissionId: ID!) {
      submissionDetails(submissionId: $submissionId) {
        targetId, targetTitle, createdAt, submissionReportPollTime
        students {
          id
          name
        },
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
        evaluationCriteria{
          id, name, maxGrade, gradeLabels { grade label}
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
          id, evaluatorName, passedAt, createdAt, evaluatedAt, archivedAt
          files{
            url, title, id
          },
          grades {
            evaluationCriterionId, grade
          },
          feedback{
            id, coachName, coachAvatarUrl, coachTitle, createdAt, value
          },
          checklist,
        }
        allSubmissions{
          id, passedAt, createdAt, evaluatedAt, feedbackSent, archivedAt
        }
        coaches{
          ...UserProxyFragment
        }
        teamName
        courseId
        reviewable
        warning
        reviewerDetails{
          assignedAt
          user {
            ...UserProxyFragment
          }
        }
      }
    }
  `)

let getSubmissionDetails = (submissionId, setState, ()) => {
  setState(_ => Loading)
  SubmissionDetailsQuery.make({submissionId: submissionId})
  |> Js.Promise.then_(response => {
    setState(_ => Loaded(SubmissionDetails.decodeJs(response["submissionDetails"])))
    Js.Promise.resolve()
  })
  |> ignore

  None
}

let updateSubmission = (setState, submissionDetails, overlaySubmission) => {
  let newSubmissionDetails = SubmissionDetails.updateOverlaySubmission(
    overlaySubmission,
    submissionDetails,
  )

  setState(_ => Loaded(newSubmissionDetails))
}

let currentSubmissionIndex = (submissionId, allSubmissions) => {
  Js.Array.length(allSubmissions) - Js.Array.findIndex(s => {
    SubmissionMeta.id(s) == submissionId
  }, allSubmissions)
}

let updateReviewChecklist = (submissionDetails, setState, reviewChecklist) =>
  setState(_ => Loaded(SubmissionDetails.updateReviewChecklist(reviewChecklist, submissionDetails)))

let updateReviewer = (submissionDetails, setState, reviewer) => {
  setState(_ => Loaded(SubmissionDetails.updateReviewer(reviewer, submissionDetails)))
}

let updateSubmissionReport = (submissionDetails, setState, submissionReports) => {
  setState(_ => Loaded(
    SubmissionDetails.updateSubmissionReport(submissionReports, submissionDetails),
  ))
}

@react.component
let make = (~submissionId, ~currentUser) => {
  let (state, setState) = React.useState(() => Loading)

  React.useEffect1(getSubmissionDetails(submissionId, setState), [submissionId])

  <div
    className="flex-1 md:flex md:flex-col md:overflow-hidden fixed z-[50] inset-0 overflow-y-auto bg-white">
    {switch state {
    | Loaded(submissionDetails) =>
      <CoursesReview__Editor
        overlaySubmission={SubmissionDetails.submission(submissionDetails)}
        teamSubmission={SubmissionDetails.students(submissionDetails)->Js.Array2.length > 1}
        evaluationCriteria={SubmissionDetails.evaluationCriteria(submissionDetails)}
        targetEvaluationCriteriaIds={SubmissionDetails.targetEvaluationCriteriaIds(
          submissionDetails,
        )}
        reviewChecklist={SubmissionDetails.reviewChecklist(submissionDetails)}
        updateSubmissionCB={updateSubmission(setState, submissionDetails)}
        updateReviewChecklistCB={updateReviewChecklist(submissionDetails, setState)}
        submissionReports={SubmissionDetails.submissionReports(submissionDetails)}
        targetId={SubmissionDetails.targetId(submissionDetails)}
        number={currentSubmissionIndex(
          submissionId,
          SubmissionDetails.allSubmissions(submissionDetails),
        )}
        currentUser
        submissionDetails
        submissionId
        updateReviewerCB={updateReviewer(submissionDetails, setState)}
        updateSubmissionReportCB={updateSubmissionReport(submissionDetails, setState)}
        submissionReportPollTime={SubmissionDetails.submissionReportPollTime(submissionDetails)}
      />

    | Loading =>
      <div>
        <div className="bg-gray-50 md:px-4">
          <div className="mx-auto"> {SkeletonLoading.card()} </div>
        </div>
        <div className="grid md:grid-cols-2 mt-10 border-t h-full">
          <div className="md:px-4 bg-white">
            {SkeletonLoading.heading()}
            {SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.paragraph())}
          </div>
          <div className="md:px-4 bg-gray-50 border-s">
            {SkeletonLoading.userDetails()}
            {SkeletonLoading.paragraph()}
            {SkeletonLoading.userDetails()}
            {SkeletonLoading.paragraph()}
          </div>
        </div>
      </div>
    }}
  </div>
}
