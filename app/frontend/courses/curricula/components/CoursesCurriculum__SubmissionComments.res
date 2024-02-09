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
      <div>
        <button
          className="border border-gray-300 bg-white text-gray-600 px-3 py-1 font-medium text-xs leading-snug rounded-full hover:text-primary-500 hover:border-primary-500 hover:bg-gray-100 transition"
          onClick={toggleComments(setShowComments)}>
          <Icon className="if i-comment-alt-light if-fw" />
          <span className="ps-1">
            {switch showComments {
            | true => tr("hide_comments")->str
            | false => tr("view_comments")->str
            }}
          </span>
        </button>
      </div>
    </div>
    <div hidden={!showComments} className="submissionComments mt-4" key={submissionId}>
      <div className="flex gap-2 relative">
        <div className="flex justify-end align-start absolute h-full -left-8 -ml-[0.5px] w-8 ">
          <div> {currentUser->CurrentUser.avatar} </div>
        </div>
        <div
          className="w-8 h-8 shrink-0 uppercase text-xs font-semibold border bg-gray-200 rounded-full flex items-center justify-center"
        />
        <input
          className="appearance-none block text-sm w-full bg-white border border-gray-300 rounded px-3 py-1.5 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          type_="text"
          value=newComment
          maxLength=255
          autoFocus=true
          placeholder={tr("write_comment")}
          onChange=handleInputChange
        />
        <button className="btn btn-primary text-sm" onClick={handleCreateSubmissionComment}>
          {tr("comment")->str}
        </button>
      </div>
      {submissionComments
      ->Js.Array2.map(comment => {
        <CoursesCurriculum__SubmissionCommentShow currentUser comment />
      })
      ->React.array}
    </div>
  </div>
}
