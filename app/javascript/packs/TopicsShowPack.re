open TopicsShow__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("topic", Topic.decode),
    json |> field("firstPost", Post.decode),
    json |> field("replies", array(Post.decode)),
    json |> field("users", array(User.decode)),
    json |> field("currentUserId", string),
    json |> field("isCoach", bool),
    json |> field("communityId", string),
    json |> optional(field("target", LinkedTarget.decode)),
  );

let (
  topic,
  firstPost,
  replies,
  users,
  currentUserId,
  isCoach,
  communityId,
  target,
) =
  DomUtils.parseJsonTag() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <TopicsShow__Root
    topic
    firstPost
    replies
    users
    currentUserId
    isCoach
    communityId
    target
  />,
  "react-root",
);
