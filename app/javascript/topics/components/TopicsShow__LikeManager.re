open TopicsShow__Types;

let str = React.string;

module CreatePostLikeQuery = [%graphql
  {|
  mutation CreatePostLikeMutation($postId: ID!) {
    createPostLike(postId: $postId)  {
      postLikeId
    }
  }
|}
];

module DeletePostLikeQuery = [%graphql
  {|
  mutation DeletePostLikeMutation($id: ID!) {
    deletePostLike(id: $id) {
      success
    }
  }
  |}
];

let iconClasses = (liked, saving) => {
  let classes = "text-xl text-gray-600";
  classes
  ++ (
    if (saving) {
      " fas fa-thumbs-up cursor-pointer text-primary-200";
    } else if (liked) {
      " fas fa-thumbs-up cursor-pointer text-primary-400";
    } else {
      " far fa-thumbs-up cursor-pointer";
    }
  );
};

let handlePostLike =
    (
      saving,
      liked,
      setSaving,
      postId,
      currentUserId,
      likes,
      removeLikeCB,
      handleCreateResponse,
      addLikeCB,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  saving
    ? ()
    : {
      setSaving(_ => true);
      if (liked) {
        let id = currentUserId |> Like.findUserLike(likes) |> Like.id;
        DeletePostLikeQuery.make(~id, ())
        |> GraphqlQuery.sendQuery
        |> Js.Promise.then_(response => {
             response##deletePostLike##success
               ? {
                 removeLikeCB(id);
                 setSaving(_ => false);
               }
               : setSaving(_ => false);
             Js.Promise.resolve();
           })
        |> ignore;
      } else {
        CreatePostLikeQuery.make(~postId, ())
        |> GraphqlQuery.sendQuery
        |> Js.Promise.then_(response => {
             switch (response##createPostLike##postLikeId) {
             | Some(id) =>
               handleCreateResponse(
                 id,
                 currentUserId,
                 postId,
                 setSaving,
                 addLikeCB,
               )
             | None => setSaving(_ => false)
             };
             Js.Promise.resolve();
           })
        |> Js.Promise.catch(_ => {
             setSaving(_ => false);
             Js.Promise.resolve();
           })
        |> ignore;
      };
    };
};

let handleCreateResponse = (id, currentUserId, postId, setSaving, addLikeCB) => {
  let like = Like.create(id, currentUserId);
  setSaving(_ => false);
  addLikeCB(like);
};

[@react.component]
let make =
    (~postId, ~postLikes, ~currentUserId, ~addPostLikeCB, ~removePostLikeCB) => {
  let liked = currentUserId |> Like.currentUserLiked(postLikes);
  let (saving, setSaving) = React.useState(() => false);

  <div className="text-center pr-1 md:pr-4">
    <div
      className="cursor-pointer"
      title={(liked ? "Unlike" : "Like") ++ " Answer"}
      onClick={handlePostLike(
        saving,
        liked,
        setSaving,
        postId,
        currentUserId,
        postLikes,
        removePostLikeCB,
        handleCreateResponse,
        addPostLikeCB,
      )}>
      <div
        className="flex items-center justify-center rounded-full hover:bg-gray-100 h-8 w-8 md:h-10 md:w-10 p-1 md:p-2"
        key={iconClasses(liked, saving)}>
        <i className={iconClasses(liked, saving)} />
      </div>
      <p className="text-xs pb-1">
        {postLikes |> Array.length |> string_of_int |> str}
      </p>
    </div>
  </div>;
};
