let decodeProps = json => {
  open Json.Decode
  (
    field("currentCourseId", string, json),
    field("courses", array(CourseInfo.decode), json),
    field("additionalLinks", array(string), json),
    field("coverImage", optional(string), json),
  )
}

Psj.matchPaths([], () => {
  let (currentCourseId, courses, additionalLinks, coverImage) =
    DomUtils.parseJSONAttribute(~id="course-header-root", ())->decodeProps

  switch ReactDOM.querySelector("#course-header-root") {
  | Some(root) =>
    ReactDOM.render(
      <StudentCourse__Header currentCourseId courses additionalLinks coverImage />,
      root,
    )
  | None => ()
  }
})
