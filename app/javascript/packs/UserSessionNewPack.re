let decodeProps = json =>
  Json.Decode.(
    json |> field("schoolName", string),
    json |> field("authenticityToken", string),
    json |> field("fqdn", string),
    json |> optional(field("oauthHost", string)),
  );

let (schoolName, authenticityToken, fqdn, oauthHost) =
  DomUtils.parseJSONTag(~id="user-session-new-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserSessionNew schoolName authenticityToken fqdn oauthHost />,
  "user-session-new",
);
