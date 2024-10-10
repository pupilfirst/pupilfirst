open SchoolRouter__Types

module Decode = {
  open Json.Decode

  let props = object(field => {
    (
      field.required("courses", array(Course.decode)),
      field.required("currentUser", User.decode),
      field.required("school", School.decode),
    )
  })
}

let (courses, currentUser, school) =
  DomUtils.parseJSONTag(~id="school-router-data", ())->Decode.props

switch ReactDOM.querySelector("#school-router") {
| Some(root) => ReactDOM.render(<SchoolRouter school courses currentUser />, root)
| None => ()
}
