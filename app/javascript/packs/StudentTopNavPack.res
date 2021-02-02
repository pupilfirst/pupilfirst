open StudentTopNav__Types
open Json.Decode

let decodeProps = json => (
  json |> field("schoolName", string),
  json |> field("logoUrl", nullable(string)) |> Js.Null.toOption,
  json |> field("links", array(NavLink.decode)),
  json |> field("isLoggedIn", bool),
  json |> field("currentUser", optional(User.decode)),
  json |> field("hasNotifications", bool),
)

let (schoolName, logoUrl, links, isLoggedIn, currentUser, hasNotifications) =
  DomUtils.parseJSONTag(~id="student-top-nav-props", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(
  <StudentTopNav schoolName logoUrl links isLoggedIn currentUser hasNotifications />,
  "student-top-nav",
)
