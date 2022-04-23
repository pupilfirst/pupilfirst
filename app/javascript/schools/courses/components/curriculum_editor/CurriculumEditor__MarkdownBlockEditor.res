let str = React.string

let onChange = (contentBlock, updateContentBlockCB, value) => {
  let newContentBlock = contentBlock |> ContentBlock.updateMarkdown(value)
  updateContentBlockCB(newContentBlock)
}

@react.component
let make = (~markdown, ~courseAuthorMaxLength, ~contentBlock, ~updateContentBlockCB) =>
  <MarkdownEditor
    value=markdown
    profile=Markdown.Permissive
    maxLength=courseAuthorMaxLength
    onChange={onChange(contentBlock, updateContentBlockCB)}
    dynamicHeight=true
  />
