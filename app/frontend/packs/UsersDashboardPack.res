open UsersDashboard__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("currentSchoolAdmin", bool),
    json |> field("courses", array(Course.decode)),
    json |> field("communities", array(Community.decode)),
    json |> field("showUserEdit", bool),
    json |> field("userName", string),
    json |> field("preferredName", nullable(string)) |> Js.Null.toOption,
    json |> field("userTitle", string),
    json |> optional(field("avatarUrl", string)),
    json |> field("issuedCertificates", array(IssuedCertificate.decode)),
    json |> field("standingEnabled", bool),
    json |> field("currentStandingName", string),
    json |> field("currentStandingColor", string),
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
    standingEnabled,
    currentStandingName,
    currentStandingColor,
  ) =
    DomUtils.parseJSONTag(~id="users-dashboard-data", ()) |> decodeProps

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
        standingEnabled
        currentStandingName
        currentStandingColor
      />,
      element,
    )
  | None => ()
  }
})
