open CoursesStudents__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("levels", array(Level.decode)),
    json |> field("course", Course.decode),
    json |> field("userId", string),
    json |> field("personalCoaches", array(Coach.decode)),
    json |> field("currentCoach", Coach.decode),
    json |> field("teamTags", array(string)) |> Belt.Set.String.fromArray,
    json |> field("userTags", array(string)) |> Belt.Set.String.fromArray,
  )
}

Psj.matchPaths(["courses/:id/students", "students/:id/report"], () => {
  let (levels, course, userId, personalCoaches, currentCoach, teamTags, userTags) =
    DomUtils.parseJSONTag(~id="school-course-students__props", ()) |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <CoursesStudents__Root levels course userId personalCoaches currentCoach teamTags userTags />,
      root,
    )
  | None => ()
  }
})
