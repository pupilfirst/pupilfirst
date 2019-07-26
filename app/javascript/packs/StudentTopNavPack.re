[@bs.config {jsx: 3}];

open StudentTopNav__Types;

type props = {
  schoolName: string,
  logoUrl: option(string),
  links: list(NavLink.t),
  authenticityToken: string,
  isLoggedIn: bool,
};

let decodeProps = json =>
  Json.Decode.{
    schoolName: json |> field("schoolName", string),
    logoUrl: json |> field("logoUrl", nullable(string)) |> Js.Null.toOption,
    links: json |> field("links", list(NavLink.decode)),
    authenticityToken: json |> field("authenticityToken", string),
    isLoggedIn: json |> field("isLoggedIn", bool),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="student-top-nav",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <StudentTopNav
    schoolName={props.schoolName}
    logoUrl={props.logoUrl}
    links={props.links}
    authenticityToken={props.authenticityToken}
    isLoggedIn={props.isLoggedIn}
  />,
  "student-top-nav",
);
