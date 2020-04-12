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

[@react.component]
let make = (~post, ~currentUserId, ~users) => {
  let user =
    users
    |> ArrayUtils.unsafeFind(
         user => Post.creatorId(post) == User.id(user),
         "Unable to find user with ID: "
         ++ Post.creatorId(post)
         ++ " in TopicsShow__PostReplyShow",
       );
  <div
    className="flex flex-col border border-gray-200 bg-gray-300 rounded-lg my-2 mx-2 px-2 py-2">
    <div className="flex items-center">
      {avatar(~size=("6", "8"), user |> User.avatarUrl, user |> User.name)}
      <span className="text-xs font-semibold ml-2">
        {user |> User.name |> str}
      </span>
    </div>
    <div className="text-sm"> {post |> Post.body |> str} </div>
  </div>;
};
