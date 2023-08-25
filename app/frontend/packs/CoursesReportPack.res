open CoursesReport__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("studentId", string),
    json |> field("coaches", array(Coach.decode)),
    json |> field("teamStudentIds", array(string)),
  )
}

Psj.match("courses#report", () => {
  let (studentId, coaches, teamStudentIds) =
    DomUtils.parseJSONTag(~id="course-student-report__props", ()) |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(<CoursesReport__Root studentId coaches teamStudentIds />, root)
  | None => ()
  }
})
