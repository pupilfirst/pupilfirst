open UsersDashboard__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("currentSchoolAdmin", bool, json),
    field("courses", array(Course.decode), json),
    field("communities", array(Community.decode), json),
    field("showUserEdit", bool, json),
    field("userName", string, json),
    field("preferredName", nullable(string), json)->Js.Null.toOption,
    field("userTitle", string, json),
    optional(field("avatarUrl", string), json),
    field("issuedCertificates", array(IssuedCertificate.decode), json),
    optional(field("standing", Standing.decode), json),
  )
}

Psj.match("users#dashboard", () => {
  let (
    currentSchoolAdmin,
    courses,
    communities,
    showUserEdit,
    userName,
    preferredName,
    userTitle,
    avatarUrl,
    issuedCertificates,
    standing,
  ) =
    DomUtils.parseJSONTag(~id="users-dashboard-data", ())->decodeProps

  switch ReactDOM.querySelector("#users-dashboard") {
  | Some(element) =>
    ReactDOM.render(
      <UsersDashboard__Root
        currentSchoolAdmin
        courses
        communities
        showUserEdit
        userName
        preferredName
        userTitle
        avatarUrl
        issuedCertificates
        standing
      />,
      element,
    )
  | None => ()
  }
})
