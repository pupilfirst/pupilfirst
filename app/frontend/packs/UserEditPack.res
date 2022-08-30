let decodeProps = json => {
  open Json.Decode
  (
    field("name", string, json),
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
    name,
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
        name
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
