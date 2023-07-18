open CoachesSchoolIndex__Types

type props = {
  coaches: array<Coach.t>,
  authenticityToken: string,
}

let decodeProps = json => {
  open Json.Decode
  {
    coaches: json |> field("coaches", array(Coach.decode)),
    authenticityToken: json |> field("authenticityToken", string),
  }
}

Psj.match("schools/faculty#school_index", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(element) =>
    let props = DomUtils.parseJSONTag(~id="sa-coaches-panel", ()) |> decodeProps

    ReactDOM.render(
      <SA_Coaches_SchoolIndex coaches=props.coaches authenticityToken=props.authenticityToken />,
      element,
    )
  | None => ()
  }
})
