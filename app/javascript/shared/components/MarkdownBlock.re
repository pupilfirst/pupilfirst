[@bs.config {jsx: 3}];
[%bs.raw {|require("./MarkdownBlock.css")|}];

let str = React.string;

let randomId = () => {
  let randomComponent =
    Js.Math.random() |> Js.Float.toString |> Js.String.substr(~from=2);
  "markdown-block-" ++ randomComponent;
};

[@react.component]
let make = (~markdown, ~className) => {
  let id = randomId();

  React.useEffect1(
    () => {
      PrismJs.highlightAllUnder(id);
      None;
    },
    [|markdown|],
  );

  <div
    className={"markdown-block " ++ className}
    id
    dangerouslySetInnerHTML={"__html": markdown |> Markdown.parse}
  />;
};