[@bs.config {jsx: 3}];

open CourseShow__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("schoolName", string),
    json |> field("course", Course.decode),
    json |> field("levels", list(Level.decode)),
    json |> field("targetGroups", list(TargetGroup.decode)),
    json |> field("targets", list(Target.decode)),
    json |> field("submissions", list(Submission.decode)),
    json |> field("team", string),
    json |> field("students", list(Student.decode)),
    json |> field("coaches", list(Coach.decode)),
    json |> field("userProfiles", list(UserProfile.decode)),
    json |> field("currentUserId", string),
    json |> field("locked", bool),
  );

let (
  authenticityToken,
  schoolName,
  course,
  levels,
  targetGroups,
  targets,
  submissions,
  team,
  students,
  coaches,
  userProfiles,
  currentUserId,
  locked,
) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesShow__Curriculum
    authenticityToken
    schoolName
    course
    levels
    targetGroups
    targets
    submissions
    team
    students
    coaches
    userProfiles
    currentUserId
    locked
  />,
  "react-root",
);