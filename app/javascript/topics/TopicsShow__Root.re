[%bs.raw {|require("./TopicsShow__Root.css")|}];

open TopicsShow__Types;

let str = React.string;

type state = {
  topic: Topic.t,
  first_post: Post.t,
  replies: array(Post.t),
};

type action =
  | AddReply(Post.t)
  | LikeReply(Post.id)
  | RemoveLikeFromReply(Post.id)
  | LikeTopic
  | RemoveLikeFromTopic
  | UpdateTopicTitle(string)
  | UpdateFirstPost(Post.t)
  | UpdateReply(Post.t)
  | ArchivePost(Post.id);

[@react.component]
let make =
    (
      ~topic,
      ~firstPost,
      ~replies,
      ~users,
      ~currentUserId,
      ~isCoach,
      ~communityId,
      ~target,
    ) =>
  <div> {"Hello" |> str} </div>;
