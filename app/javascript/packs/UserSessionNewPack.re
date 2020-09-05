let decodeProps = json =>
  Json.Decode.(
    json |> field("schoolName", string),
    json |> field("referer", optional(string)),
    json |> field("fqdn", string),
    json |> optional(field("oauthHost", string)),
  );

let (schoolName, referer, fqdn, oauthHost) =
  DomUtils.parseJSONTag(~id="user-session-new-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserSessionNew schoolName referer fqdn oauthHost />,
  "user-session-new",
);
