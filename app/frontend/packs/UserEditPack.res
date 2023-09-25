let decodeProps = json => {
  open Json.Decode
  (
    field("name", string, json),
    field("preferredName", string, json),
    field("about", string, json),
    field("email", string, json),
    field("locale", string, json),
    field("availableLocales", array(string), json),
    field("avatarUrl", optional(string), json),
    field("dailyDigest", optional(bool), json),
    field("hasCurrentPassword", bool, json),
    field("isSchoolAdmin", bool, json),
    field("hasValidDeleteAccountToken", bool, json),
    field("schoolName", string, json),
  )
}

Psj.match("users#edit", () => {
  let (
    name,
    preferredName,
    about,
    email,
    locale,
    availableLocales,
    avatarUrl,
    dailyDigest,
    hasCurrentPassword,
    isSchoolAdmin,
    hasValidDeleteAccountToken,
    schoolName,
  ) =
    DomUtils.parseJSONTag(~id="user-edit__props", ()) |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <UserEdit
        name
        preferredName
        about
        email
        locale
        availableLocales
        avatarUrl
        dailyDigest
        hasCurrentPassword
        isSchoolAdmin
        hasValidDeleteAccountToken
        schoolName
      />,
      root,
    )
  | None => ()
  }
})
