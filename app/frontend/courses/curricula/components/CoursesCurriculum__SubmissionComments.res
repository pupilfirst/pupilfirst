let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionComments")

open CoursesCurriculum__Types

module CreateSubmissionCommentMutation = %graphql(`
   mutation CreateSubmissionCommentMutation($comment: String!, $submissionId: String!) {
     createSubmissionComment(comment: $comment, submissionId: $submissionId ) {
       comment {
         id
         userId
         comment
         submissionId
         userName
         updatedAt
         reactions {
            id,
            reactionableId,
            reactionValue,
            reactionableType,
            userName,
            updatedAt
          }
          moderationReports {
            id,
            userId,
            reportableId,
            reason,
            reportableType
          },
       }
     }
   }
   `)

module HideSubmissionCommentMutation = %graphql(`
   mutation HideSubmissionCommentMutation($submissionCommentId: String!) {
     hideSubmissionComment(submissionCommentId: $submissionCommentId ) {
       success
     }
   }
   `)

let hideComment = (submissionCommentId, setSubmissionComments, event) => {
  ReactEvent.Mouse.preventDefault(event)
  HideSubmissionCommentMutation.make({submissionCommentId: submissionCommentId})
  |> Js.Promise.then_(response => {
    switch response["hideSubmissionComment"]["success"] {
    | true =>
      setSubmissionComments(submissionComments =>
        submissionComments->Js.Array2.filter(comment => comment.Comment.id !== submissionCommentId)
      )
    | false => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let toggleComments = (setShowComments, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowComments(prevState => !prevState)
}

@react.component
let make = (~currentUser, ~author, ~submissionId, ~comments) => {
  let (submissionComments, setSubmissionComments) = React.useState(() => comments)
  let (showComments, setShowComments) = React.useState(() => false)
  let (newComment, setNewComment) = React.useState(() => "")

  let handleInputChange = event => {
    setNewComment(ReactEvent.Form.currentTarget(event)["value"])
  }

  let handleCreateSubmissionComment = event => {
    ReactEvent.Mouse.preventDefault(event)
    CreateSubmissionCommentMutation.make({comment: newComment, submissionId})
    |> Js.Promise.then_(response => {
      switch response["createSubmissionComment"]["comment"] {
      | Some(createdComment) =>
        setNewComment(_ => "")
        setSubmissionComments(existingComments =>
          Js.Array2.concat([createdComment], existingComments)
        )
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }

  <div>
    <div className="max-w-3xl flex items-center justify-between mx-auto">
      <div>
        <button onClick={toggleComments(setShowComments)}>
          {switch showComments {
          | true => tr("hide_comments")->str
          | false => tr("view_comments")->str
          }}
        </button>
      </div>
    </div>
    {switch showComments {
    | false => React.null
    | true =>
      <div className="submissionComments" key={submissionId}>
        <div className="ms-6">
          <input
            className="appearance-none block text-sm w-full bg-white border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
            type_="text"
            value=newComment
            maxLength=255
            placeholder={tr("write_comment")}
            onChange=handleInputChange
          />
          <button onClick={handleCreateSubmissionComment}> {tr("comment")->str} </button>
        </div>
        {submissionComments
        ->Js.Array2.map(comment => {
          <div className="bg-white border-t p-4 md:p-6" key={comment->Comment.id}>
            <div className="flex items-center">
              // #TODO Use each user's avatar
              <div
                className="shrink-0 w-12 h-12 bg-gray-300 rounded-full overflow-hidden ltr:mr me-3 object-cover">
                {currentUser->User.avatar}
              </div>
              <div>
                <div>
                  <h4
                    className="font-semibold text-base leading-tight block md:inline-flex self-end">
                    {comment.userName |> str}
                  </h4>
                </div>
              </div>
            </div>
            {switch author {
            | false => React.null
            | true =>
              <div>
                <button
                  onClick={hideComment(comment->Comment.id, setSubmissionComments)}
                  className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
                  // <i className=icon />

                  <span className="font-semibold ms-2"> {"Hide Comment"->str} </span>
                </button>
              </div>
            }}
            <CoursesCurriculum__ModerationReportButton
              currentUser
              moderationReports={comment->Comment.moderationReports}
              reportableId={comment->Comment.id}
              reportableType={"SubmissionComment"}
            />
            <MarkdownBlock
              profile=Markdown.Permissive className="ms-15" markdown={comment |> Comment.comment}
            />
            <CoursesCurriculum__Reactions
              reactionableType="SubmissionComment"
              reactionableId={comment->Comment.id}
              reactions={comment->Comment.reactions}
            />
          </div>
        })
        ->React.array}
      </div>
    }}
  </div>
}
