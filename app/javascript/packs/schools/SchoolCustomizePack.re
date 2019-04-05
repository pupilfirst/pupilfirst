type props = {authenticityToken: string};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
  };

let props = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolCustomize authenticityToken={props.authenticityToken} />,
  "react-root",
);