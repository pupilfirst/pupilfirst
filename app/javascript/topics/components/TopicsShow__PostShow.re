open TopicsShow__Types;

let str = React.string;
[%bs.raw {|require("./TopicsShow__PostShow.css")|}];

let solutionIcon = {
  <div className="flex flex-col items-center pr-1 md:pr-4 pb-4 pt-2">
    <div
      className="flex items-center justify-center w-8 h-8 bg-green-200 text-green-800 rounded-full">
      <PfIcon className="if i-check-solid" />
    </div>
    <div className="text-tiny font-semibold text-green-800 pt-1">
      {"Solution" |> str}
    </div>
  </div>;
};

let findUser = (users, userId) => {
  users |> Array.to_list |> User.findById(userId);
};

let optionsDropdown =
    (isPostCreator, isTopicCreator, isCoach, isFirstPost, toggleShowPostEdit) => {
  let selected =
    <div
      className="flex items-center justify-center w-8 h-8 rounded leading-tight border bg-gray-100 text-gray-800 cursor-pointer hover:bg-gray-200">
      <PfIcon className="if i-ellipsis-h-regular text-base" />
    </div>;
  let postTypeString = isFirstPost ? "Post" : "Reply";
  let editPostButton =
    <button
      onClick={_ => toggleShowPostEdit(_ => true)}
      className="flex p-2 items-center text-gray-700 whitespace-no-wrap">
      <FaIcon classes="fas fa-edit mr-2" />
      {"Edit " ++ postTypeString |> str}
    </button>;
  let markAsSolutionButton =
    isFirstPost
      ? React.null
      : <button
          className="flex p-2 items-center text-gray-700 whitespace-no-wrap">
          <PfIcon className="if i-check-circle-alt-regular if-fw" />
          {"Mark as solution" |> str}
        </button>;
  let deletePostButton =
    <button className="flex p-2 items-center text-gray-700 whitespace-no-wrap">
      <FaIcon classes="fas fa-trash-alt mr-2" />
      {"Delete " ++ postTypeString |> str}
    </button>;

  let contents =
    switch (isCoach, isTopicCreator, isPostCreator) {
    | (true, _, _) => [|
        editPostButton,
        markAsSolutionButton,
        deletePostButton,
      |]
    | (false, true, false) => [|markAsSolutionButton|]
    | (false, true, true) => [|
        editPostButton,
        markAsSolutionButton,
        deletePostButton,
      |]
    | (false, false, true) => [|editPostButton, deletePostButton|]
    | _ => [||]
    };
  <Dropdown selected contents right=true />;
};

let onBorderAnimationEnd = event => {
  let element =
    ReactEvent.Animation.target(event) |> DomUtils.EventTarget.unsafeToElement;
  element->Webapi.Dom.Element.setClassName("");
};

let navigateToEditor = () => {
  let elementId = "add-reply-to-topic";
  let element =
    Webapi.Dom.document |> Webapi.Dom.Document.getElementById(elementId);
  Js.Global.setTimeout(
    () => {
      switch (element) {
      | Some(e) =>
        {
          Webapi.Dom.Element.scrollIntoView(e);
          e->Webapi.Dom.Element.setClassName("topics-show__highlighted-item");
        }
        |> ignore
      | None => Rollbar.error("Could not find the post to scroll to.")
      }
    },
    50,
  )
  |> ignore;
};

[@react.component]
let make =
    (
      ~post,
      ~topic,
      ~users,
      ~posts,
      ~currentUserId,
      ~isCoach,
      ~isTopicCreator,
      ~updatePostCB,
      ~addNewReplyCB,
      ~addPostLikeCB,
      ~removePostLikeCB,
    ) => {
  let user = findUser(users);
  let repliesToPost = post |> Post.repliesToPost(posts);
  let isPostCreator = currentUserId == Post.creatorId(post);
  let isFirstPost = Post.postNumber(post) == 1;
  let (showPostEdit, toggleShowPostEdit) = React.useState(() => false);
  let (showReplies, toggleShowReplies) = React.useState(() => false);

  <div id={"post-show-" ++ Post.id(post)} onAnimationEnd=onBorderAnimationEnd>
    <div className="flex pb-4" key={post |> Post.id}>
      <div id="likes-and-solution" className="hidden lg:flex flex-col w-1/8">
        {post |> Post.solution ? solutionIcon : React.null}
        {<TopicsShow__LikeManager
           postId={post |> Post.id}
           postLikes={post |> Post.postLikes}
           currentUserId
           addPostLikeCB
           removePostLikeCB
         />}
      </div>
      <div id="body-and-user-data" className="flex-1 border-b pb-8">
        <div className="pt-2" id="body">
          <div className="flex justify-between lg:hidden">
            <TopicsShow__UserShow
              user={user(post |> Post.creatorId)}
              createdAt={post |> Post.createdAt}
            />
            <div className="flex-shrink-0 mt-1">
              {isPostCreator || isCoach || isTopicCreator
                 ? optionsDropdown(
                     isPostCreator,
                     isTopicCreator,
                     isCoach,
                     isFirstPost,
                     toggleShowPostEdit,
                   )
                 : React.null}
            </div>
          </div>
          {showPostEdit
             ? <div className="flex-1">
                 <TopicsShow__PostEditor
                   id={"edit-post-" ++ Post.id(post)}
                   topic
                   currentUserId
                   post
                   handlePostCB=updatePostCB
                   postNumber={post |> Post.postNumber}
                   handleCloseCB={() => toggleShowPostEdit(_ => false)}
                 />
               </div>
             : <div className="flex items-start justify-between">
                 <div className="text-sm"> {post |> Post.body |> str} </div>
                 <div className="hidden lg:block flex-shrink-0">
                   {isPostCreator || isCoach || isTopicCreator
                      ? optionsDropdown(
                          isPostCreator,
                          isTopicCreator,
                          isCoach,
                          isFirstPost,
                          toggleShowPostEdit,
                        )
                      : React.null}
                 </div>
               </div>}
        </div>
        <div id="user-data" className="flex justify-between pt-4">
          <div className="flex">
            <div className="hidden lg:block">
              <TopicsShow__UserShow
                user={user(post |> Post.creatorId)}
                createdAt={post |> Post.createdAt}
              />
            </div>
            <div id="likes-and-solution" className="flex flex-col lg:hidden">
              {post |> Post.solution ? solutionIcon : React.null}
              {<TopicsShow__LikeManager
                 postId={post |> Post.id}
                 postLikes={post |> Post.postLikes}
                 currentUserId
                 addPostLikeCB
                 removePostLikeCB
               />}
            </div>
          </div>
          <div className="flex items-center text-sm font-semibold">
            {repliesToPost |> ArrayUtils.isNotEmpty
               ? <button
                   id="show-replies-button"
                   onClick={_ =>
                     toggleShowReplies(showReplies => !showReplies)
                   }
                   className="border bg-white mr-3 p-2 rounded text-xs font-semibold">
                   {(post |> Post.replies |> Array.length |> string_of_int)
                    ++ " Replies"
                    |> str}
                   <FaIcon classes="fas fa-chevron-down ml-2" />
                 </button>
               : React.null}
            <button
              onClick={_ => {
                addNewReplyCB();
                navigateToEditor();
              }}
              id="reply button"
              className="border bg-gray-200 p-2 rounded text-xs font-semibold">
              <FaIcon classes="fas fa-reply mr-2" />
              {"Reply" |> str}
            </button>
          </div>
        </div>
        {showReplies
           ? <div className="pl-10 pt-2 topics-post-show__replies-container">
               {repliesToPost
                |> Array.map(post =>
                     <TopicsShow__PostReplyShow
                       key={post |> Post.id}
                       post
                       users
                     />
                   )
                |> React.array}
             </div>
           : React.null}
      </div>
    </div>
  </div>;
};
