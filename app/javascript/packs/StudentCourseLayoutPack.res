let decodeProps = json => {
  open Json.Decode
  (
    field("currentCourseId", string, json),
    field("courses", array(CourseInfo.decode), json),
    field("additionalLinks", array(string), json),
    field("coverImage", optional(string), json),
  )
}

let (currentCourseId, courses, additionalLinks, coverImage) =
  DomUtils.parseJSONAttribute(~id="course-header-root", ())->decodeProps

ReactDOMRe.renderToElementWithId(
  <StudentCourse__Header currentCourseId courses additionalLinks coverImage />,
  "course-header-root",
)
