[%bs.raw {|require("./TopicsShow__Root.css")|}];

open TopicsShow__Types;

let str = React.string;

type state = {
  topic: Topic.t,
  firstPost: Post.t,
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

let reducer = (state, action) => {
  switch (action) {
  | AddReply(post) => state
  | LikeReply(postId) => state
  | RemoveLikeFromReply(postId) => state
  | LikeTopic => state
  | RemoveLikeFromTopic => state
  | UpdateTopicTitle(title) => state
  | UpdateFirstPost(post) => state
  | UpdateReply(post) => state
  | ArchivePost(postId) => state
  };
};

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
    ) => {
  let (state, send) =
    React.useReducer(reducer, {topic, firstPost, replies});
  <div className="bg-gray-100">
    <div className="flex-col items-center justify-between">
      <div
        className="max-w-4xl w-full mx-auto items-center justify-center bg-white p-8 my-4 border-t border-b md:border-0 rounded md:rounded-lg shadow">
        {<div>
           <h3 className="leading-snug ml-14">
             {topic |> Topic.title |> str}
           </h3>
           <TopicsShow__PostShow
             post=firstPost
             topic
             users
             posts=replies
             currentUserId
           />
         </div>}
        {<h5 className="pt-4 pb-2 ml-14 border-b mb-4">
           {(replies |> Post.mainThread |> Array.length |> string_of_int)
            ++ " Replies"
            |> str}
         </h5>}
        {replies
         |> Post.mainThread
         |> Array.map(reply =>
              <TopicsShow__PostShow
                key={Post.id(reply)}
                post=reply
                topic
                users
                posts=replies
                currentUserId
              />
            )
         |> React.array}
      </div>
      <div className="mt-4">
        <TopicsShow__PostEditor topic currentUserId />
      </div>
    </div>
  </div>;
};
