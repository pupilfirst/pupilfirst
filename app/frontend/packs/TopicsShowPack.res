open TopicsShow__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("topic", Topic.decode, json),
    field("firstPost", Post.decode, json),
    field("replies", array(Post.decode), json),
    field("users", array(User.decode), json),
    field("currentUserId", string, json),
    field("moderator", bool, json),
    field("community", Community.decode, json),
    option(field("target", LinkedTarget.decode), json),
    field("topicCategories", array(TopicCategory.decode), json),
    field("subscribed", bool, json),
  )
}

Psj.match("topics#show", () => {
  let (
    topic,
    firstPost,
    replies,
    users,
    currentUserId,
    moderator,
    community,
    target,
    topicCategories,
    subscribed,
  ) = decodeProps(DomUtils.parseJSONTag())

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <TopicsShow__Root
        topic
        firstPost
        replies
        users
        currentUserId
        moderator
        community
        target
        topicCategories
        subscribed
      />,
      root,
    )
  | None => ()
  }
})
