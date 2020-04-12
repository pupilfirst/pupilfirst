open TopicsShow__Types;

let str = React.string;

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

[@react.component]
let make = (~postLikes, ~currentUserId) => {
  let liked = currentUserId |> Like.currentUserLiked(postLikes);
  let (saving, setSaving) = React.useState(() => false);

  <div className="text-center mr-1 md:mr-2">
    <div
      className="cursor-pointer"
      title={(liked ? "Unlike" : "Like") ++ " Answer"}
      onClick={_ => ()}>
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
