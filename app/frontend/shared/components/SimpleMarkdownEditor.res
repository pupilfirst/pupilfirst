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
    "textareaId": option(field("textareaId", string), props),
    "maxLength": option(field("maxLength", int), props),
    "placeholder": option(field("placeholder", string), props),
    "tabIndex": option(field("tabIndex", int), props),
    "textAreaName": option(field("textAreaName", string), props),
    "fileUpload": option(field("fileUpload", bool), props),
    "disabled": option(field("disabled", bool), props),
    "dynamicHeight": option(field("dynamicHeight", bool), props),
    "defaultMode": Some(MarkdownEditor.Windowed(#Editor)),
  })
}
