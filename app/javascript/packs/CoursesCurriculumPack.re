open CoursesCurriculum__Types;

let decodeProps = json =>
  Json.Decode.(
    field("course", Course.decode, json),
    field("levels", list(Level.decode), json),
    field("targetGroups", list(TargetGroup.decode), json),
    field("targets", list(Target.decode), json),
    field("submissions", list(LatestSubmission.decode), json),
    field("team", Team.decode, json),
    field("coaches", list(Coach.decode), json),
    field("users", list(User.decode), json),
    field("evaluationCriteria", list(EvaluationCriterion.decode), json),
    field("preview", bool, json),
    field("accessLockedLevels", bool, json),
    field("teamMembersPending", bool, json),
  );

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
  teamMembersPending,
) =
  DomUtils.parseJSONTag() |> decodeProps;

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
    teamMembersPending
  />,
  "react-root",
);
