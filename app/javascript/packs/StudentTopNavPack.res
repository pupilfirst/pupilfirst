open StudentTopNav__Types

type props = {
  schoolName: string,
  logoUrl: option<string>,
  links: list<NavLink.t>,
  isLoggedIn: bool,
  currentUser: option<User.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    schoolName: json |> field("schoolName", string),
    logoUrl: json |> field("logoUrl", nullable(string)) |> Js.Null.toOption,
    links: json |> field("links", list(NavLink.decode)),
    isLoggedIn: json |> field("isLoggedIn", bool),
    currentUser: json |> field("currentUser", optional(User.decode)),
  }
}

let props = DomUtils.parseJSONTag(~id="student-top-nav-props", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(
  <StudentTopNav
    schoolName={props.schoolName}
    logoUrl={props.logoUrl}
    links={props.links}
    isLoggedIn={props.isLoggedIn}
    currentUser={props.currentUser}
  />,
  "student-top-nav",
)
