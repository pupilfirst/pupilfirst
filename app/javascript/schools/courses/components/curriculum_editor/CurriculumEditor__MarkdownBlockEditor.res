let str = React.string

let onChange = (contentBlock, updateContentBlockCB, value) => {
  let newContentBlock = contentBlock |> ContentBlock.updateMarkdown(value)
  updateContentBlockCB(newContentBlock)
}

@react.component
let make = (
  ~markdown,
  ~markdownCurriculumEditorMaxLength,
  ~contentBlock,
  ~updateContentBlockCB,
) => {
  <MarkdownEditor
    value=markdown
    profile=Markdown.Permissive
    maxLength=markdownCurriculumEditorMaxLength
    onChange={onChange(contentBlock, updateContentBlockCB)}
    dynamicHeight=true
  />
}
