[@bs.config {jsx: 3}];

let str = React.string;

type contentType =
  | Text
  | Image
  | Embed
  | File;

type state = {
  contentType,
  sortIndex: int,
  targetId: int,
};