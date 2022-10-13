type props = {
  currentSchoolAdminId: string,
  admins: array<SchoolAdmin.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    currentSchoolAdminId: json |> field("currentSchoolAdminId", string),
    admins: json |> field("admins", array(SchoolAdmin.decode)),
  }
}

Psj.match("schools#admins", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(element) =>
    let props = DomUtils.parseJSONTag(~id="school-admins-data", ()) |> decodeProps

    ReactDOM.render(
      <SchoolAdmins__Editor currentSchoolAdminId=props.currentSchoolAdminId admins=props.admins />,
      element,
    )
  | None => ()
  }
})
