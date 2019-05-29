[@bs.config {jsx: 3}];
exception RootAttributeMissing(string);

open Webapi.Dom;

type props = {
  id: string,
  text: string,
};

let decodeProps = json =>
  Json.Decode.{
    id: json |> field("id", string),
    text: json |> field("text", string),
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
    (~attributeName="markdown-text", ~attribute="data-json-props", ()) =>
  document
  |> Document.getElementsByClassName(attributeName)
  |> HtmlCollection.toArray
  |> Array.map(element => {
       let props = parseElement(element, attribute);
       ReactDOMRe.renderToElementWithId(
         <MarkdownBlock
           markdown={props.text}
           className="p-3 leading-normal text-sm"
         />,
         props.id,
       );
     });

parseMarkdown();