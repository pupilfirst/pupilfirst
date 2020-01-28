[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

let onChange = (contentBlock, updateContentBlockCB, event) => {
  let value = ReactEvent.Form.target(event)##value;
  let newContentBlock = contentBlock |> ContentBlock.updateMarkdown(value);
  updateContentBlockCB(newContentBlock);
};

[@react.component]
let make = (~markdown, ~contentBlock, ~updateContentBlockCB) => {
  <MarkdownEditor2
    value=markdown
    onChange={onChange(contentBlock, updateContentBlockCB)}
  />;
};
