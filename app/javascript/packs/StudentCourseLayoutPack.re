[@bs.config {jsx: 3}];

let decodeProps = json =>
  Json.Decode.(
    json |> field("currentCourseId", string),
    json |> field("courses", list(StudentCourse__Course.decode)),
    json |> field("additionalLinks", list(string)),
  );

let (currentCourseId, courses, additionalLinks) =
  DomUtils.parseJsonAttribute(~id="course-header-root", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <StudentCourse__Header currentCourseId courses additionalLinks />,
  "course-header-root",
);
