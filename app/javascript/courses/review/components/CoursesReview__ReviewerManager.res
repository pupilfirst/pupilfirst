open CoursesReview__Types
let str = React.string

module AssignReviewerMutation = %graphql(
  `
    mutation AssignReviewerMutation($submissionId: ID!) {
      assignReviewer(submissionId: $submissionId){
        reviewer{
          id, userId, name, title, avatarUrl
        }
      }
    }
  `
)

module ReassignReviewerMutation = %graphql(
  `
    mutation ReassignReviewerMutation($submissionId: ID!) {
      reassignReviewer(submissionId: $submissionId){
        reviewer{
          id, userId, name, title, avatarUrl
        }
      }
    }
  `
)

let assignReviewer = (submissionId, setSaving, updateReviewerCB) => {
  setSaving(_ => true)
  AssignReviewerMutation.make(~submissionId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    updateReviewerCB(Some(Reviewer.makeFromJs(response["assignReviewer"]["reviewer"])))
    setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> ignore
}

let reassignReviewer = (submissionId, setSaving, updateReviewerCB) => {
  setSaving(_ => true)
  ReassignReviewerMutation.make(~submissionId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    updateReviewerCB(Some(Reviewer.makeFromJs(response["reassignReviewer"]["reviewer"])))
    setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~submissionId, ~submissionDetails, ~updateReviewerCB) => {
  let (saving, setSaving) = React.useState(_ => false)

  <div className="w-full px-4 md:px-6 pt-8 space-y-8 mx-auto">
    <div className="flex flex-col justify-center items-center">
      {switch SubmissionDetails.reviewer(submissionDetails) {
      | Some(reviewer) =>
        [
          {
            switch Reviewer.avatarUrl(reviewer) {
            | Some(avatarUrl) =>
              <img
                className="h-40 w-40 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover"
                src=avatarUrl
              />
            | None =>
              <Avatar
                name={Reviewer.name(reviewer)}
                className="h-40 w-40 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover"
              />
            }
          },
          <div className="text-sm mt-4"> {"Reviewer"->str} </div>,
          <div className="text-md font-semibold"> {Reviewer.name(reviewer)->str} </div>,
          {
            switch SubmissionDetails.reviewerAssignedAt(submissionDetails) {
            | Some(date) =>
              <p className="text-xs">
                {str(`Assigned ${DateFns.formatDistanceToNow(date, ~addSuffix=true, ())} `)}
              </p>
            | None => React.null
            }
          },
        ]->React.array
      | None =>
        <div className="h-40 w-40 rounded-full bg-gray-300 flex items-center justify-center">
          <Icon className="if i-eye-solid text-gray-800 text-6xl" />
        </div>
      }}
      <div className="mt-4">
        {Belt.Option.isSome(SubmissionDetails.reviewer(submissionDetails))
          ? <button
              disabled=saving
              onClick={_ => reassignReviewer(submissionId, setSaving, updateReviewerCB)}
              className="btn btn-primary btn-large">
              {str("Assign to me!")}
            </button>
          : <button
              disabled=saving
              onClick={_ => assignReviewer(submissionId, setSaving, updateReviewerCB)}
              className="btn btn-primary btn-large">
              {str("Start Review")}
            </button>}
      </div>
    </div>
  </div>
}
