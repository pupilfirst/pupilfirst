let decodeProps = json => {
  open Json.Decode
  (
    field("courseId", string, json),
    field("tags", array(string), json),
    field("selectedApplicant", optional(CourseApplicants__Applicant.decode), json),
  )
}

let (courseId, tags, selectedApplicant) =
  DomUtils.parseJSONTag(~id="schools-courses-applicants__props", ())->decodeProps

switch ReactDOM.querySelector("#schools-courses-applicants__root") {
| Some(root) =>
  ReactDOM.render(  <CourseApplicants__Root courseId tags selectedApplicant />, root)
| None => ()
}
