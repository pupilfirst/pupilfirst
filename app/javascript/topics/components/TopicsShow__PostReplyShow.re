open TopicsShow__Types;

let str = React.string;
[%bs.raw {|require("./TopicsShow__PostReplyShow.css")|}];

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

let navigateToPost = postId => {
  let elementId = "post-show-" ++ postId;
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
let make = (~post, ~users) => {
  let user =
    users
    |> ArrayUtils.unsafeFind(
         user => Post.creatorId(post) == User.id(user),
         "Unable to find user with ID: "
         ++ Post.creatorId(post)
         ++ " in TopicsShow__PostReplyShow",
       );
  <div
    className="topics-post-reply-show__replies flex flex-col border bg-gray-100 rounded-lg mb-2 p-4">
    <div className="flex justify-between">
      <div className="flex items-center">
        {avatar(~size=("6", "7"), user |> User.avatarUrl, user |> User.name)}
        <span className="text-xs font-semibold ml-2">
          {user |> User.name |> str}
        </span>
      </div>
      <div
        onClick={_ => navigateToPost(post |> Post.id)}
        className="flex-shrink-0 flex items-center justify-center w-7 h-7 rounded leading-tight border bg-gray-100 text-gray-700 cursor-pointer hover:bg-gray-300">
        <i className="fas fa-angle-double-down" />
      </div>
    </div>
    <div className="text-sm ml-9"> {post |> Post.body |> str} </div>
  </div>;
};