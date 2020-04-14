open TopicsShow__Types;

let str = React.string;

let avatarClasses = size => {
  let (defaultSize, mdSize) = size;
  "w-"
  ++ defaultSize
  ++ " h-"
  ++ defaultSize
  ++ " md:w-"
  ++ mdSize
  ++ " md:h-"
  ++ mdSize
  ++ " text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover";
};

let avatar = (~size=("6", "8"), avatarUrl, name) => {
  switch (avatarUrl) {
  | Some(avatarUrl) => <img className={avatarClasses(size)} src=avatarUrl />
  | None => <Avatar name className={avatarClasses(size)} />
  };
};

let optionsDropdown = toggleShowReplyEdit => {
  let selected =
    <div
      className="flex items-center justify-center w-7 h-7 rounded leading-tight border bg-gray-100 text-gray-700 cursor-pointer hover:bg-gray-300">
      <PfIcon className="if i-ellipsis-h-regular text-base" />
    </div>;
  let editPostButton =
    <button
      onClick={_ => toggleShowReplyEdit(_ => true)}
      className="flex p-2 items-center text-gray-700">
      <FaIcon classes="fas fa-edit mr-2" />
      {"Edit Reply" |> str}
    </button>;
  let deletePostButton =
    <button className="flex p-2 items-center text-gray-700">
      <FaIcon classes="fas fa-trash-alt mr-2" />
      {"Delete Reply" |> str}
    </button>;
  <Dropdown
    selected
    contents=[|editPostButton, deletePostButton|]
    right=true
  />;
};

[@react.component]
let make = (~topic, ~post, ~currentUserId, ~users) => {
  let (showReplyEdit, toggleShowReplyEdit) = React.useState(() => false);
  let user =
    users
    |> ArrayUtils.unsafeFind(
         user => Post.creatorId(post) == User.id(user),
         "Unable to find user with ID: "
         ++ Post.creatorId(post)
         ++ " in TopicsShow__PostReplyShow",
       );
  <div className="flex flex-col border bg-gray-100 rounded-lg mt-2 p-4">
    <div className="flex justify-between">
      <div className="flex items-center">
        {avatar(~size=("6", "8"), user |> User.avatarUrl, user |> User.name)}
        <span className="text-xs font-semibold ml-2">
          {user |> User.name |> str}
        </span>
      </div>
      <div className="flex-shrink-0">
        {optionsDropdown(toggleShowReplyEdit)}
      </div>
    </div>
    {showReplyEdit
       ? <TopicsShow__PostEditor
           topic
           currentUserId
           post
           handleCloseCB={() => toggleShowReplyEdit(_ => false)}
         />
       : <div className="text-sm ml-10"> {post |> Post.body |> str} </div>}
  </div>;
};
