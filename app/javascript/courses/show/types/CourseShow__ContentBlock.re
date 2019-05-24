exception UnexpectedBlockType(string);

type markdown = string;
type url = string;
type title = string;
type caption = string;
type embedCode = string;

type blockType =
  | Markdown(markdown)
  | File(url, title)
  | Image(url, caption)
  | Embed(url, embedCode);

type t = {
  id: string,
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
      File(url, title);
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

let id = t => t.id;
let blockType = t => t.blockType;
let sortIndex = t => t.sortIndex;