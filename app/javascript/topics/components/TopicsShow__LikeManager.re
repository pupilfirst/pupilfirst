open TopicsShow__Types;

let str = React.string;

module CreatePostLikeQuery = [%graphql
  {|
  mutation CreatePostLikeMutation($postId: ID!) {
    createPostLike(postId: $postId)  {
      success
    }
  }
|}
];

module DeletePostLikeQuery = [%graphql
  {|
  mutation DeletePostLikeMutation($postId: ID!) {
    deletePostLike(postId: $postId) {
      success
    }
  }
  |}
];

let iconClasses = (liked, saving) => {
  let classes = "text-lg";
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
        DeletePostLikeQuery.make(~postId, ())
        |> GraphqlQuery.sendQuery
        |> Js.Promise.then_(response => {
             response##deletePostLike##success
               ? {
                 removeLikeCB();
                 setSaving(_ => false);
               }
               : setSaving(_ => false);
             Js.Promise.resolve();
           })
        |> Js.Promise.catch(_ => {
             setSaving(_ => false);
             Js.Promise.resolve();
           })
        |> ignore;
      } else {
        CreatePostLikeQuery.make(~postId, ())
        |> GraphqlQuery.sendQuery
        |> Js.Promise.then_(response => {
             response##createPostLike##success
               ? handleCreateResponse(setSaving, addLikeCB)
               : setSaving(_ => false);
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

let handleCreateResponse = (setSaving, addLikeCB) => {
  setSaving(_ => false);
  addLikeCB();
};

[@react.component]
let make = (~post, ~addPostLikeCB, ~removePostLikeCB) => {
  let (saving, setSaving) = React.useState(() => false);
  let liked = Post.likedByUser(post);
  <div className="text-center pr-3 md:pr-4">
    <div
      ariaLabel={(liked ? "Unlike" : "Like") ++ " reply " ++ Post.id(post)}
      className="cursor-pointer"
      onClick={handlePostLike(
        saving,
        liked,
        setSaving,
        Post.id(post),
        removePostLikeCB,
        handleCreateResponse,
        addPostLikeCB,
      )}>
      <div
        className="flex items-center justify-center rounded-lg lg:rounded-full lg:bg-gray-100 hover:bg-gray-300 text-gray-700 hover:text-gray-900 h-8 w-8 md:h-10 md:w-10 p-1 md:p-2 mx-auto"
        key={iconClasses(liked, saving)}>
        <i className={iconClasses(liked, saving)} />
      </div>
      <p className="text-tiny lg:text-xs font-semibold">
        {post |> Post.totalLikes |> string_of_int |> str}
      </p>
    </div>
  </div>;
};
