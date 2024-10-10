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
    ArrayUtils.unsafeFind(
      user => User.id(user) == creatorId,
      "Unable to user with id: " ++ (creatorId ++ " in TopicsShow__Post"),
      users,
    )
  )

let sort = posts => ArrayUtils.copyAndSort((x, y) => x.postNumber - y.postNumber, posts)

let repliesToPost = (posts, post) =>
  sort(Js.Array.filter(p => Array.mem(p.id, post.replies), posts))

let addReply = (newReplyId, t) => {
  ...t,
  replies: Array.append([newReplyId], t.replies),
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
  Js.Array.map(
    reply => reply.id == replyId ? {...reply, solution: true} : {...reply, solution: false},
    replies,
  )

let unmarkSolution = replies => Js.Array.map(reply => {...reply, solution: false}, replies)

let find = (postId, posts) =>
  ArrayUtils.unsafeFind(
    post => post.id == postId,
    "Unable for find post with ID: " ++ (postId ++ " in TopicShow__Post"),
    posts,
  )

let highestPostNumber = posts =>
  Js.Array.reduce(
    (maxPostNumber, t) => t.postNumber > maxPostNumber ? t.postNumber : maxPostNumber,
    0,
    posts,
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
  id,
  body,
  creatorId,
  editorId,
  postNumber,
  createdAt,
  editedAt,
  totalLikes,
  likedByUser,
  replies,
  solution,
}

let decodeReplyId = json => Json.Decode.field("id", Json.Decode.string, json)

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    body: field("body", string, json),
    creatorId: option(field("creatorId", string), json),
    editorId: option(field("editorId", string), json),
    postNumber: field("postNumber", int, json),
    createdAt: field("createdAt", DateFns.decodeISO, json),
    editedAt: option(field("editedAt", DateFns.decodeISO), json),
    totalLikes: field("totalLikes", int, json),
    likedByUser: field("likedByUser", bool, json),
    replies: field("replies", array(decodeReplyId), json),
    solution: field("solution", bool, json),
  }
}
