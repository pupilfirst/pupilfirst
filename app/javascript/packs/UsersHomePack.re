[@bs.config {jsx: 3}];

type props = {
  currentSchoolAdmin: bool,
  courses: array(UsersHome__Course.t),
  communites: array(UsersHome__Community.t),
  showUserEdit: bool,
  userName: string,
  userTitle: string,
  avatarUrl: option(string),
};

let decodeProps = json =>
  Json.Decode.{
    currentSchoolAdmin: json |> field("currentSchoolAdmin", bool),
    showUserEdit: json |> field("showUserEdit", bool),
    userName: json |> field("userName", string),
    userTitle: json |> field("userTitle", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    courses: json |> field("courses", array(UsersHome__Course.decode)),
    communites:
      json |> field("communites", array(UsersHome__Community.decode)),
  };

let props = DomUtils.parseJsonTag(~id="users-home-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <UsersHome__Root
    currentSchoolAdmin={props.currentSchoolAdmin}
    courses={props.courses}
    communites={props.communites}
    showUserEdit={props.showUserEdit}
    userName={props.userName}
    userTitle={props.userTitle}
    avatarUrl={props.avatarUrl}
  />,
  "users-home",
);
