let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("schoolName", string),
  );

let (authenticityToken, schoolName) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CourseCurriculum.Jsx2 authenticityToken schoolName />,
  "react-root",
);