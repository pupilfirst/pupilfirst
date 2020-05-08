open CoursesReport__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("studentId", string),
    json |> field("levels", array(Level.decode)),
    json |> field("coaches", array(Coach.decode)),
    json |> field("teamStudentIds", array(string)),
  );

let (studentId, levels, coaches, teamStudentIds) =
  DomUtils.parseJsonTag(~id="course-student-report__props", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReport studentId levels coaches teamStudentIds />,
  "react-root",
);
