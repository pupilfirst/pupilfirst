[@bs.config {jsx: 3}];

open CoursesStudents__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("levels", array(Level.decode)),
    json |> field("course", Course.decode),
    json |> field("userId", string),
    json |> field("teamCoaches", array(TeamCoach.decode)),
  );

let (levels, course, userId, teamCoaches) =
  DomUtils.parseJsonTag(~id="school-course-students__props", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesStudents__Root levels course userId teamCoaches />,
  "react-root",
);
