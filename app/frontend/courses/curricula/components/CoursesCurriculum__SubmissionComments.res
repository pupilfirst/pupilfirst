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
         createdAt
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
          Js.Array2.concat([createdComment->Comment.decode], existingComments)
        )
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }

  <div className="w-full">
    <div className="flex items-center justify-between mx-auto">
      <div>
        <button
          className="border border-primary-400 px-3 py-1.5 font-medium text-sm rounded-full"
          onClick={toggleComments(setShowComments)}>
          {switch showComments {
          | true => tr("hide_comments")->str
          | false => tr("view_comments")->str
          }}
        </button>
      </div>
    </div>
    <div hidden={!showComments} className="submissionComments" key={submissionId}>
      <div>
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
        <CoursesCurriculum__SubmissionCommentShow currentUser author comment />
      })
      ->React.array}
    </div>
  </div>
}
