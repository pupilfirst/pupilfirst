exception RootElementMissing;
exception RootPropsMissing;

open Webapi.Dom;

type props = {authenticityToken: string};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsonProps =
  switch (document |> Document.getElementById("react-root")) {
  | Some(rootElement) =>
    switch (rootElement |> Element.getAttribute("data-json-props")) {
    | Some(props) => props
    | None => raise(RootPropsMissing)
    }
  | None => raise(RootElementMissing)
  };

let props = jsonProps |> Json.parseOrRaise |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolCustomize authenticityToken={props.authenticityToken} />,
  "react-root",
);