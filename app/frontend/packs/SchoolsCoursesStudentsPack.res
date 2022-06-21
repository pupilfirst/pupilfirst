open StudentsEditor__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("courseId", string),
    json |> field("courseCoachIds", array(string)),
    json |> field("schoolCoaches", array(Coach.decode)),
    json |> field("levels", array(Level.decode)),
    json |> field("userTags", array(string)),
    json |> field("teamTags", array(string)),
    json |> field("certificates", array(Certificate.decode)),
    json |> field("currentUserName", string),
  )
}

Psj.match("schools/courses#students", () => {
  switch ReactDOM.querySelector("#sa-students-panel") {
  | Some(element) =>
    let (
      courseId,
      courseCoachIds,
      schoolCoaches,
      levels,
      userTags,
      teamTags,
      certificates,
      currentUserName,
    ) =
      DomUtils.parseJSONTag(~id="sa-students-panel-data", ()) |> decodeProps

    ReactDOM.render(
      <StudentsEditor__Root
        courseId courseCoachIds schoolCoaches levels userTags teamTags certificates currentUserName
      />,
      element,
    )
  | None => ()
  }
})
