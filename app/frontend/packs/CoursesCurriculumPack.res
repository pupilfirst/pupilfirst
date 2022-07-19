open CoursesCurriculum__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("author", bool, json),
    field("course", Course.decode, json),
    field("levels", array(Level.decode), json),
    field("targetGroups", array(TargetGroup.decode), json),
    field("targets", array(Target.decode), json),
    field("submissions", array(LatestSubmission.decode), json),
    field("team", Team.decode, json),
    field("coaches", array(Coach.decode), json),
    field("users", array(User.decode), json),
    field("evaluationCriteria", array(EvaluationCriterion.decode), json),
    field("preview", bool, json),
    field("accessLockedLevels", bool, json),
    field("levelUpEligibility", LevelUpEligibility.decode, json),
  )
}

Psj.matchPaths(["courses/:id/curriculum", "targets/:id", "targets/:id/:slug"], () => {
  let (
    author,
    course,
    levels,
    targetGroups,
    targets,
    submissions,
    team,
    coaches,
    users,
    evaluationCriteria,
    preview,
    accessLockedLevels,
    levelUpEligibility,
  ) =
    DomUtils.parseJSONTag() |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(
      <CoursesCurriculum
        author
        course
        levels
        targetGroups
        targets
        submissions
        team
        coaches
        users
        evaluationCriteria
        preview
        accessLockedLevels
        levelUpEligibility
      />,
      root,
    )
  | None => ()
  }
})
