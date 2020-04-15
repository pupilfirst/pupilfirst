[%bs.raw {|require("./TopicsShow__Root.css")|}];

open TopicsShow__Types;

let str = React.string;

type state = {
  topic: Topic.t,
  firstPost: Post.t,
  replies: array(Post.t),
};

type action =
  | AddReply(Post.t, option(string))
  | AddReplyToFirstPost(Post.t)
  | LikeReply(Post.id)
  | RemoveLikeFromReply(Post.id)
  | LikeTopic
  | RemoveLikeFromTopic
  | UpdateTopicTitle(string)
  | UpdateReply(Post.t)
  | ArchivePost(Post.id);

let reducer = (state, action) => {
  switch (action) {
  | AddReply(newReply, replyToPostId) =>
    switch (replyToPostId) {
    | Some(id) =>
      let updatedParentPost =
        state.replies |> Post.find(id) |> Post.addReply(newReply |> Post.id);
      {
        ...state,
        replies:
          state.replies
          |> Js.Array.filter(r => Post.id(r) != id)
          |> Array.append([|newReply, updatedParentPost|]),
      };
    | None => {
        ...state,
        replies: state.replies |> Array.append([|newReply|]),
      }
    }
  | AddReplyToFirstPost(post) => {
      ...state,
      replies: state.replies |> Array.append([|post|]),
      firstPost: state.firstPost |> Post.addReply(post |> Post.id),
    }
  | LikeReply(postId) => state
  | RemoveLikeFromReply(postId) => state
  | LikeTopic => state
  | RemoveLikeFromTopic => state
  | UpdateTopicTitle(title) => state
  | UpdateReply(post) => {
      ...state,
      replies:
        state.replies
        |> Js.Array.filter(reply => Post.id(reply) != Post.id(post))
        |> Array.append([|post|]),
    }
  | ArchivePost(postId) => state
  };
};

let addNewReply = (send, replyToPostId, post) => {
  send(AddReply(post, replyToPostId));
};

let addNewReplyToFirstPost = (send, post) => {
  send(AddReplyToFirstPost(post));
};

let updatePost = (send, post) => {
  send(UpdateReply(post));
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

  let mainThread = state.replies |> Post.mainThread(state.firstPost);
  <div className="bg-gray-100">
    <div className="flex-col items-center justify-between">
      <div
        className="max-w-4xl w-full mx-auto items-center justify-center bg-white p-8 my-4 border-t border-b md:border-0 rounded md:rounded-lg shadow">
        {<div>
           <h3 className="leading-snug ml-14">
             {topic |> Topic.title |> str}
           </h3>
           <TopicsShow__PostShow
             key={Post.id(state.firstPost)}
             post={state.firstPost}
             topic
             users
             posts={state.replies}
             currentUserId
             updatePostCB={updatePost(send)}
             addNewReplyCB={addNewReplyToFirstPost(send)}
           />
         </div>}
        {<h5 className="pt-4 pb-2 ml-14 border-b mb-4">
           {(mainThread |> Array.length |> string_of_int) ++ " Replies" |> str}
         </h5>}
        {mainThread
         |> Array.map(reply =>
              <TopicsShow__PostShow
                key={Post.id(reply)}
                post=reply
                topic
                users
                posts={state.replies}
                currentUserId
                updatePostCB={updatePost(send)}
                addNewReplyCB={addNewReply(send, Some(Post.id(reply)))}
              />
            )
         |> React.array}
      </div>
      <div className="mt-4">
        <TopicsShow__PostEditor
          topic
          currentUserId
          postNumber={(state.replies |> Post.highestPostNumber) + 1}
          handlePostCB={addNewReply(send, None)}
        />
      </div>
    </div>
  </div>;
};
