open StudentsEditor__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("courseId", string),
    json |> field("courseCoachIds", array(string)),
    json |> field("schoolCoaches", array(Coach.decode)),
    json |> field("levels", array(Level.decode)),
    json |> field("studentTags", array(string)),
    json |> field("certificates", array(Certificate.decode)),
  );

let (
  courseId,
  courseCoachIds,
  schoolCoaches,
  levels,
  studentTags,
  certificates,
) =
  DomUtils.parseJSONTag(~id="sa-students-panel-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <StudentsEditor__Root
    courseId
    courseCoachIds
    schoolCoaches
    levels
    studentTags
    certificates
  />,
  "sa-students-panel",
);
