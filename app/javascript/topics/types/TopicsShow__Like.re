type t = {
  id: string,
  userId: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    userId: json |> field("userId", string),
  };

let id = t => t.id;

let addLike = (like, likes) => likes |> List.append([like]);

let removeLike = (id, likes) => likes |> List.filter(like => like.id != id);

let currentUserLiked = (likes, currentUserId) => {
  likes
  |> Js.Array.filter(like => like.userId == currentUserId)
  |> ArrayUtils.isNotEmpty;
};

let findUserLike = (likes, currentUserId) => {
  likes
  |> ArrayUtils.unsafeFind(
       like => like.userId == currentUserId,
       "Failed to find like with userId: "
       ++ currentUserId
       ++ " in TopicsShow__Like",
     );
};

let create = (id, userId) => {id, userId};
