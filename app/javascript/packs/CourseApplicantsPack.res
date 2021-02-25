let decodeProps = json => {
  open Json.Decode
  (field("courseId", string, json), field("tags", array(string), json))
}

let (courseId, tags) =
  DomUtils.parseJSONTag(~id="schools-courses-applicants__props", ())->decodeProps

ReactDOMRe.renderToElementWithId(
  <CourseApplicants__Root courseId tags />,
  "schools-courses-applicants__root",
)
