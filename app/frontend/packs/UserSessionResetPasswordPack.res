type props = {
  token: string,
  authenticityToken: string,
}

let decodeProps = json => {
  open Json.Decode
  {
    token: json |> field("token", string),
    authenticityToken: json |> field("authenticityToken", string),
  }
}

Psj.match("users/sessions#reset_password", () => {
  let props =
    DomUtils.parseJSONAttribute(
      ~id="user-session-reset-password",
      ~attribute="data-json-props",
      (),
    ) |> decodeProps

  switch ReactDOM.querySelector("#user-session-reset-password") {
  | Some(element) =>
    ReactDOM.render(
      <UserSessionResetPassword token=props.token authenticityToken=props.authenticityToken />,
      element,
    )
  | None => ()
  }
})
