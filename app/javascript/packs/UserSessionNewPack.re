let decodeProps = json =>
  Json.Decode.(
    json |> field("schoolName", string),
    json |> field("fqdn", string),
    json |> optional(field("oauthHost", string)),
    json |> field("availableOauthProviders", array(string)),
  );

let (schoolName, fqdn, oauthHost, availableOauthProviders) =
  DomUtils.parseJSONTag(~id="user-session-new-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserSessionNew schoolName fqdn oauthHost availableOauthProviders />,
  "user-session-new",
);
