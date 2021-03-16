let selectedCourse = {
  Json.Decode.optional(
    Json.Decode.field("selectedCourse", CourseEditor__Course.decode),
    DomUtils.parseJSONTag(~id="course-editor__props", ()),
  )
}

ReactDOMRe.renderToElementWithId(<CourseEditor selectedCourse />, "course-editor")
