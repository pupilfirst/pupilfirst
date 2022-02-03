let decodeProps = json => {
  open Json.Decode
  (
    json |> field("name", string),
    json |> field("about", string),
    field("locale", string, json)->Locale.fromString,
    json |> field("avatarUrl", optional(string)),
    json |> field("dailyDigest", optional(bool)),
    json |> field("hasCurrentPassword", bool),
    json |> field("isSchoolAdmin", bool),
    json |> field("hasValidDeleteAccountToken", bool),
  )
}

let (
  name,
  about,
  locale,
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
