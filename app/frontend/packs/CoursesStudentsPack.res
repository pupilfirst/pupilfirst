open CoursesStudents__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("levels", array(Level.decode)),
    json |> field("course", Course.decode),
    json |> field("userId", string),
  )
}

Psj.matchPaths(["courses/:id/students", "students/:id/report"], () => {
  let (levels, course, userId) =
    DomUtils.parseJSONTag(~id="school-course-students__props", ()) |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) => ReactDOM.render(<CoursesStudents__Root levels course userId />, root)
  | None => ()
  }
})
