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

ReactDOMRe.renderToElementWithId(<UserSessionNew schoolName fqdn oauthHost />, "user-session-new")
