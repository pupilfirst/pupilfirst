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
  | LikeFirstPost(Like.t)
  | RemoveLikeFromFirstPost(string)
  | LikeReply(Post.t, Like.t)
  | RemoveLikeFromReply(Post.t, string)
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
             addPostLikeCB={addFirstPostLike(send)}
             removePostLikeCB={removeFirstPostLike(send)}
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
                addPostLikeCB={addReplyLike(send, reply)}
                removePostLikeCB={removeReplyLike(send, reply)}
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
