type props = {
  authenticityToken: string,
  customizations: SchoolCustomize__Customizations.t,
  schoolName: string,
  schoolAbout: option<string>,
}

let decodeProps = json => {
  open Json.Decode
  {
    authenticityToken: field("authenticityToken", string, json),
    customizations: field("customizations", SchoolCustomize__Customizations.decode, json),
    schoolName: field("schoolName", string, json),
    schoolAbout: field("schoolAbout", option(string), json),
  }
}

Psj.match("schools#customize", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(element) =>
    let props = decodeProps(DomUtils.parseJSONTag(~id="school-customize-data", ()))

    ReactDOM.render(
      <SchoolCustomize__Root
        authenticityToken=props.authenticityToken
        customizations=props.customizations
        schoolName=props.schoolName
        schoolAbout=props.schoolAbout
      />,
      element,
    )
  | None => ()
  }
})
