let decodeProps = json => {
  open Json.Decode
  (
    json |> field("schoolName", string),
    json |> field("schoolLogoPath", string),
    json |> field("schoolIconPath", string),
    json |> field("courses", list(SchoolAdminNavbar__Course.decode)),
    json |> field("isCourseAuthor", bool),
    json |> field("hasNotifications", bool),
  )
}

let (schoolName, schoolLogoPath, schoolIconPath, courses, isCourseAuthor, hasNotifications) =
  DomUtils.parseJSONAttribute(~id="school-admin-navbar__root", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(
  <SchoolAdminNavbar__Root
    schoolName schoolLogoPath schoolIconPath courses isCourseAuthor hasNotifications
  />,
  "school-admin-navbar__root",
)
