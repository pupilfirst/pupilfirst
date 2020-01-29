[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

let onChange = (contentBlock, updateContentBlockCB, value) => {
  let newContentBlock = contentBlock |> ContentBlock.updateMarkdown(value);
  updateContentBlockCB(newContentBlock);
};

[@react.component]
let make = (~markdown, ~contentBlock, ~updateContentBlockCB) => {
  <MarkdownEditor2
    value=markdown
    profile=Markdown.Permissive
    defaultMode={MarkdownEditor2.Windowed(`Preview)}
    maxLength=10000
    onChange={onChange(contentBlock, updateContentBlockCB)}
  />;
};
