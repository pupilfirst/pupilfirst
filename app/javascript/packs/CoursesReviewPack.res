open CoursesReview__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("levels", array(Level.decode)),
    json |> field("courseId", string),
    json |> field("teamCoaches", array(Coach.decode)),
    json |> field("currentCoach", Coach.decode),
  )
}

let (levels, courseId, teamCoaches, currentCoach) = DomUtils.parseJSONAttribute() |> decodeProps

switch ReactDOM.querySelector("#react-root") {
| Some(root) =>
  ReactDOM.render(<CoursesReview__Root levels courseId teamCoaches currentCoach />, root)
| None => ()
}
