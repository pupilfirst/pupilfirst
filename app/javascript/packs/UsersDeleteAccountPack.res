let decodeProps = json => {
  open Json.Decode
  json |> field("token", string)
}

let token = DomUtils.parseJSONTag(~id="user-delete-account__props", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(<UsersDeleteAccount token />, "react-root")
