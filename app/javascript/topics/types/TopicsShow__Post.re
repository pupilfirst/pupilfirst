type postLike = {
  id: string,
  userId: string,
};

type t = {
  id,
  body: string,
  creatorId: string,
  editorId: option(string),
  postNumber: int,
  createdAt: Js.Date.t,
  updatedAt: Js.Date.t,
  postLikes: array(postLike),
  replies: array(string),
}
and id = string;

let decodePostLike = json =>
  Json.Decode.{
    id: json |> field("id", string),
    userId: json |> field("userId", string),
  };

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
    postLikes: json |> field("postLikes", array(decodePostLike)),
    replies: json |> field("replies", array(decodeReplyId)),
  };
