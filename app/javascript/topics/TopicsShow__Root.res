%bs.raw(`require("./TopicsShow__Root.css")`)

let t = I18n.t(~scope="components.TopicsShow__Root")

open TopicsShow__Types

let str = React.string

type state = {
  topic: Topic.t,
  firstPost: Post.t,
  replies: array<Post.t>,
  replyToPostId: option<string>,
  topicTitle: string,
  savingTopic: bool,
  changingLockedStatus: bool,
  showTopicEditor: bool,
  topicCategory: option<TopicCategory.t>,
  subscribed: bool,
}

type action =
  | SaveReply(Post.t, option<string>)
  | AddNewReply(option<string>)
  | LikeFirstPost
  | RemoveLikeFromFirstPost
  | LikeReply(Post.t)
  | RemoveLikeFromReply(Post.t)
  | UpdateFirstPost(Post.t)
  | UpdateReply(Post.t)
  | RemoveReplyToPost
  | ArchivePost(string)
  | UpdateTopicTitle(string)
  | SaveTopic(Topic.t)
  | ShowTopicEditor(bool)
  | UpdateSavingTopic(bool)
  | MarkReplyAsSolution(string)
  | UnmarkReplyAsSolution
  | StartChangingLockStatus
  | FinishLockingTopic(string)
  | FinishUnlockingTopic
  | UpdateTopicCategory(option<TopicCategory.t>)
  | Subscribe
  | Unsubscribe

let reducer = (state, action) =>
  switch action {
  | SaveReply(newReply, replyToPostId) =>
    switch replyToPostId {
    | Some(id) =>
      let updatedParentPost = state.replies |> Post.find(id) |> Post.addReply(newReply |> Post.id)
      {
        ...state,
        replies: state.replies
        |> Js.Array.filter(r => Post.id(r) != id)
        |> Array.append([newReply, updatedParentPost]),
        replyToPostId: None,
      }
    | None => {
        ...state,
        replies: state.replies |> Array.append([newReply]),
      }
    }
  | AddNewReply(replyToPostId) => {...state, replyToPostId: replyToPostId}
  | LikeFirstPost => {...state, firstPost: state.firstPost |> Post.addLike}
  | RemoveLikeFromFirstPost => {
      ...state,
      firstPost: state.firstPost |> Post.removeLike,
    }
  | LikeReply(post) =>
    let updatedPost = post |> Post.addLike
    {
      ...state,
      replies: state.replies
      |> Js.Array.filter(reply => Post.id(reply) != Post.id(post))
      |> Array.append([updatedPost]),
    }
  | RemoveLikeFromReply(post) =>
    let updatedPost = post |> Post.removeLike
    {
      ...state,
      replies: state.replies
      |> Js.Array.filter(reply => Post.id(reply) != Post.id(post))
      |> Array.append([updatedPost]),
    }
  | UpdateTopicTitle(topicTitle) => {...state, topicTitle: topicTitle}
  | UpdateFirstPost(firstPost) => {...state, firstPost: firstPost}
  | UpdateReply(reply) => {
      ...state,
      replies: state.replies
      |> Js.Array.filter(r => Post.id(r) != Post.id(reply))
      |> Array.append([reply]),
    }
  | ArchivePost(postId) => {
      ...state,
      replies: state.replies |> Js.Array.filter(r => Post.id(r) != postId),
    }
  | RemoveReplyToPost => {...state, replyToPostId: None}
  | UpdateSavingTopic(savingTopic) => {...state, savingTopic: savingTopic}
  | SaveTopic(topic) => {
      ...state,
      topic: topic,
      savingTopic: false,
      showTopicEditor: false,
    }
  | ShowTopicEditor(showTopicEditor) => {...state, showTopicEditor: showTopicEditor}
  | MarkReplyAsSolution(postId) => {
      ...state,
      replies: state.replies |> Post.markAsSolution(postId),
    }
  | UnmarkReplyAsSolution => {
      ...state,
      replies: Post.unmarkSolution(state.replies),
    }
  | UpdateTopicCategory(topicCategory) => {...state, topicCategory: topicCategory}
  | StartChangingLockStatus => {...state, changingLockedStatus: true}
  | Subscribe => {...state, subscribed: true}
  | Unsubscribe => {...state, subscribed: false}
  | FinishLockingTopic(currentUserId) => {
      ...state,
      changingLockedStatus: false,
      topic: Topic.lock(currentUserId, state.topic),
    }
  | FinishUnlockingTopic => {
      ...state,
      changingLockedStatus: false,
      topic: Topic.unlock(state.topic),
    }
  }

let subscribe = (send, ()) => {
  send(Subscribe)
}

let unsubscribe = (send, ()) => {
  send(Unsubscribe)
}

let addNewReply = (send, replyToPostId, ()) => send(AddNewReply(replyToPostId))

let updateReply = (send, reply) => send(UpdateReply(reply))

let updateFirstPost = (send, post) => send(UpdateFirstPost(post))

let saveReply = (send, replyToPostId, reply) => send(SaveReply(reply, replyToPostId))

let isTopicCreator = (firstPost, currentUserId) =>
  Post.creatorId(firstPost)->Belt.Option.mapWithDefault(false, id => id == currentUserId)

let archiveTopic = community =>
  community |> Community.path |> Webapi.Dom.Window.setLocation(Webapi.Dom.window)

module UpdateTopicQuery = %graphql(
  `
  mutation UpdateTopicMutation($id: ID!, $title: String!, $topicCategoryId: ID) {
    updateTopic(id: $id, title: $title, topicCategoryId: $topicCategoryId)  {
      success
    }
  }
`
)

let updateTopic = (state, send, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send(UpdateSavingTopic(true))
  let topicCategoryId = Belt.Option.flatMap(state.topicCategory, category => Some(
    TopicCategory.id(category),
  ))
  UpdateTopicQuery.make(~id=state.topic |> Topic.id, ~title=state.topicTitle, ~topicCategoryId?, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["updateTopic"]["success"]
      ? {
          let topic = state.topic |> Topic.updateTitle(state.topicTitle)
          send(SaveTopic(topic))
        }
      : send(UpdateSavingTopic(false))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(UpdateSavingTopic(false))
    Js.Promise.resolve()
  })
  |> ignore
}

module LockTopicQuery = %graphql(
  `
  mutation LockTopicMutation($id: ID!) {
    lockTopic(id: $id)  {
      success
    }
  }
`
)

module UnlockTopicQuery = %graphql(
  `
  mutation UnlockTopicMutation($id: ID!) {
    unlockTopic(id: $id)  {
      success
    }
  }
`
)

let lockTopic = (topicId, currentUserId, send) =>
  WindowUtils.confirm("Are you sure you want to lock this topic?", () => {
    send(StartChangingLockStatus)
    LockTopicQuery.make(~id=topicId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      response["lockTopic"]["success"] ? send(FinishLockingTopic(currentUserId)) : ()
      Js.Promise.resolve()
    }) |> ignore
  })

let unlockTopic = (topicId, send) =>
  WindowUtils.confirm("Are you sure you want to unlock this topic?", () => {
    send(StartChangingLockStatus)
    UnlockTopicQuery.make(~id=topicId, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response => {
      response["unlockTopic"]["success"] ? send(FinishUnlockingTopic) : ()
      Js.Promise.resolve()
    })
    |> ignore
  })

let communityLink = community =>
  <a href={Community.path(community)} className="btn btn-subtle">
    <i className="fas fa-users" />
    <span className="ml-2"> {Community.name(community) |> str} </span>
  </a>

let topicCategory = (topicCategories, topicCategoryId) =>
  switch topicCategoryId {
  | Some(id) =>
    Some(
      ArrayUtils.unsafeFind(
        category => TopicCategory.id(category) == id,
        "Unable to find topic category with ID: " ++ id,
        topicCategories,
      ),
    )
  | None => None
  }

let categoryDropdownSelected = topicCategory =>
  <div
    ariaLabel="Selected category"
    className="flex justify-between text-sm bg-white border border-gray-400 rounded py-1 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300 cursor-pointer">
    {switch topicCategory {
    | Some(topicCategory) =>
      let (color, _) = TopicCategory.color(topicCategory)
      let style = ReactDOMRe.Style.make(~backgroundColor=color, ())

      <div className="inline-flex items-center">
        <div className="h-3 w-3 rounded mt-px" style />
        <span className="ml-2"> {TopicCategory.name(topicCategory)->str} </span>
      </div>
    | None => str("None")
    }}
    <FaIcon classes="ml-4 fas fa-caret-down" />
  </div>

let topicCategorySelector = (send, selectedTopicCategory, availableTopicCategories) => {
  let selectableTopicCategories = Belt.Option.mapWithDefault(
    selectedTopicCategory,
    availableTopicCategories,
    topicCategory =>
      Js.Array.filter(
        availableTopicCategory =>
          TopicCategory.id(availableTopicCategory) != TopicCategory.id(topicCategory),
        availableTopicCategories,
      ),
  )

  let topicCategoryList = Js.Array.map(topicCategory => {
    let (color, _) = TopicCategory.color(topicCategory)
    let style = ReactDOMRe.Style.make(~backgroundColor=color, ())
    let categoryName = TopicCategory.name(topicCategory)

    <div
      ariaLabel={"Select category " ++ categoryName}
      className="px-3 py-2 font-normal flex items-center"
      onClick={_ => send(UpdateTopicCategory(Some(topicCategory)))}>
      <div className="w-3 h-3 rounded mt-px" style />
      <span className="ml-2"> {categoryName->str} </span>
    </div>
  }, selectableTopicCategories)

  switch selectedTopicCategory {
  | None => topicCategoryList
  | Some(_category) =>
    Js.Array.concat(
      topicCategoryList,
      [
        <div
          ariaLabel="Select no category"
          className="px-3 py-2 font-normal flex items-center"
          onClick={_ => send(UpdateTopicCategory(None))}>
          <div className="w-3 h-3 rounded bg-gray-300 mt-px" />
          <span className="ml-2"> {"None"->str} </span>
        </div>,
      ],
    )
  }
}

let topicSolutionId = replies => {
  Js.Array.find(Post.solution, replies)->Belt.Option.map(Post.id)
}

@react.component
let make = (
  ~topic,
  ~firstPost,
  ~replies,
  ~users,
  ~currentUserId,
  ~moderator,
  ~community,
  ~target,
  ~topicCategories,
  ~subscribed,
) => {
  let (state, send) = React.useReducerWithMapState(reducer, topic, topic => {
    topic: topic,
    firstPost: firstPost,
    replies: replies,
    replyToPostId: None,
    topicTitle: topic |> Topic.title,
    savingTopic: false,
    showTopicEditor: false,
    changingLockedStatus: false,
    subscribed: subscribed,
    topicCategory: topicCategory(topicCategories, Topic.topicCategoryId(topic)),
  })

  <div className="bg-gray-100">
    <div className="max-w-4xl w-full mt-5 pl-4 lg:pl-0 lg:mx-auto">
      {communityLink(community)}
    </div>
    <div className="flex-col items-center justify-between">
      {switch target {
      | Some(target) =>
        <div className="max-w-4xl w-full mt-5 lg:x-4 mx-auto">
          <div
            className="flex py-4 px-4 md:px-5 mx-3 lg:mx-0 bg-white border border-primary-500 shadow-md rounded-lg justify-between items-center">
            <p className="w-3/5 md:w-4/5 text-sm">
              <span className="font-semibold block text-xs">
                {t("linked_target_label") |> str}
              </span>
              <span> {target |> LinkedTarget.title |> str} </span>
            </p>
            {switch target |> LinkedTarget.id {
            | Some(id) =>
              <a href={"/targets/" ++ id} className="btn btn-default">
                {t("view_target_button") |> str}
              </a>
            | None => React.null
            }}
          </div>
        </div>
      | None => React.null
      }}
      <div
        className="max-w-4xl w-full mx-auto bg-white p-4 lg:p-8 my-4 border-t border-b md:border-0 lg:rounded-lg lg:shadow">
        <div ariaLabel="Topic Details">
          {state.showTopicEditor
            ? <DisablingCover disabled=state.savingTopic>
                <div
                  className="flex flex-col lg:ml-14 bg-gray-100 p-2 rounded border border-primary-200">
                  <input
                    onChange={event =>
                      send(UpdateTopicTitle(ReactEvent.Form.target(event)["value"]))}
                    value=state.topicTitle
                    className="appearance-none block w-full bg-white text-gray-900 font-semibold border border-gray-400 rounded py-3 px-4 mb-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                    type_="text"
                  />
                  <div className="flex flex-col md:flex-row md:justify-between md:items-end">
                    <div className="flex flex-col items-left flex-shrink-0">
                      <span className="inline-block text-gray-700 text-tiny font-semibold mr-2">
                        {t("topic_category_label") |> str}
                      </span>
                      <Dropdown
                        selected={categoryDropdownSelected(state.topicCategory)}
                        contents={topicCategorySelector(send, state.topicCategory, topicCategories)}
                        className=""
                      />
                    </div>
                    <div className="flex justify-end pt-4 md:pt-0">
                      <button
                        onClick={_ => send(ShowTopicEditor(false))} className="btn btn-subtle mr-3">
                        {t("topic_editor_cancel_button") |> str}
                      </button>
                      <button
                        onClick={updateTopic(state, send)}
                        disabled={state.topicTitle |> Js.String.trim == ""}
                        className="btn btn-primary">
                        {t("update_topic_button") |> str}
                      </button>
                    </div>
                  </div>
                </div>
              </DisablingCover>
            : <div className="flex flex-col ">
                <div
                  className="topics-show__title-container flex items-center md:items-start justify-between mb-2">
                  <h3
                    ariaLabel="Topic Title"
                    className="leading-snug lg:pl-14 text-base lg:text-2xl w-9/12">
                    {state.topic |> Topic.title |> str}
                  </h3>
                  <span className="flex">
                    {moderator || isTopicCreator(firstPost, currentUserId)
                      ? <button
                          onClick={_ => send(ShowTopicEditor(true))}
                          className="topics-show__title-edit-button inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0 mt-2 ml-3">
                          <i className="far fa-edit" />
                          <span className="hidden md:inline-block ml-1">
                            {t("edit_topic_button") |> str}
                          </span>
                        </button>
                      : React.null}
                    {
                      let isLocked = Topic.lockedAt(state.topic)->Belt.Option.isSome
                      let topicId = state.topic->Topic.id
                      moderator
                        ? <button
                            disabled=state.changingLockedStatus
                            onClick={_ =>
                              isLocked
                                ? unlockTopic(topicId, send)
                                : lockTopic(topicId, currentUserId, send)}
                            className="topics-show__title-edit-button inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0 mt-2 ml-2">
                            <PfIcon className={"fa fa-" ++ (isLocked ? "unlock" : "lock")} />
                            <span className="hidden md:inline-block ml-1">
                              {(
                                isLocked ? t("unlock_topic_button") : t("lock_topic_button")
                              ) |> str}
                            </span>
                          </button>
                        : React.null
                    }
                  </span>
                </div>
                {switch state.topicCategory {
                | Some(topicCategory) =>
                  let (color, _) = TopicCategory.color(topicCategory)
                  let style = ReactDOMRe.Style.make(~backgroundColor=color, ())
                  <div className="py-2 flex items-center lg:pl-14 text-xs font-semibold">
                    <div className="w-3 h-3 rounded" style />
                    <span className="ml-2"> {TopicCategory.name(topicCategory)->str} </span>
                  </div>
                | None => React.null
                }}
                <div className="lg:pl-14">
                  <TopicsShow__SubscriptionManager
                    subscribed={state.subscribed}
                    topicId={Topic.id(topic)}
                    subscribeCB={subscribe(send)}
                    unsubscribeCB={unsubscribe(send)}
                  />
                </div>
              </div>}
          {<TopicsShow__PostShow
            key={Post.id(state.firstPost)}
            post=state.firstPost
            topic=state.topic
            users
            posts=state.replies
            currentUserId
            moderator
            isTopicCreator={isTopicCreator(firstPost, currentUserId)}
            updatePostCB={updateFirstPost(send)}
            addNewReplyCB={addNewReply(send, None)}
            addPostLikeCB={() => send(LikeFirstPost)}
            removePostLikeCB={() => send(RemoveLikeFromFirstPost)}
            markPostAsSolutionCB={() => ()}
            unmarkPostAsSolutionCB={() => ()}
            archivePostCB={() => archiveTopic(community)}
            topicSolutionId={topicSolutionId(state.replies)}
          />}
        </div>
        <h5 className="pt-4 pb-2 lg:ml-14 border-b">
          {Inflector.pluralize(
            "Reply",
            ~count=Array.length(state.replies),
            ~inclusive=true,
            (),
          ) |> str}
        </h5>
        {state.replies
        |> Post.sort
        |> Array.map(reply =>
          <div key={Post.id(reply)} className="topics-show__replies-wrapper">
            <TopicsShow__PostShow
              post=reply
              topic=state.topic
              users
              posts=state.replies
              currentUserId
              moderator
              isTopicCreator={isTopicCreator(firstPost, currentUserId)}
              updatePostCB={updateReply(send)}
              addNewReplyCB={addNewReply(send, Some(Post.id(reply)))}
              markPostAsSolutionCB={() => send(MarkReplyAsSolution(Post.id(reply)))}
              unmarkPostAsSolutionCB={() => send(UnmarkReplyAsSolution)}
              removePostLikeCB={() => send(RemoveLikeFromReply(reply))}
              addPostLikeCB={() => send(LikeReply(reply))}
              archivePostCB={() => send(ArchivePost(Post.id(reply)))}
              topicSolutionId={topicSolutionId(state.replies)}
            />
          </div>
        )
        |> React.array}
      </div>
      <div className="mt-4 px-4">
        {switch Topic.lockedAt(state.topic) {
        | Some(_lockedAt) =>
          <div
            className="flex p-4 bg-yellow-100 text-yellow-900 border border-yellow-500 border-l-4 rounded-r-md mt-2 mx-auto w-full max-w-4xl mb-4 text-sm justify-center items-center">
            <div className="w-6 h-6 text-yellow-500 flex-shrink-0">
              <i className="fa fa-lock" />
            </div>
            <span className="ml-2"> {t("locked_topic_notice")->React.string} </span>
          </div>

        | None =>
          <TopicsShow__PostEditor
            id="add-reply-to-topic"
            topic
            currentUserId
            handlePostCB={saveReply(send, state.replyToPostId)}
            replyToPostId=?state.replyToPostId
            replies=state.replies
            users
            removeReplyToPostCB={() => send(RemoveReplyToPost)}
          />
        }}
      </div>
    </div>
  </div>
}
