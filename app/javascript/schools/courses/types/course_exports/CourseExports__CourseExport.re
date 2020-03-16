type id = string;

type file = {
  path: string,
  createdAt: string,
};

type t = {
  id,
  createdAt: string,
  file: option(file),
  tags: array(string),
  reviewedOnly: bool,
};

let id = t => t.id;
let createdAt = (t: t) => t.createdAt;
let file = t => t.file;
let tags = t => t.tags;
let reviewedOnly = t => t.reviewedOnly;
let fileCreatedAt = (file: file) => file.createdAt;
let filePath = file => file.path;

let decodeFile = json =>
  Json.Decode.{
    path: json |> field("path", string),
    createdAt: json |> field("createdAt", string),
  };

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    createdAt: json |> field("createdAt", string),
    file: json |> field("file", nullable(decodeFile)) |> Js.Null.toOption,
    tags: json |> field("tags", array(string)),
    reviewedOnly: json |> field("reviewedOnly", bool),
  };

let make = (~id, ~createdAt, ~tags, ~reviewedOnly) => {
  id,
  createdAt,
  tags,
  reviewedOnly,
  file: None,
};
