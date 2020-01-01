[@bs.config {jsx: 3}];

open CourseExports__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("course", Course.decode),
    json |> field("exports", array(CourseExport.decode)),
    json |> field("tags", array(Tag.decode)),
  );

let (authenticityToken, course, exports, tags) =
  DomUtils.parseJsonTag(~id="schools-courses-exports__props", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CourseExports__Root authenticityToken course exports tags />,
  "schools-courses-exports__root",
);
