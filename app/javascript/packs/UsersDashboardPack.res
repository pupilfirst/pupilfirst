open UsersDashboard__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("currentSchoolAdmin", bool),
    json |> field("courses", array(Course.decode)),
    json |> field("communities", array(Community.decode)),
    json |> field("showUserEdit", bool),
    json |> field("userName", string),
    json |> field("userTitle", string),
    json |> optional(field("avatarUrl", string)),
    json |> field("issuedCertificates", array(IssuedCertificate.decode)),
  )
}

let (
  currentSchoolAdmin,
  courses,
  communities,
  showUserEdit,
  userName,
  userTitle,
  avatarUrl,
  issuedCertificates,
) =
  DomUtils.parseJSONTag(~id="users-dashboard-data", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(
  <UsersDashboard__Root
    currentSchoolAdmin
    courses
    communities
    showUserEdit
    userName
    userTitle
    avatarUrl
    issuedCertificates
  />,
  "users-dashboard",
)
