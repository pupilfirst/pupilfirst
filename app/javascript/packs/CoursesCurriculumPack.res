open CoursesCurriculum__Types

let decodeProps = json => {
  open Json.Decode
  (
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

let (
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

ReactDOMRe.renderToElementWithId(
  <CoursesCurriculum
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
  "react-root",
)
