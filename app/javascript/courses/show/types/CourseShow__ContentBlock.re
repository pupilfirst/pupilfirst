exception UnexpectedBlockType(string);

type blockType =
  | Markdown
  | File
  | Image
  | Embed;

type t = {
  id: string,
  blockType,
  content: string,
  sortIndex: int,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    blockType:
      switch (json |> field("blockType", string)) {
      | "markdown" => Markdown
      | "file" => File
      | "image" => Image
      | "embed" => Embed
      | unknownBlockType => raise(UnexpectedBlockType(unknownBlockType))
      },
    content: json |> field("content", string),
    sortIndex: json |> field("sortIndex", int),
  };