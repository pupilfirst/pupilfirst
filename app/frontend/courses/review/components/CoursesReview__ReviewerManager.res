open CoursesReview__Types
let str = React.string

let t = I18n.t(~scope="components.CoursesReview__ReviewerManager")

module UserProxyFragment = UserProxy.Fragment
module AssignReviewerMutation = %graphql(`
    mutation AssignReviewerMutation($submissionId: ID!) {
      assignReviewer(submissionId: $submissionId){
        reviewer{
          ...UserProxyFragment
        }
      }
    }
  `)

module ReassignReviewerMutation = %graphql(`
    mutation ReassignReviewerMutation($submissionId: ID!) {
      reassignReviewer(submissionId: $submissionId){
        reviewer{
          ...UserProxyFragment
        }
      }
    }
  `)

let assignReviewer = (submissionId, setSaving, updateReviewerCB) => {
  setSaving(_ => true)
  AssignReviewerMutation.make(~notify=false, {submissionId: submissionId})
  |> Js.Promise.then_(response => {
    updateReviewerCB(Some(UserProxy.makeFromJs(response["assignReviewer"]["reviewer"])))
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
  ReassignReviewerMutation.make({submissionId: submissionId})
  |> Js.Promise.then_(response => {
    updateReviewerCB(Some(UserProxy.makeFromJs(response["reassignReviewer"]["reviewer"])))
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

  <div className="w-full p-4 md:p-6 space-y-8 mx-auto">
    <div>
      {switch SubmissionDetails.reviewer(submissionDetails) {
      | Some(reviewer) => [
          <div className="inline-flex bg-gray-50 px-3 py-2 mt-2 rounded-md" key="reviewer-details">
            {switch UserProxy.avatarUrl(Reviewer.user(reviewer)) {
            | Some(avatarUrl) =>
              <img
                className="h-9 w-9 md:h-10 md:w-10 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 object-cover"
                src=avatarUrl
              />
            | None =>
              <Avatar
                name={UserProxy.name(Reviewer.user(reviewer))}
                className="h-9 w-9 md:h-10 md:w-10 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 object-cover"
              />
            }}
            <div className="ms-2">
              <p className="text-sm font-semibold">
                {UserProxy.name(Reviewer.user(reviewer))->str}
              </p>
              <p className="text-xs text-gray-800">
                {t(
                  ~variables=[
                    (
                      "date",
                      DateFns.formatDistanceToNow(
                        Reviewer.assignedAt(reviewer),
                        ~addSuffix=true,
                        (),
                      ),
                    ),
                  ],
                  "assigned_at",
                )->str}
              </p>
            </div>
          </div>,
          <div className="flex flex-col md:flex-row items-center mt-4" key="change-reviewer-button">
            <p className="text-sm pe-4">
              {t(
                ~variables=[("current_coach_name", UserProxy.name(Reviewer.user(reviewer)))],
                "remove_reviewer_assign_to_me",
              )->str}
            </p>
            <button
              disabled=saving
              onClick={_ => reassignReviewer(submissionId, setSaving, updateReviewerCB)}
              className="btn md:btn-small btn-default w-full md:w-auto mt-2 md:mt-0">
              {str(t("change_reviewer_and_start_review"))}
            </button>
          </div>,
        ]
      | None => [
          <div className="flex items-center justify-center" key="no-reviewer">
            <div
              className="h-24 w-24 md:h-30 md:w-30 rounded-xl bg-gray-100 flex items-center justify-center">
              <Icon className="if i-eye-solid text-gray-400 text-4xl" />
            </div>
          </div>,
          <div className="flex items-center justify-center mt-4" key="start-review">
            <button
              disabled=saving
              onClick={_ => assignReviewer(submissionId, setSaving, updateReviewerCB)}
              className="btn btn-primary w-full md:w-auto">
              {str(t("start_review"))}
            </button>
          </div>,
        ]
      }->React.array}
    </div>
  </div>
}
