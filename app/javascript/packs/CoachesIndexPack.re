let decodeProps = json =>
  Json.Decode.(
    optional(field("subheading", string), json),
    field("coaches", array(CoachesIndex__Coach.decode), json),
    field("studentInCourseIds", array(string), json),
  );

let (subheading, coaches, studentInCourseIds) =
  DomUtils.parseJSONTag() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoachesIndex__Root subheading coaches studentInCourseIds />,
  "react-root",
);
