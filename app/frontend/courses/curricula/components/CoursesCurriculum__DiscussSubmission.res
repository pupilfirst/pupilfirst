let str = React.string
let t = I18n.t(~scope="components.CoursesCurriculum__DiscussSubmission")

open CoursesCurriculum__Types

module PinSubmissionMutation = %graphql(`
   mutation PinSubmissionMutation($pinned: Boolean!, $submissionId: String!) {
     pinSubmission(pinned: $pinned, submissionId: $submissionId ) {
       success
     }
   }
   `)

module HideSubmissionMutation = %graphql(`
   mutation HideSubmissionMutation($submissionId: String!, $hide: Boolean!) {
     hideSubmission(submissionId: $submissionId, hide: $hide ) {
       success
     }
   }
   `)

let pinSubmission = (submission, callBack, event) => {
  ReactEvent.Mouse.preventDefault(event)
  let pinned = !(submission->DiscussionSubmission.pinned)
  let submissionId = submission->DiscussionSubmission.id
  PinSubmissionMutation.make({pinned, submissionId})
  |> Js.Promise.then_(response => {
    switch response["pinSubmission"]["success"] {
    | true => callBack(submission->DiscussionSubmission.targetId)
    | false => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let hideSubmission = (submission, hide, callBack, event) => {
  ReactEvent.Mouse.preventDefault(event)

  let submissionId = submission->DiscussionSubmission.id
  HideSubmissionMutation.make({submissionId, hide})
  |> Js.Promise.then_(response => {
    switch response["hideSubmission"]["success"] {
    | true => callBack(submission->DiscussionSubmission.targetId)
    | false => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~currentUser, ~author, ~submission, ~callBack) => {
  let submissionId = submission->DiscussionSubmission.id
  let submissionHidden = Belt.Option.isSome(submission->DiscussionSubmission.hiddenAt)

  <div
    key={submissionId}
    className="mt-4 pb-4 relative curriculum__submission-feedback-container"
    ariaLabel={submission |> DiscussionSubmission.createdAtPretty}>
    <div className="flex justify-between items-end">
      {switch submission->DiscussionSubmission.anonymous {
      | true =>
        <span>
          {str(t("submitted_by"))}
          <span className="font-semibold"> {t("anonymous")->str} </span>
        </span>
      | false =>
        switch DiscussionSubmission.teamName(submission) {
        | Some(name) =>
          <span>
            {str(t("submitted_by_team"))}
            <span className="font-semibold"> {str(name)} </span>
          </span>
        | None =>
          <span>
            {str(t("submitted_by"))}
            <span className="font-semibold">
              {DiscussionSubmission.userNames(submission)->str}
            </span>
          </span>
        }
      }}
      <span className="ms-1" title={DiscussionSubmission.createdAtPretty(submission)}>
        {{
          t(
            ~variables=[("created_at", DiscussionSubmission.createdAtPretty(submission))],
            "created_at",
          )
        }->str}
      </span>
    </div>
    {switch submissionHidden {
    | true =>
      <div>
        <p>
          {("This submission was hidden by course moderators on " ++
          submission->DiscussionSubmission.hiddenAtPretty)->str}
        </p>
      </div>
    | false => React.null
    }}
    {switch author {
    | false => React.null
    | true =>
      <div>
        <button
          onClick={pinSubmission(submission, callBack)}
          className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
          // <i className=icon />

          <span className="font-semibold ms-2">
            {switch submission->DiscussionSubmission.pinned {
            | true => "Unpin Submission"->str
            | false => "Pin Submission"->str
            }}
          </span>
        </button>
        <button
          onClick={hideSubmission(submission, !submissionHidden, callBack)}
          className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
          // <i className=icon />

          <span className="font-semibold ms-2">
            {switch submissionHidden {
            | true => "Un-hide submission"->str
            | false => "Hide submission"->str
            }}
          </span>
        </button>
      </div>
    }}
    <div className="rounded-lg bg-gray-50 border shadow-md overflow-hidden">
      <CoursesCurriculum__ModerationReportButton
        currentUser
        moderationReports={submission->DiscussionSubmission.moderationReports}
        reportableId={submission->DiscussionSubmission.id}
        reportableType={"TimelineEvent"}
      />
      <div className="px-4 py-4 md:px-6 md:pt-6 md:pb-5">
        <SubmissionChecklistShow
          checklist={submission |> DiscussionSubmission.checklist}
          updateChecklistCB=None
          forDiscussion=true
        />
      </div>
      <CoursesCurriculum__Reactions
        reactionableType="TimelineEvent"
        reactionableId={submissionId}
        reactions={submission->DiscussionSubmission.reactions}
      />
      <CoursesCurriculum__SubmissionComments
        currentUser author submissionId comments={submission->DiscussionSubmission.comments}
      />
    </div>
  </div>
}
