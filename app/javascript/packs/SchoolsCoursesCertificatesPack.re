open CourseCertificates__Types;

let decodeProps = json =>
  Json.Decode.(json |> field("course", Course.decode));

let course =
  DomUtils.parseJSONTag(~id="schools-courses-certificates__props", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CourseCertificates__Root course />,
  "schools-courses-certificates__root",
);
