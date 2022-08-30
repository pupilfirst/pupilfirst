type rec t = {
  id: id,
  body: string,
  creatorId: option<string>,
  editorId: option<string>,
  postNumber: int,
  createdAt: Js.Date.t,
  editedAt: option<Js.Date.t>,
  totalLikes: int,
  likedByUser: bool,
  replies: array<string>,
  solution: bool,
}
and id = string

let id = t => t.id

let creatorId = t => t.creatorId

let editorId = t => t.editorId

let body = t => t.body

let replies = t => t.replies

let createdAt = t => t.createdAt

let editedAt = t => t.editedAt

let likedByUser = t => t.likedByUser

let postNumber = t => t.postNumber

let totalLikes = t => t.totalLikes

let solution = t => t.solution

let user = (users, t) =>
  t.creatorId->Belt.Option.map(creatorId =>
    users |> ArrayUtils.unsafeFind(
      user => User.id(user) == creatorId,
      "Unable to user with id: " ++ (creatorId ++ " in TopicsShow__Post"),
    )
  )

let sort = posts => posts |> ArrayUtils.copyAndSort((x, y) => x.postNumber - y.postNumber)

let repliesToPost = (posts, post) =>
  posts |> Js.Array.filter(p => post.replies |> Array.mem(p.id)) |> sort

let addReply = (newReplyId, t) => {
  ...t,
  replies: t.replies |> Array.append([newReplyId]),
}

let addLike = t => {
  ...t,
  totalLikes: t.totalLikes + 1,
  likedByUser: true,
}

let removeLike = t => {
  ...t,
  likedByUser: false,
  totalLikes: t.totalLikes - 1,
}

let markAsSolution = (replyId, replies) =>
  replies |> Js.Array.map(reply =>
    reply.id == replyId ? {...reply, solution: true} : {...reply, solution: false}
  )

let unmarkSolution = replies => replies |> Js.Array.map(reply => {...reply, solution: false})

let find = (postId, posts) =>
  posts |> ArrayUtils.unsafeFind(
    post => post.id == postId,
    "Unable for find post with ID: " ++ (postId ++ " in TopicShow__Post"),
  )

let highestPostNumber = posts =>
  posts |> Js.Array.reduce(
    (maxPostNumber, t) => t.postNumber > maxPostNumber ? t.postNumber : maxPostNumber,
    0,
  )

let make = (
  ~id,
  ~body,
  ~creatorId,
  ~editorId,
  ~postNumber,
  ~createdAt,
  ~editedAt,
  ~totalLikes,
  ~likedByUser,
  ~replies,
  ~solution,
) => {
  id: id,
  body: body,
  creatorId: creatorId,
  editorId: editorId,
  postNumber: postNumber,
  createdAt: createdAt,
  editedAt: editedAt,
  totalLikes: totalLikes,
  likedByUser: likedByUser,
  replies: replies,
  solution: solution,
}

let decodeReplyId = json => json |> Json.Decode.field("id", Json.Decode.string)

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    body: json |> field("body", string),
    creatorId: json |> optional(field("creatorId", string)),
    editorId: json |> optional(field("editorId", string)),
    postNumber: json |> field("postNumber", int),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    editedAt: json |> optional(field("editedAt", DateFns.decodeISO)),
    totalLikes: json |> field("totalLikes", int),
    likedByUser: json |> field("likedByUser", bool),
    replies: json |> field("replies", array(decodeReplyId)),
    solution: json |> field("solution", bool),
  }
}
