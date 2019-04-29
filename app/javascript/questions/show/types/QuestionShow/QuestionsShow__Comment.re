type t = {
  id: int,
  value: string,
  userId: int,
  commentableId: int,
  commentableType: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    value: json |> field("value", string),
    userId: json |> field("userId", int),
    commentableId: json |> field("commentableId", int),
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