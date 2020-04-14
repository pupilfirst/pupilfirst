open TopicsShow__Types;

let str = React.string;

let solutionIcon = {
  <div className="flex flex-col items-center">
    <div className="bg-green-300 text-green-700 w-5 text-center">
      <PfIcon className="if i-check-square-solid if-fw" />
    </div>
    <div className="text-xs text-green-700"> {"Solution" |> str} </div>
  </div>;
};

let findUser = (users, userId) => {
  users |> Array.to_list |> User.findById(userId);
};

let optionsDropdown = toggleShowPostEdit => {
  let selected =
    <div
      className="flex items-center justify-center w-8 h-8 rounded leading-tight border bg-gray-100 text-gray-800 cursor-pointer hover:bg-gray-200">
      <PfIcon className="if i-ellipsis-h-regular text-base" />
    </div>;
  let editPostButton =
    <button
      onClick={_ => toggleShowPostEdit(_ => true)}
      className="flex p-2 items-center text-gray-700">
      <FaIcon classes="fas fa-edit mr-2" />
      {"Edit Reply" |> str}
    </button>;
  let markAsSolutionButton =
    <button className="flex p-2 items-center text-gray-700">
      <PfIcon className="if i-check-circle-alt-regular if-fw" />
      {"Mark as solution" |> str}
    </button>;
  let deletePostButton =
    <button className="flex p-2 items-center text-gray-700">
      <FaIcon classes="fas fa-trash-alt mr-2" />
      {"Delete Reply" |> str}
    </button>;
  <Dropdown
    selected
    contents=[|editPostButton, markAsSolutionButton, deletePostButton|]
    right=true
  />;
};

[@react.component]
let make = (~post, ~topic, ~users, ~posts, ~currentUserId) => {
  let user = findUser(users);
  let repliesToPost = post |> Post.repliesToPost(posts);
  let (showPostEdit, toggleShowPostEdit) = React.useState(() => false);
  let (showReplies, toggleShowReplies) = React.useState(() => false);
  let (showNewReply, toggleshowNewReply) = React.useState(() => false);
  let handleCloseCB = () => toggleShowPostEdit(_ => false);
  let handlePostEditCB = (post, bool) => {
    toggleShowPostEdit(_
      => false);
      // handlePostCB(post, bool);
  };
  <div>
    <div className="flex pt-4" key={post |> Post.id}>
      <div id="likes-and-solution" className="flex flex-col w-1/8">
        {post |> Post.solution ? solutionIcon : React.null}
        {<TopicsShow__LikeManager
           postLikes={post |> Post.postLikes}
           currentUserId
         />}
      </div>
      <div id="body-and-user-data" className="w-7/8">
        <div id="body" className="flex items-start">
          {showPostEdit
             ? <div className="flex-1">
                 <TopicsShow__PostEditor
                   topic
                   currentUserId
                   post
                   handleCloseCB={() => toggleShowPostEdit(_ => false)}
                 />
               </div>
             : <div className="flex items-start">
                 <div className="text-sm"> {post |> Post.body |> str} </div>
                 <div className="flex-shrink-0">
                   {optionsDropdown(toggleShowPostEdit)}
                 </div>
               </div>}
        </div>
        <div id="user-data" className="flex justify-between pt-4">
          <TopicsShow__UserShow
            user={user(post |> Post.creatorId)}
            createdAt={post |> Post.createdAt}
          />
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
              onClick={_ => toggleshowNewReply(showNewReply => !showNewReply)}
              id="reply button"
              className="border bg-gray-200 p-2 rounded text-xs font-semibold">
              <FaIcon classes="fas fa-reply mr-2" />
              {"Reply" |> str}
            </button>
          </div>
        </div>
        {showNewReply
           ? <TopicsShow__PostEditor
               topic
               currentUserId
               handleCloseCB={() => toggleshowNewReply(_ => false)}
             />
           : React.null}
        {showReplies
           ? <div>
               {repliesToPost
                |> Array.map(post =>
                     <TopicsShow__PostReplyShow
                       topic
                       post
                       currentUserId
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
