let selectedCourse = {
  Json.Decode.optional(
    Json.Decode.field("selectedCourse", CourseEditor__Course.decode),
    DomUtils.parseJSONTag(~id="course-editor__props", ()),
  )
}

switch ReactDOM.querySelector("#course-editor") {
| Some(element) => ReactDOM.render(<CourseEditor selectedCourse />, element)
| None => ()
}
