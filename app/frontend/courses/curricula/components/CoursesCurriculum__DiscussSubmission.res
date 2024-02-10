let str = React.string
let t = I18n.t(~scope="components.CoursesCurriculum__DiscussSubmission")

open CoursesCurriculum__Types

module PinSubmissionMutation = %graphql(`
   mutation PinSubmissionMutation($pin: Boolean!, $submissionId: String!) {
     pinSubmission(pin: $pin, submissionId: $submissionId ) {
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
  let pin = !(submission->DiscussionSubmission.pinned)
  let submissionId = submission->DiscussionSubmission.id
  PinSubmissionMutation.make({pin, submissionId})
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

let pinnedClasses = pinned => {
  switch pinned {
  | true => ""
  | false => ""
  }
}

@react.component
let make = (~currentUser, ~submission, ~callBack) => {
  let submissionId = submission->DiscussionSubmission.id
  let (submissionHidden, setSubmissionHidden) = React.useState(() =>
    Belt.Option.isSome(submission->DiscussionSubmission.hiddenAt)
  )

  let teamStrength = Belt.Array.length(submission->DiscussionSubmission.users)

  <div
    key={submissionId}
    className={"mt-4 pb-4 relative curriculum__submission-feedback-container" ++
    pinnedClasses(submission->DiscussionSubmission.pinned)}
    ariaLabel={submission |> DiscussionSubmission.createdAtPretty}>
    <div className="flex items-start justify-between">
      <div className="flex gap-3">
        <div className="isolate flex -space-x-2 overflow-hidden">
          <div
            className="w-8 h-8 relative z-10 uppercase text-xs font-semibold border bg-gray-200 rounded-full flex items-center justify-center">
            {switch submission->DiscussionSubmission.anonymous {
            | true => <span className="font-semibold"> {t("anonymous_avatar")->str} </span>
            | false => submission->DiscussionSubmission.firstUser->User.avatar
            }}
            <span className="font-semibold" />
          </div>
          {switch teamStrength {
          | 1 => React.null
          | teamStrength =>
            <div
              className="flex items-center justify-center w-8 h-8 text-xs border bg-gray-200 text-gray-600 relative z-0 rounded-full">
              <span> {("+" ++ Belt.Int.toString(teamStrength - 1))->str} </span>
            </div>
          }}
        </div>
        <div className="flex flex-col flex-wrap">
          {switch submission->DiscussionSubmission.anonymous {
          | true =>
            <span className="font-semibold text-xs leading-tight block md:inline-flex">
              {t("anonymous")->str}
            </span>

          | false =>
            switch DiscussionSubmission.teamName(submission) {
            | Some(name) =>
              <span className="font-semibold text-xs leading-tight block md:inline-flex">
                <span className="text-gray-500"> {str(t("submitted_by_team"))} </span>
                <span className="ms-1"> {str(name)} </span>
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
          <p> {t("submission_hidden")->str} </p>
        </div>
      | false => React.null
      }}
      <div className="flex space-x-2">
        {switch currentUser->CurrentUser.isModerator {
        | false => React.null
        | true =>
          <div className="flex space-x-2">
            <button
              onClick={pinSubmission(submission, callBack)}
              className="flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 focus:outline-none focus:text-gray-800 focus:bg-gray-50 whitespace-nowrap">
              {switch submission->DiscussionSubmission.pinned {
              | true =>
                <span className="flex items-center md:space-x-1">
                  <Icon className="if i-pin-angle-light if-fw" />
                  <span className="hidden md:inline-block text-xs"> {t("unpin")->str} </span>
                </span>
              | false =>
                <span className="flex items-center md:space-x-1">
                  <Icon className="if i-pin-angle-light if-fw" />
                  <span className="hidden md:inline-block text-xs"> {t("pin")->str} </span>
                </span>
              }}
            </button>
            <button
              onClick={hideSubmission(submission, !submissionHidden, setSubmissionHidden)}
              className="flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 focus:outline-none focus:text-gray-800 focus:bg-gray-50 whitespace-nowrap">
              {switch submissionHidden {
              | true =>
                <span className="flex items-center md:space-x-1">
                  <Icon className="if i-eye-closed-light if-fw" />
                  <span className="hidden md:inline-block text-xs"> {t("unhide")->str} </span>
                </span>
              | false =>
                <span className="flex items-center md:space-x-1">
                  <Icon className="if i-eye-light if-fw" />
                  <span className="hidden md:inline-block text-xs"> {t("hide")->str} </span>
                </span>
              }}
            </button>
          </div>
        }}
        <CoursesCurriculum__ModerationReportButton
          currentUser
          moderationReports={submission->DiscussionSubmission.moderationReports}
          reportableId={submission->DiscussionSubmission.id}
          reportableType={"TimelineEvent"}
        />
      </div>
    </div>
    <div className="relative">
      <div className="absolute w-8 top-0 left-0 bottom-0 flex justify-center items-center z-0">
        <div className="w-px h-full border-l border-gray-300" />
      </div>
      <div className="ms-11 pb-4 pt-6">
        <SubmissionChecklistShow
          checklist={submission |> DiscussionSubmission.checklist}
          updateChecklistCB=None
          forDiscussion=true
        />
      </div>
      <CoursesCurriculum__Reactions
        currentUser
        reactionableType="TimelineEvent"
        reactionableId={submissionId}
        reactions={submission->DiscussionSubmission.reactions}
      />
      <div className="relative ms-11">
        // <div
        //   className="flex justify-end align-start absolute h-full -left-8 -ml-[0.5px] w-8 bg-white ">
        //   <div
        //     className="h-6 border-b cursor-pointer w-7 border-l border-gray-300 rounded-bl-3xl"
        //   />
        // </div>
        <CoursesCurriculum__SubmissionComments
          currentUser submissionId comments={submission->DiscussionSubmission.comments}
        />
      </div>
    </div>
  </div>
}
