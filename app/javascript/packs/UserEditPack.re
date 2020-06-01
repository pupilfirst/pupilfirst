let decodeProps = json =>
  Json.Decode.(
    json |> field("name", string),
    json |> field("about", string),
    json |> field("avatarUrl", optional(string)),
    json |> field("dailyDigest", bool),
    json |> field("currentUserId", string),
  );

let (name, about, avatarUrl, dailyDigest, currentUserId) =
  DomUtils.parseJSONTag(~id="user-edit__props", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserEdit currentUserId name about avatarUrl dailyDigest />,
  "react-root",
);
