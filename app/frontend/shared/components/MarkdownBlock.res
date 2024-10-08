%%raw(`import "./MarkdownBlock.css"`)

let randomId = () => {
  let randomComponent = Js.String.substr(~from=2, Js.Float.toString(Js.Math.random()))
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
  switch JsonUtils.parse(props) {
  | Object(json) => {
      let markdown = switch json->Dict.get("markdown") {
      | Some(String(markdown)) => markdown
      | _ => raise(JsonUtils.DecodeError("Failed to parse markdown from JSON in MarkdownBlock"))
      }

      let className = switch json->Dict.get("className") {
      | Some(String(className)) => Some(className)
      | Some(JsonUtils.Null) => None
      | _ => raise(JsonUtils.DecodeError("Failed to parse className from JSON in MarkdownBlock"))
      }

      make({
        markdown,
        ?className,
        profile: Markdown.Permissive,
      })
    }
  | _ => raise(JsonUtils.DecodeError("Failed to parse JSON in MarkdownBlock"))
  }
}
