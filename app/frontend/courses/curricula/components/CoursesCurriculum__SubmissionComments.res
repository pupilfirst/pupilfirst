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
   mutation HideSubmissionCommentMutation($submissionCommentId: String!, $hide: Boolean!) {
     hideSubmissionComment(submissionCommentId: $submissionCommentId, hide: $hide ) {
       comment {
         id
         userId
         comment
         submissionId
         userName
         updatedAt
         hiddenAt
         hiddenById
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

module ArchiveSubmissionCommentMutation = %graphql(`
   mutation ArchiveSubmissionCommentMutation($submissionCommentId: String!) {
     archiveSubmissionComment(submissionCommentId: $submissionCommentId ) {
       success
     }
   }
   `)

let hideComment = (submissionCommentId, hide, setSubmissionComments, event) => {
  ReactEvent.Mouse.preventDefault(event)
  HideSubmissionCommentMutation.make({submissionCommentId, hide})
  |> Js.Promise.then_(response => {
    switch response["hideSubmissionComment"]["comment"] {
    | Some(hiddenComment) =>
      let hiddenComment = hiddenComment->Comment.decode
      setSubmissionComments(existingComments =>
        Js.Array2.concat(
          [hiddenComment],
          Js.Array2.filter(
            existingComments,
            comment => comment->Comment.id != hiddenComment->Comment.id,
          ),
        )
      )
    | None => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let archiveComment = (submissionCommentId, setSubmissionComments, event) => {
  ReactEvent.Mouse.preventDefault(event)
  ArchiveSubmissionCommentMutation.make({submissionCommentId: submissionCommentId})
  |> Js.Promise.then_(response => {
    switch response["archiveSubmissionComment"]["success"] {
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

  let normalComment = comment => {
    let commentHidden = Belt.Option.isSome(comment->Comment.hiddenAt)

    <div className="bg-white border-t p-4 md:p-6" key={comment->Comment.id}>
      <div className="flex items-center">
        <div>
          <div>
            <h4 className="font-semibold text-base leading-tight block md:inline-flex self-end">
              {comment.userName |> str}
            </h4>
          </div>
          <span className="ms-1" title={Comment.updatedAtPretty(comment)}>
            {Comment.updatedAtPretty(comment)->str}
          </span>
        </div>
      </div>
      {switch author {
      | false => React.null
      | true =>
        <div>
          <button
            onClick={hideComment(comment->Comment.id, !commentHidden, setSubmissionComments)}
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
            onClick={archiveComment(comment->Comment.id, setSubmissionComments)}
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
          <p>
            {("This comment was hidden by course moderator at " ++ comment->Comment.hiddenAtPretty)
              ->str}
          </p>
        </div>
      | false => React.null
      }}
    </div>
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
          switch comment->Comment.hiddenAt {
          | Some(_) =>
            switch author || currentUser->User.id == comment->Comment.userId {
            | true => normalComment(comment)
            | false => React.null
            }
          | _ => normalComment(comment)
          }
        })
        ->React.array}
      </div>
    }}
  </div>
}
