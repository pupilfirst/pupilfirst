[@bs.config {jsx: 3}];

open CoursesStudents__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("levels", array(Level.decode)),
    json |> field("course", Course.decode),
    json |> field("students", array(Student.decode)),
    json |> field("teams", array(Team.decode)),
  );

let (authenticityToken, levels, course, students, teams) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesStudents__Root authenticityToken levels course students teams />,
  "react-root",
);
