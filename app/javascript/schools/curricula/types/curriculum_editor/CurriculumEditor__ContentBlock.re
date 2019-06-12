exception InvalidBlockType(string);

type markdown = string;
type url = string;
type fileUrl = string;
type fileName = string;
type title = string;
type caption = string;
type embedCode = string;

type blockType =
  | Markdown(markdown)
  | File(fileUrl, fileName, title)
  | Image(fileUrl, caption)
  | Embed(url, embedCode);

type t = {
  id: string,
  blockType,
  targetId: string,
  sortIndex: int,
};

let id = t => t.id;
let blockType = t => t.blockType;
let sortIndex = t => t.sortIndex;
let targetId = t => t.targetId;

let decodeMarkdownContent = json =>
  Json.Decode.(field("markdown", string, json));

let decodeFileContent = json => Json.Decode.(field("title", string, json));

let decodeEmdedContent = json => (
  Json.Decode.(field("url", string, json)),
  Json.Decode.(field("embedCode", string, json)),
);

let decodeImageContent = json => Json.Decode.(field("caption", string, json));

let decode = json => {
  open Json.Decode;

  let blockType =
    switch (json |> field("blockType", string)) {
    | "markdown" => Markdown(json |> field("content", decodeMarkdownContent))
    | "file" =>
      let title = json |> field("content", decodeFileContent);
      let fileUrl = json |> field("fileUrl", string);
      let fileName = json |> field("fileName", string);
      File(fileUrl, fileName, title);
    | "embed" =>
      let (url, embedCode) = json |> field("content", decodeEmdedContent);
      Embed(url, embedCode);
    | "image" =>
      let fileUrl = json |> field("fileUrl", string);
      let caption = json |> field("content", decodeImageContent);
      Image(fileUrl, caption);
    | invalidBlockType => raise(InvalidBlockType(invalidBlockType))
    };

  {
    id: json |> field("id", string),
    targetId: json |> field("targetId", string),
    blockType,
    sortIndex: json |> field("sortIndex", int),
  };
};