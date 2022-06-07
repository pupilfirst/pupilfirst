type props = {
  communities: list<SchoolCommunities__Community.t>,
  courses: list<SchoolCommunities__Course.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    communities: json |> field("communities", list(SchoolCommunities__Community.decode)),
    courses: json |> field("courses", list(SchoolCommunities__Course.decode)),
  }
}

let props = DomUtils.parseJSONTag() |> decodeProps

switch ReactDOM.querySelector("#school-communities") {
| Some(element) =>
  ReactDOM.render(
    <SchoolCommunities__Index communities=props.communities courses=props.courses />,
    element,
  )
| None => ()
}
