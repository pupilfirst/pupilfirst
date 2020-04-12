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

let optionsDropdown = {
  let selected = <PfIcon className="if i-ellipsis-h-light if-fw" />;
  let editPostButton =
    <button className="flex p-2 items-center text-gray-700">
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
  let handleCloseCB = () => toggleShowPostEdit(_ => false);
  let handlePostEditCB = (post, bool) => {
    toggleShowPostEdit(_
      => false);
      // handlePostCB(post, bool);
  };
  <div className="flex pt-2" key={post |> Post.id}>
    <div id="likes-and-solution" className="flex flex-col w-1/8">
      {post |> Post.solution ? solutionIcon : React.null}
      {<TopicsShow__LikeManager
         postLikes={post |> Post.postLikes}
         currentUserId
       />}
    </div>
    <div id="body-and-user-data" className="w-7/8 ml-2">
      <div id="body" className="flex">
        <div className="w-7/8"> {post |> Post.body |> str} </div>
        <div className="w-1/8 cursor-pointer hover:bg-gray-400 bg-gray-200">
          optionsDropdown
        </div>
      </div>
      <div id="user-data" className="flex justify-between">
        <TopicsShow__UserShow
          user={user(post |> Post.creatorId)}
          createdAt={post |> Post.createdAt}
        />
        <div className="flex items-center text-sm font-semibold">
          {repliesToPost |> ArrayUtils.isNotEmpty
             ? <button
                 id="show-replies-button"
                 onClick={_ => toggleShowReplies(showReplies => !showReplies)}
                 className="border border-gray-300 bg-white mr-3 p-2 rounded-lg">
                 {(post |> Post.replies |> Array.length |> string_of_int)
                  ++ " Replies"
                  |> str}
                 <FaIcon classes="fas fa-chevron-down ml-2" />
               </button>
             : React.null}
          <button
            id="reply button"
            className=" border border-gray-300 bg-gray-200 p-2 rounded-lg">
            <FaIcon classes="fas fa-reply mr-2" />
            {"Reply" |> str}
          </button>
        </div>
      </div>
      {showReplies
         ? <div>
             {repliesToPost
              |> Array.map(post =>
                   <TopicsShow__PostReplyShow post currentUserId users />
                 )
              |> React.array}
           </div>
         : React.null}
    </div>
  </div>;
};
