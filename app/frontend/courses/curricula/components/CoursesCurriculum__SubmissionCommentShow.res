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
    switch response["hideSubmissionComment"]["success"] {
    | true => setCommentHidden(_ => hide)
    | false => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let archiveComment = (submissionCommentId, setCommentArchived, setShowConfirmDelete, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowConfirmDelete(_ => false)
  ArchiveSubmissionCommentMutation.make({submissionCommentId: submissionCommentId})
  |> Js.Promise.then_(response => {
    switch response["archiveSubmissionComment"]["success"] {
    | true => setCommentArchived(_ => true)
    | false => ()
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
let make = (~currentUser, ~comment) => {
  let (commentHidden, setCommentHidden) = React.useState(() =>
    Belt.Option.isSome(comment->Comment.hiddenAt)
  )
  let (commentArchived, setCommentArchived) = React.useState(() => false)
  let (showConfirmDelete, setShowConfirmDelete) = React.useState(() => false)

  let isModerator = currentUser->CurrentUser.isModerator

  let commentDisplay =
    <div className="relative mt-4">
      <div
        className="flex justify-end align-start absolute h-full -left-8 -ml-[0.5px] w-8 last:bg-white ">
        <div className="h-6 border-b cursor-pointer w-7 border-l border-gray-300 rounded-bl-3xl" />
      </div>
      {switch commentHidden {
      | true =>
        <div className="absolute -translate-x-1/2 left-1/2 z-20 flex justify-end mx-auto bottom-0">
          <p
            className="px-2 py-1 bg-white/75 border border-b-0 rounded-t-lg text-xs leading-tight italic text-gray-700">
            {"This comment is hidden from discussions."->str}
          </p>
        </div>
      | false => React.null
      }}
      <div
        className={if commentHidden {
          "relative curriculum__submission-comment-hidden"
        } else {
          "flex-1"
        }}
        key={comment->Comment.id}>
        <div className="flex items-center justify-between">
          <div>
            <div className="flex gap-3">
              // <div
              //   className="flex justify-end align-start absolute h-full -left-8 -ml-[0.5px] w-8 bg-white ">
              //   <div
              //     className="h-6 border-b cursor-pointer w-7 border-l border-gray-300 rounded-bl-3xl"
              //   />
              // </div>
              <div
                className="w-8 h-8 uppercase text-xs font-semibold border bg-gray-200 rounded-full flex items-center justify-center">
                {String.sub(comment.userName, 0, 2) |> str}
              </div>
              <div className="flex flex-col flex-wrap">
                <p className="font-semibold text-xs leading-tight block md:inline-flex">
                  {comment.userName |> str}
                </p>
                <p
                  className="text-xs text-gray-600 leading-tight pt-1"
                  title={Comment.createdAtPretty(comment)}>
                  {Comment.createdAtPretty(comment)->str}
                </p>
              </div>
            </div>
          </div>
          <div className="flex space-x-2">
            {switch isModerator {
            | false => React.null
            | true =>
              <div>
                <button
                  onClick={hideComment(comment->Comment.id, !commentHidden, setCommentHidden)}
                  className="flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 focus:outline-none focus:text-gray-800 focus:bg-gray-50 whitespace-nowrap"
                  title={commentHidden ? "Unhide Comment" : "Hide Comment"}>
                  {switch commentHidden {
                  | true =>
                    <span className="flex items-center md:space-x-1">
                      <Icon className="if i-eye-closed-light if-fw" />
                      <span className="hidden md:inline-block text-xs"> {"Unhide"->str} </span>
                    </span>
                  | false =>
                    <span className="flex items-center md:space-x-1">
                      <Icon className="if i-eye-light if-fw" />
                      <span className="hidden md:inline-block text-xs"> {"Hide"->str} </span>
                    </span>
                  }}
                </button>
              </div>
            }}
            {switch currentUser->CurrentUser.id == comment->Comment.userId {
            | false =>
              <CoursesCurriculum__ModerationReportButton
                currentUser
                moderationReports={comment->Comment.moderationReports}
                reportableId={comment->Comment.id}
                reportableType={"SubmissionComment"}
              />
            | true =>
              <div>
                <button
                  onClick={updateShowConfirmDelete(setShowConfirmDelete, true)}
                  className="flex md:space-x-1 items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 focus:outline-none focus:text-gray-800 focus:bg-gray-50 whitespace-nowrap">
                  <Icon className="if i-trash-light if-fw" />
                  <span className="hidden md:inline-block text-xs"> {"Delete"->str} </span>
                </button>
              </div>
            }}
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
    </div>

  <div>
    {switch showConfirmDelete {
    | false => React.null
    | true =>
      <div className="blanket">
        <h2> {"Delete comment"->str} </h2>
        <p> {"Are you sure you want to delete comment?"->str} </p>
        <button
          onClick={archiveComment(comment->Comment.id, setCommentArchived, setShowConfirmDelete)}>
          {"Delete"->str}
        </button>
      </div>
    }}
    {switch (commentArchived, commentHidden) {
    | (true, _) => React.null
    | (false, false) => commentDisplay
    | (false, true) =>
      switch isModerator || currentUser->CurrentUser.id == comment->Comment.userId {
      | true => commentDisplay
      | false => React.null
      }
    }}
  </div>
}
