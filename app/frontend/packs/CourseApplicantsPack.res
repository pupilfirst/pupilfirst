let decodeProps = json => {
  open Json.Decode
  (
    field("courseId", string, json),
    field("tags", array(string), json),
    field("selectedApplicant", optional(CourseApplicants__Applicant.decode), json),
  )
}

Psj.match("schools/courses#applicants", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(root) =>
    let (courseId, tags, selectedApplicant) =
      DomUtils.parseJSONTag(~id="schools-courses-applicants__props", ())->decodeProps

    ReactDOM.render(<CourseApplicants__Root courseId tags selectedApplicant />, root)
  | None => ()
  }
})
