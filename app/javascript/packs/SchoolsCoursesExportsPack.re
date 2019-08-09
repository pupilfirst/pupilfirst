[@bs.config {jsx: 3}];

open CourseExports__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("course", Course.decode),
    json |> field("exports", array(CourseExport.decode)),
  );

let (course, exports) =
  DomUtils.parseJsonAttribute(~id="schools-courses-exports__root", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CourseExports__Root course exports />,
  "schools-courses-exports__root",
);
