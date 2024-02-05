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

let archiveComment = (submissionCommentId, setCommentArchived, event) => {
  ReactEvent.Mouse.preventDefault(event)
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

@react.component
let make = (~currentUser, ~author, ~comment) => {
  let (commentHidden, setCommentHidden) = React.useState(() =>
    Belt.Option.isSome(comment->Comment.hiddenAt)
  )
  let (commentArchived, setCommentArchived) = React.useState(() => false)

  let commentDisplay =
    <div className="mt-6" key={comment->Comment.id}>
      <div className="flex items-center justify-between">
        <div>
          <div className="flex gap-3">
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
        <div className="flex">
          {switch author {
          | false => React.null
          | true =>
            <div>
              <button
                onClick={hideComment(comment->Comment.id, !commentHidden, setCommentHidden)}
                className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap"
                title={commentHidden ? "Unhide Comment" : "Hide Comment"}>
                <span className="font-semibold ms-2">
                  {switch commentHidden {
                  | true =>
                    <span>
                      <Icon className="if i-eye-light if-fw" />
                    </span>
                  | false => "Hide Comment"->str
                  }}
                </span>
              </button>
            </div>
          }}
          {switch currentUser->User.id == comment->Comment.userId {
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
                onClick={archiveComment(comment->Comment.id, setCommentArchived)}
                className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
                // <i className=icon />

                <span className="font-semibold ms-2"> {"Delete Comment"->str} </span>
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
      {switch commentHidden {
      | true =>
        <div>
          <p> {"This comment is hidden from discussions"->str} </p>
        </div>
      | false => React.null
      }}
    </div>

  {
    switch (commentArchived, commentHidden) {
    | (true, _) => React.null
    | (false, false) => commentDisplay
    | (false, true) =>
      switch author || currentUser->User.id == comment->Comment.userId {
      | true => commentDisplay
      | false => React.null
      }
    }
  }
}
