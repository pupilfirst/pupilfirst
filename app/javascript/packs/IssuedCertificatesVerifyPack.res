let decodeProps = json => {
  open Json.Decode
  (
    json |> field("issuedCertificate", IssuedCertificate.decode),
    json |> field("verifyImageUrl", string),
    json |> field("currentUser", bool),
  )
}

let (issuedCertificate, verifyImageUrl, currentUser) = DomUtils.parseJSONTag() |> decodeProps

ReactDOMRe.renderToElementWithId(
  <VerifyCertificate__Root issuedCertificate verifyImageUrl currentUser />,
  "react-root",
)
