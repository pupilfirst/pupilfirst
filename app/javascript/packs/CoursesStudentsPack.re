[@bs.config {jsx: 3}];

open CoursesStudents__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("levels", array(Level.decode)),
    json |> field("course", Course.decode),
  );

let (levels, course) = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesStudents__Root levels course />,
  "react-root",
);
