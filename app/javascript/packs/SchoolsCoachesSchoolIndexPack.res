open CoachesSchoolIndex__Types

type props = {
  coaches: list<Coach.t>,
  authenticityToken: string,
}

let decodeProps = json => {
  open Json.Decode
  {
    coaches: json |> field("coaches", list(Coach.decode)),
    authenticityToken: json |> field("authenticityToken", string),
  }
}

let props =
  DomUtils.parseJSONAttribute(~id="sa-coaches-panel", ~attribute="data-props", ()) |> decodeProps

switch ReactDOM.querySelector("#sa-coaches-panel") {
| Some(element) =>
  ReactDOM.render(
    <SA_Coaches_SchoolIndex coaches=props.coaches authenticityToken=props.authenticityToken />,
    element,
  )
| None => ()
}
