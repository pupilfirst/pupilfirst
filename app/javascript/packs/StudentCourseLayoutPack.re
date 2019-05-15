[@bs.config {jsx: 3}];
type props = {authenticityToken: string};

let decodeProps = json =>
  Json.Decode.(json |> field("authenticityToken", string));

let authenticityToken =
  DomUtils.parseJsonAttribute(~id="course-header-root", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <StudentCourseHeader authenticityToken />,
  "course-header-root",
);