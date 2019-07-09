type t = {
  id: string,
  value: string,
  commentableId: string,
  commentableType: string,
  creatorId: string,
  archived: bool,
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    value: json |> field("value", string),
    creatorId: json |> field("creatorId", string),
    commentableId: json |> field("commentableId", string),
    commentableType: json |> field("commentableType", string),
    archived: json |> field("archived", bool),
    createdAt: json |> field("createdAt", string),
  };

let commentableType = t => t.commentableType;

let commentableId = t => t.commentableId;

let creatorId = t => t.creatorId;

let value = t => t.value;

let id = t => t.id;

let archived = t => t.archived;

let createdAt = t => t.createdAt;
let commentsForQuestion = comments =>
  comments |> List.filter(comment => comment.commentableType == "Question");

let commentsForAnswer = (answerId, comments) =>
  comments
  |> List.filter(comment => comment.commentableType == "Answer")
  |> List.filter(comment => comment.commentableId == answerId);

let addComment = (comments, comment) =>
  comments |> List.rev |> List.append([comment]) |> List.rev;

let findComment = (id, comments) =>
  comments |> List.filter(comment => comment.id == id) |> List.hd;

let updateComment = (comments, newComment) =>
  comments
  |> List.map(comment => comment.id == newComment.id ? newComment : comment);

let delete = (id, comments) => comments |> List.filter(c => c.id != id);

let create =
    (
      id,
      value,
      creatorId,
      commentableId,
      commentableType,
      archived,
      createdAt,
    ) => {
  id,
  value,
  creatorId,
  commentableId,
  commentableType,
  archived,
  createdAt,
};

let sort = comments =>
  comments
  |> List.sort((c1, c2) =>
       (c1.id |> int_of_string) - (c2.id |> int_of_string)
     );
