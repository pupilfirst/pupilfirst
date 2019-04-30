type t = {
  id: string,
  value: string,
  userId: string,
  commentableId: string,
  commentableType: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    value: json |> field("value", string),
    userId: json |> field("userId", string),
    commentableId: json |> field("commentableId", string),
    commentableType: json |> field("commentableType", string),
  };

let commentableType = t => t.commentableType;

let commentableId = t => t.commentableId;

let userId = t => t.userId;

let value = t => t.value;

let id = t => t.id;

let commentsForQuestion = comments =>
  comments |> List.filter(comment => comment.commentableType == "Question");

let commentsForAnswer = (answerId, comments) =>
  comments
  |> List.filter(comment => comment.commentableType == "Answer")
  |> List.filter(comment => comment.commentableId == answerId);

let addComment = (comments, comment) =>
  comments |> List.rev |> List.append([comment]) |> List.rev;

let create = (id, value, userId, commentableId, commentableType) => {
  id,
  value,
  userId,
  commentableId,
  commentableType,
};