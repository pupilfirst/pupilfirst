let decodeProps = json => {
  open Json.Decode
  (
    field("schoolName", string, json),
    field("schoolLogoPath", string, json),
    field("schoolIconPath", string, json),
    field("courses", array(CourseInfo.decode), json),
    field("isCourseAuthor", bool, json),
    field("hasNotifications", bool, json),
  )
}

let (schoolName, schoolLogoPath, schoolIconPath, courses, isCourseAuthor, hasNotifications) =
  DomUtils.parseJSONAttribute(~id="school-admin-navbar__root", ()) |> decodeProps

switch ReactDOM.querySelector("#school-admin-navbar__root") {
| Some(root) =>
  ReactDOM.render(
    <SchoolAdminNavbar__Root
      schoolName schoolLogoPath schoolIconPath courses isCourseAuthor hasNotifications
    />,
    root,
  )
| None => ()
}
