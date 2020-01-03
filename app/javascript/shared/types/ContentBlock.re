exception UnexpectedBlockType(string);
exception UpdateBlockTypeMismatch(string, string);

type markdown = string;
type url = string;
type title = string;
type caption = string;
type embedCode = string;
type filename = string;

type blockType =
  | Markdown(markdown)
  | File(url, title, filename)
  | Image(url, caption)
  | Embed(url, embedCode);

type id = string;

type t = {
  id,
  blockType,
  sortIndex: int,
};

let decodeMarkdownContent = json =>
  Json.Decode.(json |> field("markdown", string));
let decodeFileContent = json => Json.Decode.(json |> field("title", string));
let decodeImageContent = json =>
  Json.Decode.(json |> field("caption", string));
let decodeEmbedContent = json =>
  Json.Decode.(
    json |> field("url", string),
    json |> field("embedCode", string),
  );

let decode = json => {
  open Json.Decode;

  let blockType =
    switch (json |> field("blockType", string)) {
    | "markdown" => Markdown(json |> field("content", decodeMarkdownContent))
    | "file" =>
      let title = json |> field("content", decodeFileContent);
      let url = json |> field("fileUrl", string);
      let filename = json |> field("filename", string);
      File(url, title, filename);
    | "image" =>
      let caption = json |> field("content", decodeImageContent);
      let url = json |> field("fileUrl", string);
      Image(url, caption);
    | "embed" =>
      let (url, embedCode) = json |> field("content", decodeEmbedContent);
      Embed(url, embedCode);
    | unknownBlockType => raise(UnexpectedBlockType(unknownBlockType))
    };

  {
    id: json |> field("id", string),
    blockType,
    sortIndex: json |> field("sortIndex", int),
  };
};

let sort = blocks => blocks |> List.sort((x, y) => x.sortIndex - y.sortIndex);

let id = t => t.id;
let blockType = t => t.blockType;
let sortIndex = t => t.sortIndex;

let make = (id, sortIndex, blockType) => {id, sortIndex, blockType};

let makeMarkdownBlock = (~id, ~sortIndex, ~markdown) =>
  Markdown(markdown) |> make(id, sortIndex);

let makeImageBlock = (~id, ~sortIndex, ~fileUrl, ~caption) =>
  Image(fileUrl, caption) |> make(id, sortIndex);

let makeFileBlock = (~id, ~sortIndex, ~fileUrl, ~title, ~fileName) =>
  File(fileUrl, title, fileName) |> make(id, sortIndex);

let makeEmbedBlock = (~id, ~sortIndex, ~url, ~embedCode) =>
  Embed(url, embedCode) |> make(id, sortIndex);

let blockTypeToString = blockType =>
  switch (blockType) {
  | Markdown(_markdown) => "markdown"
  | File(_url, _title, _filename) => "file"
  | Image(_url, _caption) => "image"
  | Embed(_url, _embedCode) => "embed"
  };

let updateMarkdownBlock = (markdown, t) => {
  ...t,
  blockType: Markdown(markdown),
};

let updateFileBlock = (title, t) => {
  switch (t.blockType) {
  | File(url, _title, filename) => {
      ...t,
      blockType: File(url, title, filename),
    }
  | otherType =>
    raise(UpdateBlockTypeMismatch("file", otherType |> blockTypeToString))
  };
};

let updateImageBlock = (caption, t) => {
  switch (t.blockType) {
  | Image(url, _caption) => {...t, blockType: Image(url, caption)}
  | otherType =>
    raise(UpdateBlockTypeMismatch("image", otherType |> blockTypeToString))
  };
};
