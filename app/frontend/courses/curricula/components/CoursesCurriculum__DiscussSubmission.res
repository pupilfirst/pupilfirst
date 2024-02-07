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

let hideSubmission = (submission, hide, setSubmissionHidden, event) => {
  ReactEvent.Mouse.preventDefault(event)

  let submissionId = submission->DiscussionSubmission.id
  HideSubmissionMutation.make({submissionId, hide})
  |> Js.Promise.then_(response => {
    switch response["hideSubmission"]["success"] {
    | true => setSubmissionHidden(_ => hide)
    | false => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~currentUser, ~author, ~submission, ~callBack) => {
  let submissionId = submission->DiscussionSubmission.id
  let (submissionHidden, setSubmissionHidden) = React.useState(() =>
    Belt.Option.isSome(submission->DiscussionSubmission.hiddenAt)
  )

  <div
    key={submissionId}
    className="mt-4 pb-4 relative curriculum__submission-feedback-container"
    ariaLabel={submission |> DiscussionSubmission.createdAtPretty}>
    <div className="flex justify-between">
      <div className="flex gap-3">
        <div
          className="w-8 h-8 uppercase text-xs font-semibold border bg-gray-200 rounded-full flex items-center justify-center">
          <span className="font-semibold" />
        </div>
        <div className="flex flex-col flex-wrap">
          {switch submission->DiscussionSubmission.anonymous {
          | true =>
            <span>
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
              <span className="font-semibold text-xs leading-tight block md:inline-flex">
                {DiscussionSubmission.userNames(submission)->str}
              </span>
            }
          }}
          <span
            className="text-xs text-gray-600 leading-tight pt-1"
            title={DiscussionSubmission.createdAtPretty(submission)}>
            {{
              t(
                ~variables=[("created_at", DiscussionSubmission.createdAtPretty(submission))],
                "created_at",
              )
            }->str}
          </span>
        </div>
      </div>
      {switch submissionHidden {
      | true =>
        <div>
          <p> {"This submission is hidden from discussions"->str} </p>
        </div>
      | false => React.null
      }}
      {switch author {
      | false => React.null
      | true =>
        <div>
          <button
            onClick={pinSubmission(submission, callBack)}
            className="cursor-pointer block p-1 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
            // <i className=icon />

            <span className="font-semibold ms-2">
              {switch submission->DiscussionSubmission.pinned {
              | true => "Unpin Submission"->str
              | false => "Pin Submission"->str
              }}
            </span>
          </button>
          <button
            onClick={hideSubmission(submission, !submissionHidden, setSubmissionHidden)}
            className="cursor-pointer block p-1 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
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
    </div>
    <div className="relative">
      <div className="absolute w-8 top-0 left-0 bottom-0 flex justify-center items-center z-0">
        <div className="w-px h-full border-l border-gray-300" />
      </div>
      <div className="ms-11 pb-4">
        <SubmissionChecklistShow
          checklist={submission |> DiscussionSubmission.checklist}
          updateChecklistCB=None
          forDiscussion=true
        />
      </div>
      <CoursesCurriculum__ModerationReportButton
        currentUser
        moderationReports={submission->DiscussionSubmission.moderationReports}
        reportableId={submission->DiscussionSubmission.id}
        reportableType={"TimelineEvent"}
      />
      <CoursesCurriculum__Reactions
        currentUser
        reactionableType="TimelineEvent"
        reactionableId={submissionId}
        reactions={submission->DiscussionSubmission.reactions}
      />
      <div className="relative ms-11">
        // <div className="flex justify-end align-start relative bg-gray-50">
        //   <div
        //     className="h-6 border-b cursor-pointer w-7 border-l border-gray-300 rounded-bl-3xl"
        //   />
        // </div>
        <CoursesCurriculum__SubmissionComments
          currentUser author submissionId comments={submission->DiscussionSubmission.comments}
        />
      </div>
    </div>
  </div>
}
