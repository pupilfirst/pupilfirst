[@bs.config {jsx: 3}];
exception RootAttributeMissing(string);

open Webapi.Dom;

type props = {
  markdown: string,
  permissive: bool,
};

let decodeProps = json =>
  Json.Decode.{
    markdown: json |> field("markdown", string),
    permissive: json |> field("permissive", bool),
  };

let parseElement = (element, attribute) =>
  (
    switch (element |> Element.getAttribute(attribute)) {
    | Some(props) => props
    | None => raise(RootAttributeMissing(attribute))
    }
  )
  |> Json.parseOrRaise
  |> decodeProps;

let parseMarkdown =
    (~attributeName="convert-markdown", ~attribute="data-json-props", ()) =>
  document
  |> Document.getElementsByClassName(attributeName)
  |> HtmlCollection.toArray
  |> Array.map(element => {
       let props = parseElement(element, attribute);
       let profile =
         props.permissive ? Markdown.Permissive : Markdown.QuestionAndAnswer;
       element
       |> ReactDOMRe.render(
            <MarkdownBlock
              markdown={props.markdown}
              className="leading-normal text-sm"
              profile
            />,
          );
     });

parseMarkdown();
