let decodeProps = json => {
  open Json.Decode
  json |> field("token", string)
}

Psj.match("users#delete_account", () => {
  let token = DomUtils.parseJSONTag(~id="user-delete-account__props", ()) |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) => ReactDOM.render(<UsersDeleteAccount token />, root)
  | None => ()
  }
})
