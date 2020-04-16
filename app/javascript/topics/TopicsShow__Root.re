[%bs.raw {|require("./TopicsShow__Root.css")|}];

open TopicsShow__Types;

let str = React.string;

type state = {
  topic: Topic.t,
  firstPost: Post.t,
  replies: array(Post.t),
  replyToPostId: option(string),
};

type action =
  | SaveReply(Post.t, option(string))
  | AddNewReply(option(string))
  | LikeFirstPost(Like.t)
  | RemoveLikeFromFirstPost(string)
  | LikeReply(Post.t, Like.t)
  | RemoveLikeFromReply(Post.t, string)
  | UpdateTopicTitle(string)
  | UpdateFirstPost(Post.t)
  | UpdateReply(Post.t)
  | ArchivePost(Post.id);

let reducer = (state, action) => {
  switch (action) {
  | SaveReply(newReply, replyToPostId) =>
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
  | AddNewReply(replyToPostId) => {...state, replyToPostId}
  | LikeFirstPost(like) => {
      ...state,
      firstPost: state.firstPost |> Post.addLike(like),
    }
  | RemoveLikeFromFirstPost(likeId) => {
      ...state,
      firstPost: state.firstPost |> Post.removeLike(likeId),
    }
  | LikeReply(post, like) =>
    let updatedPost = post |> Post.addLike(like);
    {
      ...state,
      replies:
        state.replies
        |> Js.Array.filter(reply => Post.id(reply) != Post.id(post))
        |> Array.append([|updatedPost|]),
    };
  | RemoveLikeFromReply(post, likeId) =>
    let updatedPost = post |> Post.removeLike(likeId);
    {
      ...state,
      replies:
        state.replies
        |> Js.Array.filter(reply => Post.id(reply) != Post.id(post))
        |> Array.append([|updatedPost|]),
    };
  | UpdateTopicTitle(title) => state
  | UpdateFirstPost(firstPost) => {...state, firstPost}
  | UpdateReply(reply) => {
      ...state,
      replies:
        state.replies
        |> Js.Array.filter(r => Post.id(r) != Post.id(reply))
        |> Array.append([|reply|]),
    }
  | ArchivePost(postId) => state
  };
};

let addNewReply = (send, replyToPostId, ()) => {
  send(AddNewReply(replyToPostId));
};

let updateReply = (send, reply) => {
  send(UpdateReply(reply));
};

let updateFirstPost = (send, post) => {
  send(UpdateFirstPost(post));
};

let saveReply = (send, replyToPostId, reply) => {
  send(SaveReply(reply, replyToPostId));
};

let addReplyLike = (send, post, like) => {
  send(LikeReply(post, like));
};

let removeReplyLike = (send, post, likeId) => {
  send(RemoveLikeFromReply(post, likeId));
};

let addFirstPostLike = (send, like) => {
  send(LikeFirstPost(like));
};

let removeFirstPostLike = (send, likeId) => {
  send(RemoveLikeFromFirstPost(likeId));
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
    React.useReducer(
      reducer,
      {topic, firstPost, replies, replyToPostId: None},
    );

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
             posts=[||]
             currentUserId
             updatePostCB={updateFirstPost(send)}
             addNewReplyCB={addNewReply(send, None)}
             addPostLikeCB={addFirstPostLike(send)}
             removePostLikeCB={removeFirstPostLike(send)}
           />
         </div>}
        {<h5 className="pt-4 pb-2 ml-14 border-b mb-4">
           {(state.replies |> Array.length |> string_of_int)
            ++ " Replies"
            |> str}
         </h5>}
        {state.replies
         |> Post.sort
         |> Array.map(reply =>
              <TopicsShow__PostShow
                key={Post.id(reply)}
                post=reply
                topic
                users
                posts={state.replies}
                currentUserId
                updatePostCB={updateReply(send)}
                addNewReplyCB={addNewReply(send, Some(Post.id(reply)))}
                addPostLikeCB={addReplyLike(send, reply)}
                removePostLikeCB={removeReplyLike(send, reply)}
              />
            )
         |> React.array}
      </div>
      <div className="mt-4">
        <TopicsShow__PostEditor
          id="add-reply-to-topic"
          topic
          currentUserId
          postNumber={(state.replies |> Post.highestPostNumber) + 1}
          handlePostCB={saveReply(send, state.replyToPostId)}
          replyToPostId=?{state.replyToPostId}
        />
      </div>
    </div>
  </div>;
};
