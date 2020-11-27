open TopicsShow__Types

let str = React.string
%bs.raw(`require("./TopicsShow__PostEditor.css")`)

type state = {
  body: string,
  saving: bool,
  editReason: option<string>,
}

module CreatePostQuery = %graphql(
  `
  mutation CreatePostMutation($body: String!, $topicId: ID!, $replyToPostId: ID) {
    createPost(body: $body, topicId: $topicId, replyToPostId: $replyToPostId)  {
      postId
    }
  }
`
)

module UpdatePostQuery = %graphql(
  `
  mutation UpdatePostMutation($id: ID!, $body: String!, $editReason: String) {
    updatePost(id: $id, body: $body, editReason: $editReason)  {
      success
    }
  }
`
)

let dateTime = Js.Date.make()

let handlePostCreateResponse = (id, body, postNumber, currentUserId, setState, handlePostCB) => {
  let post = Post.make(
    ~id,
    ~body,
    ~creatorId=Some(currentUserId),
    ~editorId=None,
    ~postNumber,
    ~createdAt=dateTime,
    ~editedAt=None,
    ~totalLikes=0,
    ~likedByUser=false,
    ~replies=[],
    ~solution=false,
  )
  setState(_ => {body: "", saving: false, editReason: None})
  handlePostCB(post)
}

let handlePostUpdateResponse = (
  id,
  body,
  currentUserId,
  setState,
  handleCloseCB,
  handlePostCB,
  post,
) => {
  let updatedPost = Post.make(
    ~id,
    ~body,
    ~creatorId=post |> Post.creatorId,
    ~editorId=Some(currentUserId),
    ~postNumber=post |> Post.postNumber,
    ~createdAt=post |> Post.createdAt,
    ~editedAt=Some(dateTime),
    ~totalLikes=post |> Post.totalLikes,
    ~likedByUser=post |> Post.likedByUser,
    ~replies=post |> Post.replies,
    ~solution=post |> Post.solution,
  )

  setState(_ => {body: "", saving: false, editReason: None})
  handleCloseCB |> OptionUtils.mapWithDefault(cb => cb(), ())
  handlePostCB(updatedPost)
}
let savePost = (
  ~editReason,
  ~body,
  ~topic,
  ~setState,
  ~currentUserId,
  ~replyToPostId,
  ~handlePostCB,
  ~post,
  ~postNumber,
  ~handleCloseCB,
  event,
) => {
  event |> ReactEvent.Mouse.preventDefault
  if body != "" {
    setState(state => {...state, saving: true})

    switch post {
    | Some(post) =>
      let postId = post |> Post.id

      UpdatePostQuery.make(~id=postId, ~body, ~editReason?, ())
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response => {
        response["updatePost"]["success"]
          ? handlePostUpdateResponse(
              postId,
              body,
              currentUserId,
              setState,
              handleCloseCB,
              handlePostCB,
              post,
            )
          : setState(state => {...state, saving: false})
        Js.Promise.resolve()
      })
      |> Js.Promise.catch(_ => {
        setState(state => {...state, saving: false})
        Js.Promise.resolve()
      })
      |> ignore
    | None =>
      CreatePostQuery.make(~body, ~topicId=topic |> Topic.id, ~replyToPostId?, ())
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response => {
        switch response["createPost"]["postId"] {
        | Some(postId) =>
          handlePostCreateResponse(postId, body, postNumber, currentUserId, setState, handlePostCB)
        | None => setState(state => {...state, saving: false})
        }
        Js.Promise.resolve()
      })
      |> Js.Promise.catch(_ => {
        setState(state => {...state, saving: false})
        Js.Promise.resolve()
      })
      |> ignore
    }
  } else {
    Notification.error("Empty", "Reply cant be blank")
  }
}

let onBorderAnimationEnd = event => {
  let element = ReactEvent.Animation.target(event) |> DomUtils.EventTarget.unsafeToElement
  element->Webapi.Dom.Element.setClassName("w-full flex flex-col")
}

let replyToUserInfo = user => {
  let avatarUrl = Belt.Option.flatMap(user, User.avatarUrl)
  let name = user->Belt.Option.mapWithDefault("?", user => User.name(user))
  <div className="flex items-center border bg-white px-2 py-1 rounded-lg">
    {switch avatarUrl {
    | Some(avatarUrl) =>
      <img
        className="w-6 h-6 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover"
        src=avatarUrl
      />
    | None =>
      <Avatar
        name
        className="w-6 h-6 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover"
      />
    }}
    <span className="text-xs font-semibold ml-2"> {name |> str} </span>
  </div>
}

@react.component
let make = (
  ~editing=false,
  ~id,
  ~topic,
  ~currentUserId,
  ~handlePostCB,
  ~replies,
  ~users,
  ~replyToPostId=?,
  ~post=?,
  ~handleCloseCB=?,
  ~removeReplyToPostCB=?,
) => {
  let (state, setState) = React.useState(() => {
    body: switch post {
    | Some(post) => post |> Post.body
    | None => ""
    },
    saving: false,
    editReason: None,
  })
  let updateMarkdownCB = body => setState(state => {...state, body: body})
  let editReason = state.editReason
  let setEditReason = editReason => setState(state => {...state, editReason: editReason})
  <DisablingCover disabled=state.saving>
    <div
      ariaLabel="Add new reply"
      className="py-2 lg:px-0 max-w-4xl w-full flex mx-auto items-center justify-center relative">
      <div className="flex w-full">
        <div id className="w-full flex flex-col" onAnimationEnd=onBorderAnimationEnd>
          <label
            className="inline-block tracking-wide text-gray-900 text-sm font-semibold mb-2"
            htmlFor="new-reply">
            {switch replyToPostId {
            | Some(_id) => "Reply To"
            | None => "Your Reply"
            } |> str}
          </label>
          {replyToPostId
          ->Belt.Option.flatMap(postId =>
            replies |> Js.Array.find(reply => postId == Post.id(reply))
          )
          ->Belt.Option.mapWithDefault(React.null, reply =>
            <div
              className="topics-post-editor__reply-to-preview max-w-md rounded border border-primary-200 p-3 bg-gray-200 mb-3 overflow-hidden">
              <div className="flex justify-between">
                {replyToUserInfo(reply |> Post.user(users))}
                <div
                  onClick={_ => removeReplyToPostCB |> OptionUtils.mapWithDefault(cb => cb(), ())}
                  className="flex w-6 h-6 p-2 items-center justify-center cursor-pointer border border-gray-400 rounded bg-gray-200 hover:bg-gray-400">
                  <PfIcon className="if i-times-regular text-base" />
                </div>
              </div>
              <p className="text-sm pt-2">
                <MarkdownBlock
                  markdown={reply |> Post.body}
                  className="leading-normal text-sm"
                  profile=Markdown.QuestionAndAnswer
                />
              </p>
              <div className="topics-post-editor__reply-to-preview-bottom-fadeout" />
            </div>
          )}
          <div>
            <MarkdownEditor
              placeholder="Type in your reply. You can use Markdown to format your response."
              textareaId="new-reply"
              onChange=updateMarkdownCB
              value=state.body
              profile=Markdown.QuestionAndAnswer
              maxLength=10000
            />
            {editing
              ? <input
                  id="edit-reason"
                  className="mt-2 appearance-none block w-full bg-white text-gray-900 font-semibold border border-gray-400 rounded py-3 px-4 mb-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  onChange={event => {
                    let reason = ReactEvent.Form.target(event)["value"]
                    switch reason {
                    | "" => setEditReason(None)
                    | reason => setEditReason(Some(reason))
                    }
                  }}
                  placeholder="Reason for this edit (optional)"
                  value={switch editReason {
                  | None => ""
                  | Some(editReason) => editReason
                  }}
                  maxLength=500
                />
              : React.null}
          </div>
          <div className="flex justify-end pt-3">
            {switch handleCloseCB {
            | Some(handleCloseCB) =>
              <button
                disabled=state.saving
                onClick={_ => handleCloseCB()}
                className="btn btn-subtle mr-2">
                {"Cancel" |> str}
              </button>
            | None => React.null
            }}
            {
              let newPostNumber =
                replies |> ArrayUtils.isNotEmpty ? (replies |> Post.highestPostNumber) + 1 : 2
              <button
                disabled={state.saving || state.body |> String.trim == ""}
                onClick={savePost(
                  ~editReason,
                  ~body=state.body,
                  ~topic,
                  ~setState,
                  ~currentUserId,
                  ~replyToPostId,
                  ~handlePostCB,
                  ~post,
                  ~postNumber=newPostNumber,
                  ~handleCloseCB,
                )}
                className="btn btn-primary">
                {switch post {
                | Some(post) => Post.postNumber(post) == 1 ? "Update Post" : "Update Reply"
                | None => "Post Your Reply"
                } |> str}
              </button>
            }
          </div>
        </div>
      </div>
    </div>
  </DisablingCover>
}
