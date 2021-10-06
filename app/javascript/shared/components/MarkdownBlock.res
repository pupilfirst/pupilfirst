%raw(`require("./MarkdownBlock.css")`)

let randomId = () => {
  let randomComponent = Js.Math.random() |> Js.Float.toString |> Js.String.substr(~from=2)
  "markdown-block-" ++ randomComponent
}

let profileClasses = profile =>
  switch profile {
  | Markdown.QuestionAndAnswer => "markdown-block__question-and-answer "
  | Permissive => "markdown-block__permissive "
  | AreaOfText => "markdown-block__area-of-text "
  }

let markdownBlockClasses = (profile, className) => {
  let defaultClasses = "markdown-block " ++ profileClasses(profile)
  switch className {
  | Some(className) => defaultClasses ++ className
  | None => defaultClasses
  }
}

let sanitize = (html, profile) =>
  switch profile {
  | Markdown.QuestionAndAnswer
  | Permissive =>
    DOMPurify.sanitizedHTML(html)
  | AreaOfText =>
    DOMPurify.sanitizedHTMLOpt(
      html,
      {
        "ALLOWED_TAGS": ["p", "em", "strong", "del", "s", "a", "sup", "sub"],
      },
    )
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
    dangerouslySetInnerHTML={Markdown.parse(profile, markdown)->sanitize(profile)}
  />
}
