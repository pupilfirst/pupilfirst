open CoursesReport__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("studentId", string),
    json |> field("levels", array(Level.decode)),
    json |> field("coaches", array(Coach.decode)),
  );

let (studentId, levels, coaches) =
  DomUtils.parseJsonTag(~id="course-student-report__props", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReport studentId levels coaches />,
  "react-root",
);
