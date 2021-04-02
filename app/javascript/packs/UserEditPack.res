let decodeProps = json => {
  open Json.Decode
  (
    json |> field("name", string),
    json |> field("about", string),
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
      name about avatarUrl dailyDigest hasCurrentPassword isSchoolAdmin hasValidDeleteAccountToken
    />,
    root,
  )
| None => ()
}
