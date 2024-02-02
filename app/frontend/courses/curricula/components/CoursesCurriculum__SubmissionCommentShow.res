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
    <div className="bg-white border-t p-4 md:p-6" key={comment->Comment.id}>
      <div className="flex items-center">
        <div>
          <div>
            <h4 className="font-semibold text-base leading-tight block md:inline-flex self-end">
              {comment.userName |> str}
            </h4>
          </div>
          <span className="ms-1" title={Comment.createdAtPretty(comment)}>
            {Comment.createdAtPretty(comment)->str}
          </span>
        </div>
      </div>
      {switch author {
      | false => React.null
      | true =>
        <div>
          <button
            onClick={hideComment(comment->Comment.id, !commentHidden, setCommentHidden)}
            className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
            // <i className=icon />

            <span className="font-semibold ms-2">
              {switch commentHidden {
              | true => "Un-hide Comment"->str
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
      <MarkdownBlock
        profile=Markdown.Permissive className="ms-15" markdown={comment |> Comment.comment}
      />
      <CoursesCurriculum__Reactions
        currentUser
        reactionableType="SubmissionComment"
        reactionableId={comment->Comment.id}
        reactions={comment->Comment.reactions}
      />
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
