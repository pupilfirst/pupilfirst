open TopicsShow__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("topic", Topic.decode),
    json |> field("firstPost", Post.decode),
    json |> field("replies", array(Post.decode)),
    json |> field("users", array(User.decode)),
    json |> field("currentUserId", string),
    json |> field("moderator", bool),
    json |> field("community", Community.decode),
    json |> optional(field("target", LinkedTarget.decode)),
    json |> field("topicCategories", array(TopicCategory.decode)),
    json |> field("subscribed", bool),
  )
}

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
) =
  DomUtils.parseJSONTag() |> decodeProps

ReactDOMRe.renderToElementWithId(
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
  "react-root",
)
