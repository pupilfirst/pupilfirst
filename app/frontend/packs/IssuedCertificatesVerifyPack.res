let decodeProps = json => {
  open Json.Decode
  (
    json |> field("issuedCertificate", IssuedCertificate.decode),
    json |> field("verifyImageUrl", string),
    json |> field("currentUser", bool),
  )
}

Psj.match("issued_certificates#verify", () => {
  let (issuedCertificate, verifyImageUrl, currentUser) = DomUtils.parseJSONTag() |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(<VerifyCertificate__Root issuedCertificate verifyImageUrl currentUser />, root)
  | None => ()
  }
})
