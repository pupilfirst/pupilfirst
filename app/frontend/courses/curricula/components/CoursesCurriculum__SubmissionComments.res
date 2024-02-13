%%raw(`import "./CoursesCurriculum__SubmissionComments.css";`)
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
         user {
            id
            name
            title
            avatarUrl
         },
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
let make = (~currentUser, ~submissionId, ~comments) => {
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
      <div id={"show_comments-" ++ submissionId}>
        <button
          className="border border-gray-300 bg-white text-gray-600 px-3 py-1 font-medium text-xs leading-snug rounded-full hover:text-primary-500 hover:border-primary-500 hover:bg-gray-100 transition"
          onClick={toggleComments(setShowComments)}>
          <Icon className="if i-comment-alt-light if-fw" />
          <span className="ps-1"> {tr("comment")->str} </span>
        </button>
      </div>
    </div>
    <div hidden={!showComments} className="submissionComments mt-4 space-y-8" key={submissionId}>
      <div className="submission-comments__comment">
        <div className="flex gap-2 relative">
          <div
            className="submission-comments__line flex justify-end align-start absolute h-full -left-8 -ml-[0.5px] bottom-1 w-8 ">
            <div
              className="h-6 border-b cursor-pointer w-7 border-l border-gray-300 rounded-bl-3xl"
            />
          </div>
          <div
            className="w-8 h-8 shrink-0 border bg-gray-200 rounded-full flex items-center justify-center">
            {currentUser->CurrentUser.avatar}
          </div>
          <input
            id={"add_comment-" ++ submissionId}
            className="appearance-none block text-sm w-full bg-white leading-tight border border-gray-300 rounded px-3 py-2 focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
            type_="text"
            value=newComment
            maxLength=255
            autoFocus={true}
            placeholder={tr("write_comment")}
            onChange=handleInputChange
          />
          <button
            disabled={newComment == ""}
            className="btn btn-primary text-sm"
            onClick={handleCreateSubmissionComment}>
            {tr("comment")->str}
          </button>
        </div>
      </div>
      {submissionComments
      ->Js.Array2.map(comment =>
        <div id={"comment-" ++ comment->Comment.id} className="submission-comments__comment group">
          <CoursesCurriculum__SubmissionCommentShow key={comment->Comment.id} currentUser comment />
        </div>
      )
      ->React.array}
    </div>
  </div>
}
