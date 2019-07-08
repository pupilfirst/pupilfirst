[@bs.config {jsx: 3}];

open CourseShow__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("course", Course.decode),
    json |> field("levels", list(Level.decode)),
    json |> field("targetGroups", list(TargetGroup.decode)),
    json |> field("targets", list(Target.decode)),
    json |> field("submissions", list(LatestSubmission.decode)),
    json |> field("team", Team.decode),
    json |> field("coaches", list(Coach.decode)),
    json |> field("userProfiles", list(UserProfile.decode)),
    json |> field("evaluationCriteria", list(EvaluationCriterion.decode)),
  );

let (
  authenticityToken,
  course,
  levels,
  targetGroups,
  targets,
  submissions,
  team,
  coaches,
  userProfiles,
  evaluationCriteria,
) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesShow__Curriculum
    authenticityToken
    course
    levels
    targetGroups
    targets
    submissions
    team
    coaches
    userProfiles
    evaluationCriteria
  />,
  "react-root",
);
