exception UnexpectedBlockType(string);

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
