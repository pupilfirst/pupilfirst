open StudentsPanel__Types;

type props = {
  teams: list(Team.t),
  courseId: string,
  students: list(Student.t),
  courseCoachIds: list(string),
  schoolCoaches: list(Coach.t),
  levels: list(Level.t),
  studentTags: list(string),
  authenticityToken: string,
};

let decodeProps = json =>
  Json.Decode.{
    teams: json |> field("teams", list(Team.decode)),
    courseId: json |> field("courseId", string),
    students: json |> field("students", list(Student.decode)),
    courseCoachIds: json |> field("courseCoachIds", list(string)),
    schoolCoaches: json |> field("schoolCoaches", list(Coach.decode)),
    levels: json |> field("levels", list(Level.decode)),
    studentTags: json |> field("studentTags", list(string)),
    authenticityToken: json |> field("authenticityToken", string),
  };

let props =
  DomUtils.parseJsonTag(~id="sa-students-panel-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SA_ActiveStudentsPanel
    teams={props.teams}
    courseId={props.courseId}
    students={props.students}
    courseCoachIds={props.courseCoachIds}
    schoolCoaches={props.schoolCoaches}
    levels={props.levels}
    studentTags={props.studentTags}
    authenticityToken={props.authenticityToken}
  />,
  "sa-students-panel",
);
