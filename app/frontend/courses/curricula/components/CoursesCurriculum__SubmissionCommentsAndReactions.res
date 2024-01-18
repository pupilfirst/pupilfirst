let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionCommentsAndReactions")

open CoursesCurriculum__Types

module CreateSubmissionCommentMutation = %graphql(`
   mutation CreateSubmissionCommentMutation($comment: String!, $submissionId: String!) {
     createSubmissionComment(comment: $comment, submissionId: $submissionId ) {
       comment {
         id
         comment
         submissionId
         userName
       }
     }
   }
   `)

let toggleComments = (setShowComments, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowComments(prevState => !prevState)
}

@react.component
let make = (~submission, ~comments, ~reactions) => {
  let (submissionComments, setSubmissionComments) = React.useState(() => comments)
  let (showComments, setShowComments) = React.useState(() => false)
  let (newComment, setNewComment) = React.useState(() => "")

  let handleInputChange = event => {
    setNewComment(ReactEvent.Form.currentTarget(event)["value"])
  }

  let handleCreateSubmissionComment = (comment, submissionId, event) => {
    ReactEvent.Mouse.preventDefault(event)
    CreateSubmissionCommentMutation.make({comment, submissionId})
    |> Js.Promise.then_(response => {
      switch response["createSubmissionComment"]["comment"] {
      | Some(comment) => setSubmissionComments(comments => Js.Array2.concat([comment], comments))
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }

  <div>
    <div className="max-w-3xl flex items-center justify-between mx-auto">
      <div className="flex">
        <div>
          <button onClick={toggleComments(setShowComments)}> {"Comment"->str} </button>
        </div>
        <CoursesCurriculum__Reactions submission reactions />
      </div>
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
      <div className="submissionComments" key={submission->Submission.id}>
        <div className="ms-6">
          <input
            className="appearance-none block text-sm w-full bg-white border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
            type_="text"
            value=newComment
            maxLength=255
            placeholder={tr("write_comment")}
            onChange=handleInputChange
          />
          <button onClick={handleCreateSubmissionComment(newComment, submission->Submission.id)}>
            {tr("comment")->str}
          </button>
        </div>
        {submissionComments
        ->Js.Array2.map(comment => {
          <div className="bg-white border-t p-4 md:p-6" key={comment->Comment.id}>
            <div className="flex items-center">
              // <div
              //   className="shrink-0 w-12 h-12 bg-gray-300 rounded-full overflow-hidden ltr:mr me-3 object-cover">
              //   coachAvatar
              // </div>
              <div>
                <div>
                  <h4
                    className="font-semibold text-base leading-tight block md:inline-flex self-end">
                    {comment.userName |> str}
                  </h4>
                </div>
              </div>
            </div>
            <MarkdownBlock
              profile=Markdown.Permissive className="ms-15" markdown={comment |> Comment.comment}
            />
          </div>
        })
        ->React.array}
      </div>
    }}
  </div>
}
