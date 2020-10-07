open CourseCertificates__Types;

let decodeProps = json =>
  Json.Decode.(
    field("course", Course.decode, json),
    field("certificates", array(Certificate.decode), json),
    field("verifyImageUrl", string, json),
  );

let (course, certificates, verifyImageUrl) =
  DomUtils.parseJSONTag(~id="schools-courses-certificates__props", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CourseCertificates__Root course certificates verifyImageUrl />,
  "schools-courses-certificates__root",
);
