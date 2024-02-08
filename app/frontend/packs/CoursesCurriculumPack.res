open CoursesCurriculum__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("currentUser", CurrentUser.decode, json),
    field("author", bool, json),
    field("course", Course.decode, json),
    field("levels", array(Level.decode), json),
    field("targetGroups", array(TargetGroup.decode), json),
    field("targets", array(Target.decode), json),
    field("submissions", array(LatestSubmission.decode), json),
    field("targetsRead", array(string), json),
    field("student", Student.decode, json),
    field("coaches", array(Coach.decode), json),
    field("users", array(User.decode), json),
    field("evaluationCriteria", array(EvaluationCriterion.decode), json),
    field("preview", bool, json),
    field("accessLockedLevels", bool, json),
  )
}

Psj.matchPaths(["courses/:id/curriculum", "targets/:id", "targets/:id/:slug"], () => {
  let (
    currentUser,
    author,
    course,
    levels,
    targetGroups,
    targets,
    submissions,
    targetsRead,
    student,
    coaches,
    users,
    evaluationCriteria,
    preview,
    accessLockedLevels,
  ) =
    DomUtils.parseJSONTag() |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <CoursesCurriculum
        currentUser
        author
        course
        levels
        targetGroups
        targets
        submissions
        targetsRead
        student
        coaches
        users
        evaluationCriteria
        preview
        accessLockedLevels
      />,
      root,
    )
  | None => ()
  }
})
