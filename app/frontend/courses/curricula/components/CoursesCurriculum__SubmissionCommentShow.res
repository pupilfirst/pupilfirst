%%raw(`import "./CoursesCurriculum__SubmissionCommentShow.css";`)
let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionCommentShow")

open CoursesCurriculum__Types

module HideSubmissionCommentMutation = %graphql(`
   mutation HideSubmissionCommentMutation($submissionCommentId: String!, $hide: Boolean!) {
     hideSubmissionComment(submissionCommentId: $submissionCommentId, hide: $hide ) {
      success
     }
   }
   `)

module ArchiveSubmissionCommentMutation = %graphql(`
   mutation ArchiveSubmissionCommentMutation($submissionCommentId: String!) {
     archiveSubmissionComment(submissionCommentId: $submissionCommentId ) {
       success
     }
   }
   `)

let hideComment = (submissionCommentId, hide, setCommentHidden, event) => {
  ReactEvent.Mouse.preventDefault(event)
  HideSubmissionCommentMutation.make({submissionCommentId, hide})
  |> Js.Promise.then_(response => {
    if response["hideSubmissionComment"]["success"] {
      setCommentHidden(_ => hide)
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let archiveComment = (submissionCommentId, setShowConfirmDelete, archiveCommentCB, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowConfirmDelete(_ => false)
  ArchiveSubmissionCommentMutation.make({submissionCommentId: submissionCommentId})
  |> Js.Promise.then_(response => {
    if response["archiveSubmissionComment"]["success"] {
      archiveCommentCB(submissionCommentId)
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let updateShowConfirmDelete = (setShowConfirmDelete, showConfirmDelete, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowConfirmDelete(_ => showConfirmDelete)
}

@react.component
let make = (~currentUser, ~comment, ~archiveCommentCB) => {
  let (commentHidden, setCommentHidden) = React.useState(() =>
    Belt.Option.isSome(comment->Comment.hiddenAt)
  )
  let (showConfirmDelete, setShowConfirmDelete) = React.useState(() => false)

  let isModerator = currentUser->CurrentUser.isModerator
  let userName = comment->Comment.user->User.name

  let commentDisplay =
    <div
      className="relative mt-4 group curriculum-submission__comment focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-500"
      tabIndex=0
      ariaLabel={"comment-" ++ comment->Comment.id}>
      <div
        className={if commentHidden {
          "relative curriculum__submission-comment-hidden rounded-b-xl"
        } else {
          "flex-1"
        }}>
        <div className="flex flex-row items-center justify-between">
          <div>
            <div className="flex gap-3">
              <div
                className="submission-comments__line flex justify-end align-start absolute h-full -left-8 -ml-[0.5px] bottom-1 w-8">
                <div
                  className="h-6 border-b cursor-pointer w-7 border-l border-gray-300 rounded-bl-3xl"
                />
              </div>
              <div
                className="w-8 h-8 border bg-gray-200 rounded-full flex items-center justify-center">
                {comment->Comment.user->User.avatar}
              </div>
              <div className="flex flex-col flex-wrap">
                <p className="font-semibold text-xs leading-tight block md:inline-flex">
                  {userName |> str}
                </p>
                <p
                  className="text-xs text-gray-600 leading-tight pt-1"
                  title={Comment.createdAtPretty(comment)}>
                  {Comment.createdAtPretty(comment)->str}
                </p>
              </div>
            </div>
          </div>
          <div className="flex space-x-2 relative">
            {isModerator
              ? <div className="relative z-[11]">
                  <button
                    onClick={hideComment(comment->Comment.id, !commentHidden, setCommentHidden)}
                    className="md:hidden md:group-hover:flex md:group-focus-within:flex md:space-x-1 items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 whitespace-nowrap focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-600 transition"
                    title={commentHidden ? "Unhide Comment" : "Hide Comment"}>
                    {commentHidden
                      ? <span className="flex items-center md:space-x-1">
                          <Icon className="if i-eye-closed-light if-fw" />
                          <span className="hidden md:inline-block text-xs">
                            {tr("unhide")->str}
                          </span>
                        </span>
                      : <span className="flex items-center md:space-x-1">
                          <Icon className="if i-eye-light if-fw" />
                          <span className="hidden md:inline-block text-xs">
                            {tr("hide")->str}
                          </span>
                        </span>}
                  </button>
                </div>
              : React.null}
            {currentUser->CurrentUser.id == comment->Comment.userId
              ? <div className="md:hidden md:group-hover:flex relative z-[11]">
                  <button
                    onClick={updateShowConfirmDelete(setShowConfirmDelete, true)}
                    className="md:hidden md:group-hover:flex md:group-focus-within:flex md:space-x-1 items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 whitespace-nowrap focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-600 transition">
                    <Icon className="if i-trash-light if-fw" />
                    <span className="hidden md:inline-block text-xs"> {tr("delete")->str} </span>
                  </button>
                </div>
              : <div className="relative z-[13]">
                  <CoursesCurriculum__ModerationReportButton
                    currentUser
                    moderationReports={comment->Comment.moderationReports}
                    reportableId={comment->Comment.id}
                    reportableType={"SubmissionComment"}
                  />
                </div>}
          </div>
        </div>
        <MarkdownBlock
          profile=Markdown.Permissive
          className="text-sm ms-11 mt-2"
          markdown={comment |> Comment.comment}
        />
        <div className="ms-11">
          <CoursesCurriculum__Reactions
            currentUser
            reactionableType="SubmissionComment"
            reactionableId={comment->Comment.id}
            reactions={comment->Comment.reactions}
          />
        </div>
      </div>
      {commentHidden
        ? <div
            className="absolute -translate-x-1/2 left-1/2 z-[10] flex justify-end mx-auto bottom-px">
            <p
              className="px-2 py-1 bg-white/20 border border-gray-300 border-b-0 whitespace-nowrap rounded-t-lg text-xs leading-tight italic text-gray-500">
              {tr("hidden")->str}
            </p>
          </div>
        : React.null}
    </div>

  <div id={"comment-" ++ comment->Comment.id}>
    {showConfirmDelete
      ? <dialog
          role="dialog"
          className="fixed inset-0 z-[999] grid place-items-center w-full h-full bg-gray-950/75 dark:bg-gray-50/75 backdrop-blur-sm ease-in duration-300">
          <div className="max-w-xl mx-auto relative p-4 bg-white rounded-lg shadow-lg">
            <div className="sm:flex sm:items-start">
              <div
                className="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg
                  className="h-6 w-6 text-red-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth="1.5"
                  stroke="currentColor"
                  ariaHidden=true>
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
                  />
                </svg>
              </div>
              <div className="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                <h3 className="text-base font-semibold leading-6 text-gray-900" id="modal-title">
                  {tr("delete_comment")->str}
                </h3>
                <div className="mt-2">
                  <p className="text-sm text-gray-500"> {tr("delete_confirm")->str} </p>
                </div>
                <div className="absolute right-0 top-0 hidden pr-4 pt-4 sm:block">
                  <button
                    autoFocus={true}
                    onClick={updateShowConfirmDelete(setShowConfirmDelete, false)}
                    className="w-6 h-6 flex items-center justify-center rounded-md text-gray-700 bg-gray-100 hover:bg-gray-200 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 transition">
                    <Icon className="if i-times-light text-xl if-fw" />
                    <span className="sr-only"> {tr("close")->str} </span>
                  </button>
                </div>
              </div>
            </div>
            <div className="mt-5 sm:ml-10 sm:mt-4 sm:flex sm:pl-4">
              <button
                className="inline-flex w-full justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 sm:w-auto"
                onClick={archiveComment(
                  comment->Comment.id,
                  setShowConfirmDelete,
                  archiveCommentCB,
                )}>
                {tr("delete")->str}
              </button>
              <button
                onClick={updateShowConfirmDelete(setShowConfirmDelete, false)}
                className="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:ml-3 sm:mt-0 sm:w-auto">
                {tr("cancel")->str}
              </button>
            </div>
          </div>
        </dialog>
      : React.null}
    {commentDisplay}
  </div>
}
