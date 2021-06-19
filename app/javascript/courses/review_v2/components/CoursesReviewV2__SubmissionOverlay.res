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
        coachIds
        teamName
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

let closeOverlay = courseId => RescriptReactRouter.push("/courses/" ++ (courseId ++ "/review_v2"))

@react.component
let make = (~submissionId) => {
  let (state, setState) = React.useState(() => Loading)

  React.useEffect1(getSubmissionDetails(submissionId, setState), [submissionId])

  <div>
    {switch state {
    | Loaded(submissionDetails) =>
      // let assignedCoaches =
      //   teamCoaches |> Js.Array.filter(coach =>
      //     submissionDetails |> SubmissionDetails.coachIds |> Array.mem(coach |> Coach.id)
      //   )

      <div>
        // {headerSection(submissionDetails, courseId, assignedCoaches)}
        <div className="container mx-auto max-w-7xl"> {inactiveWarning(submissionDetails)} </div>
        <div className="flex space-x-2 overflow-x-auto px-4">
          {Js.Array.mapi(
            (submission, index) =>
              <CoursesReviewV2__SubmissionInfoCard
                key={SubmissionMeta.id(submission)}
                submission
                submissionNumber={Array.length(SubmissionDetails.allSubmissions(submissionDetails)) -
                index}
              />,
            SubmissionDetails.allSubmissions(submissionDetails),
          )->React.array}
        </div>
      </div>

    | Loading =>
      <div>
        <div className="bg-gray-100 py-4">
          <div className="max-w-3xl mx-auto"> {SkeletonLoading.card()} </div>
        </div>
        <div className="max-w-3xl mx-auto">
          {SkeletonLoading.heading()}
          {SkeletonLoading.paragraph()}
          {SkeletonLoading.profileCard()}
          {SkeletonLoading.paragraph()}
        </div>
      </div>
    }}
  </div>
}
