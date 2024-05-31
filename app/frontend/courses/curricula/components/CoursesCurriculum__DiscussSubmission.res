%%raw(`import "./CoursesCurriculum__DiscussSubmission.css"`)

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

let pinSubmission = (submission, callback, event) => {
  ReactEvent.Mouse.preventDefault(event)
  let pin = !(submission->DiscussionSubmission.pinned)
  let submissionId = submission->DiscussionSubmission.id
  PinSubmissionMutation.make({pin, submissionId})
  |> Js.Promise.then_(response => {
    if response["pinSubmission"]["success"] {
      callback(submission->DiscussionSubmission.targetId)
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
    if response["hideSubmission"]["success"] {
      setSubmissionHidden(_ => hide)
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let pinnedClasses = pinned => {
  pinned
    ? "bg-white px-4 md:px-6 pt-6 pb-2 rounded-lg shadow-xl dark:shadow-2xl border border-gray-200/75 dark:border-gray-200"
    : "py-4"
}

@react.component
let make = (~currentUser, ~submission, ~callBack) => {
  let submissionId = submission->DiscussionSubmission.id
  let (submissionHidden, setSubmissionHidden) = React.useState(() =>
    Belt.Option.isSome(submission->DiscussionSubmission.hiddenAt)
  )

  let teamStrength = Belt.Array.length(submission->DiscussionSubmission.users)

  <div
    id={"discuss_submission-" ++ submissionId}
    tabIndex=0
    className={"relative curriculum-discuss-submission__container focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-500 " ++
    pinnedClasses(submission->DiscussionSubmission.pinned) ++ if submissionHidden {
      " curriculum-discuss-submission__hidden max-h-48 overflow-y-hidden"
    } else {
      ""
    }}
    ariaLabel={"discuss_submission-" ++ submissionId}>
    {submission->DiscussionSubmission.pinned
      ? <p
          className={"absolute bg-green-100 inline-flex items-center text-green-800 text-xs border border-green-300 px-1.5 py-0.5 leading-tight rounded-md -top-3 " ++ if (
            submissionHidden
          ) {
            " hidden"
          } else {
            ""
          }}>
          <Icon className="if i-pin-angle-light if-fw" />
          <span className="ps-1.5"> {t("pinned_submission")->str} </span>
        </p>
      : React.null}
    <div className="flex items-start justify-between">
      <div className="flex gap-3">
        <div className="isolate flex -space-x-2 overflow-hidden">
          <div
            className="w-8 h-8 relative z-10 uppercase text-xs font-semibold border bg-gray-200 rounded-full flex items-center justify-center">
            {submission->DiscussionSubmission.anonymous
              ? <span className="font-semibold"> {t("anonymous_avatar")->str} </span>
              : submission->DiscussionSubmission.firstUser->User.avatar}
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
          {submission->DiscussionSubmission.anonymous
            ? <span className="font-semibold text-xs leading-tight block md:inline-flex">
                {t("anonymous_name")->str}
              </span>
            : switch DiscussionSubmission.teamName(submission) {
              | Some(name) =>
                <span className="font-semibold text-xs leading-tight block md:inline-flex">
                  <span className="text-gray-500"> {str(t("submitted_by_team"))} </span>
                  <span className="ms-1"> {str(name)} </span>
                </span>
              | None =>
                <span className="font-semibold text-xs leading-tight block md:inline-flex">
                  {DiscussionSubmission.userNames(submission)->str}
                </span>
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
      <div className="flex space-x-2 relative">
        {currentUser->CurrentUser.isModerator
          ? <div className="flex space-x-2 relative z-[12]">
              <button
                onClick={pinSubmission(submission, callBack)}
                className="curriculum-discuss-submission__pin-button md:hidden md:group-hover:flex md:group-focus-within:flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 whitespace-nowrap focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-600 transition">
                {submission->DiscussionSubmission.pinned
                  ? <span className="flex items-center md:space-x-1">
                      <Icon className="if i-pin-angle-light if-fw" />
                      <span className="hidden md:inline-block text-xs"> {t("unpin")->str} </span>
                    </span>
                  : <span className="flex items-center md:space-x-1">
                      <Icon className="if i-pin-angle-light if-fw" />
                      <span className="hidden md:inline-block text-xs"> {t("pin")->str} </span>
                    </span>}
              </button>
              <button
                onClick={hideSubmission(submission, !submissionHidden, setSubmissionHidden)}
                className="curriculum-discuss-submission__hide-button md:hidden md:group-hover:flex md:group-focus-within:flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 whitespace-nowrap focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-600 transition">
                {submissionHidden
                  ? <span className="flex items-center md:space-x-1">
                      <Icon className="if i-eye-closed-light if-fw" />
                      <span className="hidden md:inline-block text-xs"> {t("unhide")->str} </span>
                    </span>
                  : <span className="flex items-center md:space-x-1">
                      <Icon className="if i-eye-light if-fw" />
                      <span className="hidden md:inline-block text-xs"> {t("hide")->str} </span>
                    </span>}
              </button>
            </div>
          : React.null}
        <div className="relative z-[13]">
          <CoursesCurriculum__ModerationReportButton
            currentUser
            moderationReports={submission->DiscussionSubmission.moderationReports}
            reportableId={submission->DiscussionSubmission.id}
            reportableType={"TimelineEvent"}
          />
        </div>
      </div>
    </div>
    <div className="relative">
      <div className="absolute w-8 top-0 left-0 bottom-0 flex justify-center items-center z-0">
        <div className="w-px h-full bg-gradient-to-b from-gray-300 via-gray-300 " />
      </div>
      <div className="ms-11 pb-4 pt-6">
        <SubmissionChecklistShow
          checklist={submission |> DiscussionSubmission.checklist}
          updateChecklistCB=None
          forDiscussion=true
        />
      </div>
      <div className="flex flex-col gap-4 items-start relative py-4 ps-11">
        <div>
          <CoursesCurriculum__Reactions
            currentUser
            reactionableType="TimelineEvent"
            reactionableId={submissionId}
            reactions={submission->DiscussionSubmission.reactions}
          />
        </div>
        <div className="relative w-full">
          <CoursesCurriculum__SubmissionComments
            currentUser
            submissionId
            comments={submission->DiscussionSubmission.comments}
            commentsInitiallyVisible={false}
          />
        </div>
      </div>
    </div>
    {submissionHidden
      ? <div
          className="absolute -translate-x-1/2 left-1/2 z-[12] flex justify-end mx-auto bottom-px">
          <p
            className="px-2 py-1 bg-white/20 border border-gray-300 border-b-0 whitespace-nowrap rounded-t-lg text-xs leading-tight italic text-gray-500">
            {t("submission_hidden")->str}
          </p>
        </div>
      : React.null}
  </div>
}
