let decodeProps = json => {
  open Json.Decode
  (
    json |> field("schoolName", string),
    json |> field("fqdn", string),
    json |> optional(field("oauthHost", string)),
  )
}

let (schoolName, fqdn, oauthHost) =
  DomUtils.parseJSONTag(~id="user-session-new-data", ()) |> decodeProps

switch ReactDOM.querySelector("#user-session-new") {
| Some(element) => ReactDOM.render(<UserSessionNew schoolName fqdn oauthHost />, element)
| None => ()
}
