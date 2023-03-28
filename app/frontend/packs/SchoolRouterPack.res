open SchoolRouter__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("courses", array(Course.decode), json),
    field("currentUser", User.decode, json),
    field("school", School.decode, json),
  )
}

let (courses, currentUser, school) =
  DomUtils.parseJSONTag(~id="school-router-data", ())->decodeProps

switch ReactDOM.querySelector("#school-router") {
| Some(root) => ReactDOM.render(<SchoolRouter school courses currentUser />, root)
| None => ()
}
