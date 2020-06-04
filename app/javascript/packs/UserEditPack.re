let decodeProps = json =>
  Json.Decode.(
    json |> field("name", string),
    json |> field("about", string),
    json |> field("avatarUrl", optional(string)),
    json |> field("dailyDigest", optional(bool)),
    json |> field("currentUserId", string),
    json |> field("hasCurrentPassword", bool),
  );

let (name, about, avatarUrl, dailyDigest, currentUserId, hasCurrentPassword) =
  DomUtils.parseJSONTag(~id="user-edit__props", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserEdit
    currentUserId
    name
    about
    avatarUrl
    dailyDigest
    hasCurrentPassword
  />,
  "react-root",
);
