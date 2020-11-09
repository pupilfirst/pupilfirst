let decodeProps = json => {
  open Json.Decode
  (
    json |> field("schoolName", string),
    json |> field("fqdn", string),
    json |> optional(field("oauthHost", string)),
<<<<<<< HEAD:app/javascript/packs/UserSessionNewPack.res
  )
}

let (schoolName, fqdn, oauthHost) =
  DomUtils.parseJSONTag(~id="user-session-new-data", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(<UserSessionNew schoolName fqdn oauthHost />, "user-session-new")
=======
    json |> field("availableOauthProviders", array(string)),
    json |> field("allowEmailSignIn", bool),
  );

let (schoolName, fqdn, oauthHost, availableOauthProviders, allowEmailSignIn) =
  DomUtils.parseJSONTag(~id="user-session-new-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserSessionNew schoolName fqdn oauthHost availableOauthProviders allowEmailSignIn />,
  "user-session-new",
);
>>>>>>> b38307314 (feat: Select federated sign-in buttons):app/javascript/packs/UserSessionNewPack.re
