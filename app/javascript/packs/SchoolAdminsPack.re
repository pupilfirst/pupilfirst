[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  admins: list(SchoolAdmin.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    admins: json |> field("admins", list(SchoolAdmin.decode)),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="school-admins",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolAdmin__Editor
    authenticityToken={props.authenticityToken}
    admins={props.admins}
  />,
  "school-admins",
);
