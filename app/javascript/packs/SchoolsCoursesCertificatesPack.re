open CourseCertificates__Types;

let decodeProps = json =>
  Json.Decode.(
    field("course", Course.decode, json),
    field("certificates", array(Certificate.decode), json),
  );

let (course, certificates) =
  DomUtils.parseJSONTag(~id="schools-courses-certificates__props", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CourseCertificates__Root course certificates />,
  "schools-courses-certificates__root",
);
