[@bs.config {jsx: 3}];

type props = {
  token: option(string),
  authenticityToken: string,
};

let decodeProps = json =>
  Json.Decode.{
    token: json |> field("token", nullable(string)) |> Js.Null.toOption,
    authenticityToken: json |> field("authenticityToken", string),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="user-session-reset-password",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserSessionResetPassword
    token={props.token}
    authenticityToken={props.authenticityToken}
  />,
  "user-session-reset-password",
);
