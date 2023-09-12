type props = {
  token: string,
  authenticityToken: string,
  name: string,
  email: string,
  schoolName: string,
}

let decodeProps = json => {
  open Json.Decode
  {
    token: field("token", string, json),
    authenticityToken: field("authenticityToken", string, json),
    name: field("name", string, json),
    email: field("email", string, json),
    schoolName: field("schoolName", string, json),
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
      <UserSessionResetPassword
        token=props.token
        authenticityToken=props.authenticityToken
        name=props.name
        email=props.email
        schoolName=props.schoolName
      />,
      element,
    )
  | None => ()
  }
})
