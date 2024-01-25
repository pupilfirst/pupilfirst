let str = React.string
let t = I18n.t(~scope="components.CoursesCurriculum__DiscussSubmission")

open CoursesCurriculum__Types

let dropdownSelected =
  <button
    className="text-white md:text-gray-900 bg-gray-900 md:bg-gray-100 appearance-none flex items-center justify-between hover:bg-gray-800 md:hover:bg-gray-50 hover:text-gray-50 focus:bg-gray-50 md:hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-semibold relative px-3 py-2 rounded-md w-full focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 ">
    <span> {"Menu"->str} </span>
    <i className="fas fa-chevron-down text-xs ms-3 font-semibold" />
  </button>

module PinSubmissionMutation = %graphql(`
   mutation PinSubmissionMutation($pinned: Boolean!, $submissionId: String!) {
     pinSubmission(pinned: $pinned, submissionId: $submissionId ) {
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

@react.component
let make = (~currentUser, ~author, ~submission, ~callBack) => {
  let submissionId = submission->DiscussionSubmission.id

  let menuItems = (author, submission, callBack) => {
    let pinned = submission->DiscussionSubmission.pinned
    let items = [
      <button
        className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
        // <i className=icon />

        <span className="font-semibold ms-2"> {"Archive Submission"->str} </span>
      </button>,
    ]
    let pinButton =
      <button
        onClick={pinSubmission(submission, callBack)}
        className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
        // <i className=icon />

        <span className="font-semibold ms-2">
          {switch pinned {
          | true => "Unpin Submission"->str
          | false => "Pin Submission"->str
          }}
        </span>
      </button>
    if author {
      items->Js.Array2.concat([pinButton])
    } else {
      items
    }
  }

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
    <Dropdown selected={dropdownSelected} contents={menuItems(author, submission, callBack)} />
    <div className="rounded-lg bg-gray-50 border shadow-md overflow-hidden">
      <CoursesCurriculum__ModerationReportButton
        currentUser
        moderationReports={submission->DiscussionSubmission.moderationReports}
        reportableId={submission->DiscussionSubmission.id}
        reportableType={"TimelineEvent"}
      />
      <div className="px-4 py-4 md:px-6 md:pt-6 md:pb-5">
        <SubmissionChecklistShow
          checklist={submission |> DiscussionSubmission.checklist} updateChecklistCB=None
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
