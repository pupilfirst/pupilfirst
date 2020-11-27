open CoachesIndex__Types

let decodeProps = json => {
  open Json.Decode
  (
    optional(field("subheading", string), json),
    field("coaches", array(Coach.decode), json),
    field("courses", array(Course.decode), json),
    field("studentInCourseIds", array(string), json),
  )
}

let (subheading, coaches, courses, studentInCourseIds) = DomUtils.parseJSONTag() |> decodeProps

ReactDOMRe.renderToElementWithId(
  <CoachesIndex__Root subheading coaches courses studentInCourseIds />,
  "react-root",
)
