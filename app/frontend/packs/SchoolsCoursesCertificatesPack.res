open CourseCertificates__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("course", Course.decode, json),
    field("certificates", array(Certificate.decode), json),
    field("verifyImageUrl", string, json),
    field("canBeAutoIssued", bool, json),
  )
}

Psj.match("schools/courses#certificates", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(root) =>
    let (course, certificates, verifyImageUrl, canBeAutoIssued) =
      DomUtils.parseJSONTag(~id="schools-courses-certificates__props", ()) |> decodeProps

    ReactDOM.render(
      <CourseCertificates__Root course certificates verifyImageUrl canBeAutoIssued />,
      root,
    )
  | None => ()
  }
})
