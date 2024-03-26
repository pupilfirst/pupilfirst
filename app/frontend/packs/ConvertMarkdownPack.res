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
    markdown: json |> field("markdown", string),
    profile: json |> field("profile", string),
  }
}

let parseElement = (element, attribute) =>
  switch element -> Element.getAttribute(attribute) {
  | Some(props) => props
  | None => raise(RootAttributeMissing(attribute))
  }
  |> Json.parseOrRaise
  |> decodeProps

let profileType = profile =>
  switch profile {
  | "permissive" => Markdown.Permissive
  | "areaOfText" => Markdown.AreaOfText
  | profile => raise(InvalidProfile(profile))
  }

let parseMarkdown = (~attributeName="convert-markdown", ~attribute="data-json-props", ()) =>
  document
  -> Document.getElementsByClassName(attributeName)
  |> HtmlCollection.toArray
  |> Array.map(element => {
    let props = parseElement(element, attribute)
    element |> ReactDOM.render(
      <MarkdownBlock
        markdown=props.markdown
        className="leading-normal text-sm"
        profile={profileType(props.profile)}
      />,
    )
  })

parseMarkdown()->ignore
