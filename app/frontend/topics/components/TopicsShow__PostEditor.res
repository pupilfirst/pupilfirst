open TopicsShow__Types

let str = React.string
%%raw(`import "./TopicsShow__PostEditor.css"`)

let tr = I18n.t(~scope="components.TopicsShow__PostEditor", ...)

type state = {
  body: string,
  saving: bool,
  editReason: option<string>,
}

module CreatePostQuery = %graphql(`
  mutation CreatePostMutation($body: String!, $topicId: ID!, $replyToPostId: ID) {
    createPost(body: $body, topicId: $topicId, replyToPostId: $replyToPostId)  {
      postId
    }
  }
`)

module UpdatePostQuery = %graphql(`
  mutation UpdatePostMutation($id: ID!, $body: String!, $editReason: String) {
    updatePost(id: $id, body: $body, editReason: $editReason)  {
      success
    }
  }
`)

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
    ~creatorId=Post.creatorId(post),
    ~editorId=Some(currentUserId),
    ~postNumber=Post.postNumber(post),
    ~createdAt=Post.createdAt(post),
    ~editedAt=Some(dateTime),
    ~totalLikes=Post.totalLikes(post),
    ~likedByUser=Post.likedByUser(post),
    ~replies=Post.replies(post),
    ~solution=Post.solution(post),
  )

  setState(_ => {body: "", saving: false, editReason: None})
  OptionUtils.mapWithDefault(cb => cb(), (), handleCloseCB)
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
  ReactEvent.Mouse.preventDefault(event)
  if body != "" {
    setState(state => {...state, saving: true})

    switch post {
    | Some(post) =>
      let postId = Post.id(post)

      let variables = UpdatePostQuery.makeVariables(~id=postId, ~body, ~editReason?, ())

      ignore(
        Js.Promise.catch(
          _ => {
            setState(state => {...state, saving: false})
            Js.Promise.resolve()
          },
          Js.Promise.then_((response: UpdatePostQuery.t) => {
            response.updatePost.success
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
          }, UpdatePostQuery.fetch(variables)),
        ),
      )
    | None =>
      ignore(
        Js.Promise.catch(
          _ => {
            setState(state => {...state, saving: false})
            Js.Promise.resolve()
          },
          Js.Promise.then_((response: CreatePostQuery.t) => {
            switch response.createPost.postId {
            | Some(postId) =>
              handlePostCreateResponse(
                postId,
                body,
                postNumber,
                currentUserId,
                setState,
                handlePostCB,
              )
            | None => setState(state => {...state, saving: false})
            }
            Js.Promise.resolve()
          }, CreatePostQuery.fetch({body, topicId: Topic.id(topic), replyToPostId})),
        ),
      )
    }
  } else {
    Notification.error(tr("empty"), tr("cant_blank"))
  }
}

let onBorderAnimationEnd = event => {
  let element = DomUtils.EventTarget.unsafeToElement(ReactEvent.Animation.target(event))
  element->Webapi.Dom.Element.setClassName("w-full flex flex-col")
}

let replyToUserInfo = user => {
  let avatarUrl = Belt.Option.flatMap(user, User.avatarUrl)
  let name = user->Belt.Option.mapWithDefault("?", user => User.name(user))
  <div className="flex items-center border bg-white px-2 py-1 rounded-lg">
    {switch avatarUrl {
    | Some(avatarUrl) =>
      <img
        className="w-6 h-6 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 object-cover"
        src=avatarUrl
      />
    | None =>
      <Avatar
        name
        className="w-6 h-6 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 object-cover"
      />
    }}
    <span className="text-xs font-semibold ms-2"> {str(name)} </span>
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
    | Some(post) => Post.body(post)
    | None => ""
    },
    saving: false,
    editReason: None,
  })
  let updateMarkdownCB = body => setState(state => {...state, body})
  let editReason = state.editReason
  let setEditReason = editReason => setState(state => {...state, editReason})
  <DisablingCover disabled=state.saving>
    <div
      ariaLabel="Add new reply"
      className="py-2 lg:px-0 max-w-4xl w-full flex mx-auto items-center justify-center relative">
      <div className="flex w-full">
        <div id className="w-full flex flex-col" onAnimationEnd=onBorderAnimationEnd>
          <label
            className="inline-block tracking-wide text-gray-900 text-sm font-semibold mb-2"
            htmlFor="new-reply">
            {str(
              switch replyToPostId {
              | Some(_id) => tr("reply_to")
              | None => tr("your_reply")
              },
            )}
          </label>
          {replyToPostId
          ->Belt.Option.flatMap(postId => Js.Array.find(reply => postId == Post.id(reply), replies))
          ->Belt.Option.mapWithDefault(React.null, reply =>
            <div
              className="topics-post-editor__reply-to-preview max-w-md rounded border border-primary-200 p-3 bg-gray-50 mb-3 overflow-hidden">
              <div className="flex justify-between">
                {replyToUserInfo(Post.user(users, reply))}
                <div
                  onClick={_ => OptionUtils.mapWithDefault(cb => cb(), (), removeReplyToPostCB)}
                  className="flex w-6 h-6 p-2 items-center justify-center cursor-pointer border border-gray-300 rounded bg-gray-50 hover:bg-gray-400">
                  <PfIcon className="if i-times-regular text-base" />
                </div>
              </div>
              <p className="text-sm pt-2">
                <MarkdownBlock
                  markdown={Post.body(reply)}
                  className="leading-normal text-sm"
                  profile=Markdown.Permissive
                />
              </p>
              <div className="topics-post-editor__reply-to-preview-bottom-fadeout" />
            </div>
          )}
          <div>
            <MarkdownEditor
              placeholder={tr("type_reply")}
              textareaId="new-reply"
              onChange=updateMarkdownCB
              value=state.body
              profile=Markdown.Permissive
              maxLength=10000
            />
            {editing
              ? <input
                  id="edit-reason"
                  className="mt-2 appearance-none block w-full bg-white text-gray-900 font-semibold border border-gray-300 rounded py-3 px-4 mb-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  onChange={event => {
                    let reason = ReactEvent.Form.target(event)["value"]
                    switch reason {
                    | "" => setEditReason(None)
                    | reason => setEditReason(Some(reason))
                    }
                  }}
                  placeholder={tr("reason_edit")}
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
                className="btn btn-subtle me-2">
                {str(tr("cancel"))}
              </button>
            | None => React.null
            }}
            {
              let newPostNumber = ArrayUtils.isNotEmpty(replies)
                ? Post.highestPostNumber(replies) + 1
                : 2
              <button
                disabled={state.saving || String.trim(state.body) == ""}
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
                {str(
                  switch post {
                  | Some(post) =>
                    Post.postNumber(post) == 1 ? tr("update_post") : tr("update_reply")
                  | None => tr("post_reply")
                  },
                )}
              </button>
            }
          </div>
        </div>
      </div>
    </div>
  </DisablingCover>
}
