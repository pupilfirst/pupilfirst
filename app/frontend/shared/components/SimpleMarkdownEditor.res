@react.component
let make = (
  ~value,
  ~profile,
  ~textareaId=?,
  ~maxLength=1000,
  ~defaultMode=MarkdownEditor.Windowed(#Editor),
  ~placeholder=?,
  ~tabIndex=?,
  ~textAreaName=?,
  ~fileUpload=true,
  ~disabled=false,
  ~dynamicHeight=false,
) => {
  let (state, setState) = React.useState(_ => value)

  <MarkdownEditor
    value=state
    onChange={value => {
      setState(_ => value)
    }}
    profile
    ?textareaId
    maxLength
    defaultMode
    ?placeholder
    ?tabIndex
    ?textAreaName
    fileUpload
    disabled
    dynamicHeight
  />
}

let makeFromJson = props => {
  open Json.Decode

  let profileAsString = field("profile", string, props)
  let profile = switch profileAsString {
  | "Permissive" => Markdown.Permissive
  | "AreaOfText" => AreaOfText
  | _ => AreaOfText
  }

  make({
    "profile": profile,
    "value": field("value", string, props),
    "textareaId": optional(field("textareaId", string), props),
    "maxLength": optional(field("maxLength", int), props),
    "placeholder": optional(field("placeholder", string), props),
    "tabIndex": optional(field("tabIndex", int), props),
    "textAreaName": optional(field("textAreaName", string), props),
    "fileUpload": optional(field("fileUpload", bool), props),
    "disabled": optional(field("disabled", bool), props),
    "dynamicHeight": optional(field("dynamicHeight", bool), props),
    "defaultMode": Some(MarkdownEditor.Windowed(#Editor)),
  })
}
