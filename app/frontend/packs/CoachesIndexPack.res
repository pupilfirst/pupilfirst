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

Psj.match("faculty#index", () => {
  let (subheading, coaches, courses, studentInCourseIds) = DomUtils.parseJSONTag() |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(<CoachesIndex__Root subheading coaches courses studentInCourseIds />, root)
  | None => ()
  }
})
