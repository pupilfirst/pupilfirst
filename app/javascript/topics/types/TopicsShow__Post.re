type t = {
  id,
  body: string,
  creatorId: string,
  editorId: option(string),
  postNumber: int,
  createdAt: Js.Date.t,
  updatedAt: Js.Date.t,
  postLikes: array(TopicsShow__Like.t),
  replies: array(string),
  solution: bool,
}
and id = string;

let body = t => t.body;

let replies = t => t.replies;

let createdAt = t => t.createdAt;

let postLikes = t => t.postLikes;

let postNumber = t => t.postNumber;

let solution = t => t.solution;

let user = (users, t) => {
  users
  |> ArrayUtils.unsafeFind(
       user => User.id(user) == t.creatorId,
       "Unable to user with id: " ++ t.creatorId ++ " in TopicsShow__Post",
     );
};

let sort = posts => {
  posts |> ArrayUtils.copyAndSort((x, y) => x.postNumber - y.postNumber);
};

let repliesToPost = (posts, post) => {
  posts |> Js.Array.filter(p => post.replies |> Array.mem(p.id)) |> sort;
};

let addReply = (newReplyId, t) => {
  {...t, replies: t.replies |> Array.append([|newReplyId|])};
};

let addLike = (like, t) => {
  {...t, postLikes: t.postLikes |> Array.append([|like|])};
};

let removeLike = (likeId, t) => {
  let postLikes =
    t.postLikes
    |> Js.Array.filter(like => TopicsShow__Like.id(like) != likeId);
  {...t, postLikes};
};

let find = (postId, posts) => {
  posts
  |> ArrayUtils.unsafeFind(
       post => post.id == postId,
       "Unable for find post with ID: " ++ postId ++ " in TopicShow__Post",
     );
};

let highestPostNumber = posts => {
  posts |> ArrayUtils.isEmpty
    ? 0 : (posts |> sort |> Array.to_list |> List.rev |> List.hd).postNumber;
};

let make =
    (
      id,
      body,
      creatorId,
      editorId,
      postNumber,
      createdAt,
      updatedAt,
      postLikes,
      replies,
      solution,
    ) => {
  id,
  body,
  creatorId,
  editorId,
  postNumber,
  createdAt,
  updatedAt,
  postLikes,
  replies,
  solution,
};

let mainThread = (firstPost, replies) => {
  let replyPostIds =
    Array.append(replies, [|firstPost|])
    |> Array.map(post => post.replies |> Array.to_list)
    |> Js.Array.filter(reply => reply |> ListUtils.isNotEmpty)
    |> Array.to_list
    |> List.flatten
    |> Array.of_list;
  replies
  |> Js.Array.filter(post => !(replyPostIds |> Array.mem(post.id)))
  |> sort;
};

let id = t => t.id;

let creatorId = t => t.creatorId;

let decodeReplyId = json =>
  json |> Json.Decode.field("id", Json.Decode.string);

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    body: json |> field("body", string),
    creatorId: json |> field("creatorId", string),
    editorId: json |> optional(field("editorId", string)),
    postNumber: json |> field("postNumber", int),
    createdAt: json |> field("createdAt", string) |> DateFns.parseString,
    updatedAt: json |> field("updatedAt", string) |> DateFns.parseString,
    postLikes: json |> field("postLikes", array(TopicsShow__Like.decode)),
    replies: json |> field("replies", array(decodeReplyId)),
    solution: json |> field("solution", bool),
  };
