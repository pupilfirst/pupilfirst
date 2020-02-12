[@bs.config {jsx: 3}];

let str = React.string;

let onChange = (contentBlock, updateContentBlockCB, value) => {
  let newContentBlock = contentBlock |> ContentBlock.updateMarkdown(value);
  updateContentBlockCB(newContentBlock);
};

[@react.component]
let make = (~markdown, ~contentBlock, ~updateContentBlockCB) => {
  <MarkdownEditor2
    value=markdown
    profile=Markdown.Permissive
    maxLength=10000
    onChange={onChange(contentBlock, updateContentBlockCB)}
  />;
};
