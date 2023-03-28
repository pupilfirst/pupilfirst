%%raw(`import "./MarkdownBlock.css"`)

let randomId = () => {
  let randomComponent = Js.Math.random() |> Js.Float.toString |> Js.String.substr(~from=2)
  "markdown-block-" ++ randomComponent
}

let profileClasses = profile =>
  switch profile {
  | Markdown.Permissive => "markdown-block__permissive "
  | AreaOfText => "markdown-block__area-of-text "
  }

let markdownBlockClasses = (profile, className) => {
  let defaultClasses = "markdown-block " ++ profileClasses(profile)
  switch className {
  | Some(className) => defaultClasses ++ className
  | None => defaultClasses
  }
}

@react.component
let make = (~markdown, ~className=?, ~profile) => {
  let (id, _setId) = React.useState(() => randomId())

  React.useEffect1(() => {
    PrismJs.highlightAllUnder(id)
    None
  }, [markdown])

  <div
    className={markdownBlockClasses(profile, className)}
    id
    dangerouslySetInnerHTML={Markdown.toSafeHTML(markdown, profile)}
  />
}

let makeFromJson = props => {
  open Json.Decode

  let markdown = field("markdown", string, props)
  let className = optional(field("className", string), props)

  make({
    "markdown": markdown,
    "className": className,
    "profile": Markdown.Permissive,
  })
}
