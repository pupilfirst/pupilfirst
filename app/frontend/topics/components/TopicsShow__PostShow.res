open TopicsShow__Types

let str = React.string
%%raw(`import "./TopicsShow__PostShow.css"`)

let t = I18n.t(~scope="components.TopicsShow__PostShow", ...)

let findUser = (userId, users) => userId->Belt.Option.map(userId => User.findById(userId, users))

module MarkPostAsSolutionQuery = %graphql(`
  mutation MarkAsSolutionMutation($id: ID!) {
    markPostAsSolution(id: $id)  {
      success
    }
  }
`)

module UnmarkPostAsSolutionQuery = %graphql(`
  mutation UnmarkAsSolutionMutation($id: ID!) {
    unmarkPostAsSolution(id: $id)  {
      success
    }
  }
`)

module ArchivePostQuery = %graphql(`
  mutation ArchivePostMutation($id: ID!) {
    archivePost(id: $id)  {
      success
    }
  }
`)

let markPostAsSolution = (postId, markPostAsSolutionCB) =>
  WindowUtils.confirm(t("mark_solution_confirm"), () =>
    ignore(Js.Promise.then_((response: MarkPostAsSolutionQuery.t) => {
        response.markPostAsSolution.success ? markPostAsSolutionCB() : ()
        Js.Promise.resolve()
      }, MarkPostAsSolutionQuery.fetch({id: postId})))
  )

let unmarkPostAsSolution = (postId, unmarkPostAsSolutionCB) =>
  WindowUtils.confirm(t("unmark_solution_confirm"), () =>
    ignore(Js.Promise.then_((response: UnmarkPostAsSolutionQuery.t) => {
        response.unmarkPostAsSolution.success ? unmarkPostAsSolutionCB() : ()
        Js.Promise.resolve()
      }, UnmarkPostAsSolutionQuery.fetch({id: postId})))
  )

let archivePost = (isFirstPost, postId, archivePostCB) =>
  Webapi.Dom.window->Webapi.Dom.Window.confirm(
    isFirstPost ? t("delete_topic_confirm_dialog") : t("delete_post_confirm_dialog"),
  )
    ? ignore(Js.Promise.then_((response: ArchivePostQuery.t) => {
          response.archivePost.success ? archivePostCB() : ()
          Js.Promise.resolve()
        }, ArchivePostQuery.fetch({id: postId})))
    : ()

let solutionIcon = (userCanUnmarkSolution, unmarkPostAsSolutionCB, postId) => {
  let tip = <div className="text-center"> {str(t("unmark_solution"))} </div>
  let solutionIcon =
    <div
      className={"flex items-center justify-center w-8 h-8 bg-green-200 text-green-800 rounded-full " ++ (
        userCanUnmarkSolution ? "hover:bg-gray-50 hover:text-gray-600" : ""
      )}>
      <PfIcon className="if i-check-solid text-sm lg:text-base" />
    </div>
  let iconWithTip = userCanUnmarkSolution
    ? <Tooltip tip position=#Top> solutionIcon </Tooltip>
    : solutionIcon
  <div
    ariaLabel={t("marked_solution_icon")}
    onClick={_ => userCanUnmarkSolution ? unmarkPostAsSolution(postId, unmarkPostAsSolutionCB) : ()}
    className={"flex lg:flex-col items-center w-8 h-8 bg-green-200 lg:bg-transparent rounded md:mt-4 " ++ (
      userCanUnmarkSolution ? "cursor-pointer" : ""
    )}>
    {iconWithTip}
    <div className={"text-xs lg:text-tiny font-semibold text-green-800 lg:pt-1 "}>
      {str(t("solution_icon_label"))}
    </div>
  </div>
}

let optionsDropdown = (
  post,
  isPostCreator,
  isTopicCreator,
  moderator,
  isFirstPost,
  replies,
  toggleShowPostEdit,
  archivePostCB,
) => {
  let selected =
    <div
      ariaLabel={t("options_post") ++ " " ++ Post.id(post)}
      className="flex items-center justify-center w-8 h-8 rounded leading-tight border bg-gray-50 text-gray-800 cursor-pointer hover:bg-gray-50">
      <PfIcon className="if i-ellipsis-regular text-base" />
    </div>
  let editPostButton =
    <button
      onClick={_ => toggleShowPostEdit(_ => true)}
      className="flex w-full px-3 py-2 font-semibold items-center text-gray-600 whitespace-nowrap">
      <FaIcon classes="fas fa-edit fa-fw text-base" />
      <span className="ms-2">
        {str(isFirstPost ? t("edit_post_string") : t("edit_reply_string"))}
      </span>
    </button>
  let showDelete = isFirstPost
    ? moderator || (isPostCreator && ArrayUtils.isEmpty(replies))
    : moderator || isPostCreator
  let deletePostButton = showDelete
    ? <button
        onClick={_ => archivePost(isFirstPost, Post.id(post), archivePostCB)}
        className="flex w-full px-3 py-2 font-semibold items-center text-gray-600 whitespace-nowrap">
        <FaIcon classes="fas fa-trash-alt fa-fw text-base" />
        <span className="ms-2">
          {str(isFirstPost ? t("delete_topic_string") : t("delete_reply_string"))}
        </span>
      </button>
    : React.null
  let historyButton = switch Post.editorId(post) {
  | Some(_id) =>
    <a
      href={"/posts/" ++ (Post.id(post) ++ "/versions")}
      className="flex w-full px-3 py-2 font-semibold items-center text-gray-600 whitespace-nowrap">
      <FaIcon classes="fas fa-history fa-fw text-base" />
      <span className="ms-2"> {str(t("history_button_text"))} </span>
    </a>
  | None => React.null
  }

  let contents = switch (moderator, isTopicCreator, isPostCreator) {
  | (true, _, _) => [editPostButton, historyButton, deletePostButton]
  | (false, true, true) => [editPostButton, deletePostButton]
  | (false, false, true) => [editPostButton, deletePostButton]
  | _ => []
  }
  <Dropdown selected contents right=true />
}

let onBorderAnimationEnd = event => {
  let element = DomUtils.EventTarget.unsafeToElement(ReactEvent.Animation.target(event))
  element->Webapi.Dom.Element.setClassName("")
}

let navigateToEditor = () => {
  let elementId = "add-reply-to-topic"
  let element = Webapi.Dom.document->Webapi.Dom.Document.getElementById(elementId)
  ignore(Js.Global.setTimeout(() =>
      switch element {
      | Some(e) =>
        ignore({
          Webapi.Dom.Element.scrollIntoView(e)
          e->Webapi.Dom.Element.setClassName("w-full flex flex-col topics-show__highlighted-item")
        })
      | None => Rollbar.error("Could not find the post to scroll to.")
      }
    , 50))
}

@react.component
let make = (
  ~post,
  ~topic,
  ~users,
  ~posts,
  ~currentUserId,
  ~moderator,
  ~isTopicCreator,
  ~updatePostCB,
  ~addNewReplyCB,
  ~addPostLikeCB,
  ~removePostLikeCB,
  ~markPostAsSolutionCB,
  ~unmarkPostAsSolutionCB,
  ~archivePostCB,
  ~topicSolutionId,
  (),
) => {
  let creator = Post.creatorId(post)->findUser(users)
  let editor = Post.editorId(post)->findUser(users)
  let isPostCreator =
    Post.creatorId(post)->Belt.Option.mapWithDefault(false, creatorId => currentUserId == creatorId)
  let isFirstPost = Post.postNumber(post) == 1
  let repliesToPost = isFirstPost ? [] : Post.repliesToPost(posts, post)
  let (showPostEdit, toggleShowPostEdit) = React.useState(() => false)
  let (showReplies, toggleShowReplies) = React.useState(() => false)
  let userCanUnmarkSolution = moderator || isTopicCreator

  <div id={"post-show-" ++ Post.id(post)} onAnimationEnd=onBorderAnimationEnd>
    <div className="flex pt-4" key={Post.id(post)}>
      <div className="hidden lg:flex flex-col">
        <TopicsShow__LikeManager post addPostLikeCB removePostLikeCB />
        {Post.solution(post)
          ? solutionIcon(userCanUnmarkSolution, unmarkPostAsSolutionCB, Post.id(post))
          : React.null}
        {ReactUtils.nullUnless(
          {
            let tip = <div className="text-center"> {str(t("mark_solution"))} </div>
            <div
              className="hidden md:flex md:flex-col items-center text-center md:w-14 pe-3 md:pe-4 md:mt-4">
              <Tooltip tip position=#Top>
                <button
                  ariaLabel={t("mark_solution")}
                  onClick={_ => markPostAsSolution(Post.id(post), markPostAsSolutionCB)}
                  className="mark-as-solution__button bg-gray-50 flex items-center justify-center text-center rounded-full w-8 h-8 hover:bg-gray-50 text-gray-600">
                  <PfIcon className="if i-check-solid text-sm lg:text-base" />
                </button>
              </Tooltip>
            </div>
          },
          {
            (moderator || isTopicCreator) &&
            !(isFirstPost || Post.solution(post)) &&
            Belt.Option.isNone(topicSolutionId)
          },
        )}
      </div>
      <div className="flex-1 pb-6 lg:pb-8 topics-post-show__post-body min-w-0">
        <div className="pt-2" id="body">
          <div className="flex justify-between lg:hidden">
            <TopicsShow__UserShow user=creator createdAt={Post.createdAt(post)} />
            <div className="shrink-0 mt-1">
              {isPostCreator || (moderator || isTopicCreator)
                ? optionsDropdown(
                    post,
                    isPostCreator,
                    isTopicCreator,
                    moderator,
                    isFirstPost,
                    posts,
                    toggleShowPostEdit,
                    archivePostCB,
                  )
                : React.null}
            </div>
          </div>
          {showPostEdit
            ? <div className="flex-1">
                <TopicsShow__PostEditor
                  editing=true
                  id={"edit-post-" ++ Post.id(post)}
                  topic
                  currentUserId
                  post
                  replies=posts
                  users
                  handlePostCB=updatePostCB
                  handleCloseCB={() => toggleShowPostEdit(_ => false)}
                />
              </div>
            : <div className="flex items-start justify-between min-w-0">
                <div className="text-sm min-w-0 w-full">
                  <MarkdownBlock
                    markdown={Post.body(post)}
                    className="leading-normal text-sm "
                    profile=Markdown.Permissive
                  />
                  {switch Post.editedAt(post) {
                  | Some(editedAt) =>
                    <div>
                      <div
                        className="mt-1 inline-block px-2 py-1 rounded bg-gray-50 text-xs text-gray-800 ">
                        <span> {str(t("last_edited_by_label"))} </span>
                        <span className="font-semibold">
                          {str(
                            switch editor {
                            | Some(user) => User.name(user)
                            | None => t("deleted_user_name")
                            },
                          )}
                        </span>
                        <span>
                          {str(" on " ++ editedAt->DateFns.format("do MMMM, yyyy HH:mm"))}
                        </span>
                      </div>
                    </div>
                  | None => React.null
                  }}
                </div>
                <div className="hidden lg:block shrink-0 ms-3">
                  {isPostCreator || (moderator || isTopicCreator)
                    ? optionsDropdown(
                        post,
                        isPostCreator,
                        isTopicCreator,
                        moderator,
                        isFirstPost,
                        posts,
                        toggleShowPostEdit,
                        archivePostCB,
                      )
                    : React.null}
                </div>
              </div>}
        </div>
        <div className="flex justify-between lg:items-end pt-4">
          <div className="flex-1 lg:flex-initial me-3">
            <div className="hidden lg:block">
              <TopicsShow__UserShow user=creator createdAt={Post.createdAt(post)} />
            </div>
            // Showing Like, replies and solution for mobile
            <div className="flex items-center lg:items-start justify-between lg:hidden">
              <div className="flex">
                <div className="flex">
                  <TopicsShow__LikeManager post addPostLikeCB removePostLikeCB />
                  <div className="pe-3">
                    {ArrayUtils.isNotEmpty(repliesToPost)
                      ? <button
                          onClick={_ => toggleShowReplies(showReplies => !showReplies)}
                          className="cursor-pointer flex items-center justify-center">
                          <span
                            className="flex items-center justify-center rounded-lg lg:bg-gray-50 hover:bg-gray-300 text-gray-600 hover:text-gray-900 h-8 w-8 md:h-10 md:w-10 p-1 md:p-2 mx-auto">
                            <FaIcon classes="far fa-comment-alt" />
                          </span>
                          <span className="text-tiny lg:text-xs font-semibold">
                            {str(string_of_int(Array.length(Post.replies(post))))}
                          </span>
                        </button>
                      : React.null}
                  </div>
                </div>
              </div>
              <div className="flex space-x-3">
                {ReactUtils.nullUnless(
                  <button
                    onClick={_ => markPostAsSolution(Post.id(post), markPostAsSolutionCB)}
                    className="bg-gray-50 flex md:hidden items-center text-center rounded-lg  hover:bg-gray-50 text-gray-600">
                    <PfIcon className="if i-check-solid text-sm lg:text-base" />
                    <span
                      className="ms-2 leading-tight text-xs md:text-tiny font-semibold block text-gray-900">
                      {str(t("solution"))}
                    </span>
                  </button>,
                  {
                    (moderator || isTopicCreator) &&
                    !(isFirstPost || Post.solution(post)) &&
                    Belt.Option.isNone(topicSolutionId)
                  },
                )}
                {Post.solution(post)
                  ? solutionIcon(userCanUnmarkSolution, unmarkPostAsSolutionCB, Post.id(post))
                  : React.null}
              </div>
            </div>
          </div>
          <div className="flex items-center text-sm font-semibold lg:mb-1">
            {switch topicSolutionId {
            | Some(id) =>
              isFirstPost
                ? <a
                    href={"#post-show-" ++ id}
                    className="flex items-center px-3 py-2 bg-green-200 text-green-900 border border-transparent rounded me-3  focus:border-primary-400 hover:border-green-500 hover:bg-green-300">
                    <PfIcon className="if i-arrow-down-circle-regular text-sm lg:text-base" />
                    <div className="text-xs font-semibold ps-2 ">
                      {str(t("go_to_solution_button"))}
                    </div>
                  </a>
                : React.null
            | None => React.null
            }}
            <div className="hidden lg:block">
              {ArrayUtils.isNotEmpty(repliesToPost)
                ? <button
                    id={"show-replies-" ++ Post.id(post)}
                    ariaLabel={t("show_replies") ++ " " ++ Post.id(post)}
                    onClick={_ => toggleShowReplies(showReplies => !showReplies)}
                    className="border bg-white me-3 p-2 rounded text-xs font-semibold focus:border-primary-400 hover:bg-gray-50">
                    {t(~count=Post.replies(post)->Js.Array2.length, "show_replies_button")->str}
                    <FaIcon classes={"ms-2 fas fa-chevron-" ++ (showReplies ? "up" : "down")} />
                  </button>
                : React.null}
            </div>
            {ReactUtils.nullIf(
              <button
                onClick={_ => {
                  addNewReplyCB()
                  navigateToEditor()
                }}
                id={"reply-button-" ++ Post.id(post)}
                ariaLabel={isFirstPost
                  ? t("add_reply_topic")
                  : t("add_reply_post") ++ Post.id(post)}
                className="bg-gray-50 lg:border lg:bg-gray-50 p-2 rounded text-xs font-semibold focus:border-primary-400 hover:bg-gray-300">
                <FaIcon classes="fas fa-reply me-2" />
                {t("new_reply_button")->str}
              </button>,
              Topic.lockedAt(topic)->Belt.Option.isSome,
            )}
          </div>
        </div>
        {showReplies
          ? <div
              ariaLabel={t("replies_post") ++ " " ++ Post.id(post)}
              className="lg:ps-10 pt-2 topics-post-show__replies-container">
              {React.array(
                Array.map(
                  post => <TopicsShow__PostReply key={Post.id(post)} post users />,
                  repliesToPost,
                ),
              )}
            </div>
          : React.null}
      </div>
    </div>
  </div>
}
