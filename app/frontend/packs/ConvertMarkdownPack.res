exception RootAttributeMissing(string)
exception InvalidProfile(string)

open Webapi.Dom

type props = {
  markdown: string,
  profile: string,
}

let decodeProps = json => {
  open Json.Decode
  {
    markdown: field("markdown", string, json),
    profile: field("profile", string, json),
  }
}

let parseElement = (element, attribute) =>
  decodeProps(
    Js.Json.parseExn(
      switch element->Element.getAttribute(attribute) {
      | Some(props) => props
      | None => raise(RootAttributeMissing(attribute))
      },
    ),
  )

let profileType = profile =>
  switch profile {
  | "permissive" => Markdown.Permissive
  | "areaOfText" => Markdown.AreaOfText
  | profile => raise(InvalidProfile(profile))
  }

let parseMarkdown = (~attributeName="convert-markdown", ~attribute="data-json-props", ()) =>
  Array.map(element => {
    let props = parseElement(element, attribute)
    ReactDOM.render(
      <MarkdownBlock
        markdown=props.markdown
        className="leading-normal text-sm"
        profile={profileType(props.profile)}
      />,
      element,
    )
  }, HtmlCollection.toArray(document->Document.getElementsByClassName(attributeName)))

parseMarkdown()->ignore
