let decodeProps = json => {
  open Json.Decode
  (
    field("fullname", string, json),
    field("preferredName", string, json),
    field("about", string, json),
    field("locale", string, json),
    field("availableLocales", array(string), json),
    field("avatarUrl", optional(string), json),
    field("dailyDigest", optional(bool), json),
    field("hasCurrentPassword", bool, json),
    field("isSchoolAdmin", bool, json),
    field("hasValidDeleteAccountToken", bool, json),
  )
}

Psj.match("users#edit", () => {
  let (
    fullname,
    preferredName,
    about,
    locale,
    availableLocales,
    avatarUrl,
    dailyDigest,
    hasCurrentPassword,
    isSchoolAdmin,
    hasValidDeleteAccountToken,
  ) =
    DomUtils.parseJSONTag(~id="user-edit__props", ()) |> decodeProps
  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <UserEdit
        fullname
        preferredName
        about
        locale
        availableLocales
        avatarUrl
        dailyDigest
        hasCurrentPassword
        isSchoolAdmin
        hasValidDeleteAccountToken
      />,
      root,
    )
  | None => ()
  }
})
