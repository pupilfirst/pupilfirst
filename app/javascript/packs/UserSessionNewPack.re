[@bs.config {jsx: 3}];

type props = {
  schoolName: string,
  iconUrl: option(string),
  authenticityToken: string,
  fqdn: option(string),
  oauthHost: string
};

let decodeProps = json =>
  Json.Decode.{
    schoolName: json |> field("schoolName", string),
    iconUrl: json |> field("iconUrl", nullable(string)) |> Js.Null.toOption,
    authenticityToken: json |> field("authenticityToken", string),
    fqdn: json |> field("fqdn", nullable(string)) |> Js.Null.toOption,
    oauthHost: json |> field("oauthHost", string),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="user-session-new",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UserSessionNew
    schoolName={props.schoolName}
    iconUrl={props.iconUrl}
    authenticityToken={props.authenticityToken}
    fqdn={props.fqdn}
    oauthHost={props.oauthHost}
  />,
  "user-session-new",
);
