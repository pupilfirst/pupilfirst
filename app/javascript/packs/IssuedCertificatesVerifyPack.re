let issuedCertificate =
  DomUtils.parseJsonTag() |> VerifyCertificate__IssuedCertificate.decode;

ReactDOMRe.renderToElementWithId(
  <VerifyCertificate__Root issuedCertificate />,
  "react-root",
);
