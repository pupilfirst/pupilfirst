open StudentTopNav__Types
open Json.Decode

let decodeProps = json => (
  field("schoolName", string, json),
  field("logoOnLightBgUrl", nullable(string), json)->Js.Null.toOption,
  field("logoOnDarkBgUrl", nullable(string), json)->Js.Null.toOption,
  field("links", array(NavLink.decode), json),
  field("isLoggedIn", bool, json),
  field("currentUser", option(User.decode), json),
  field("hasNotifications", bool, json),
)

switch ReactDOM.querySelector("#student-top-nav") {
| Some(element) =>
  let (
    schoolName,
    logoOnLightBgUrl,
    logoOnDarkBgUrl,
    links,
    isLoggedIn,
    currentUser,
    hasNotifications,
  ) = decodeProps(DomUtils.parseJSONTag(~id="student-top-nav-props", ()))

  ReactDOM.render(
    <StudentTopNav
      schoolName logoOnLightBgUrl logoOnDarkBgUrl links isLoggedIn currentUser hasNotifications
    />,
    element,
  )
| None => ()
}
