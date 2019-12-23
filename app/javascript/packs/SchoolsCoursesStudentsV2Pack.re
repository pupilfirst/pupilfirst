[@bs.config {jsx: 3}];

open StudentsEditor__Types;

type props = {
  courseId: string,
  courseCoachIds: list(string),
  schoolCoaches: list(Coach.t),
  levels: list(Level.t),
  studentTags: list(string),
};

let decodeProps = json =>
  Json.Decode.{
    courseId: json |> field("courseId", string),
    courseCoachIds: json |> field("courseCoachIds", list(string)),
    schoolCoaches: json |> field("schoolCoaches", list(Coach.decode)),
    levels: json |> field("levels", list(Level.decode)),
    studentTags: json |> field("studentTags", list(string)),
  };

let props =
  DomUtils.parseJsonTag(~id="sa-students-panel-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <StudentsEditor__Root
    courseId={props.courseId}
    courseCoachIds={props.courseCoachIds}
    schoolCoaches={props.schoolCoaches}
    levels={props.levels}
    studentTags={props.studentTags}
  />,
  "sa-students-panel",
);
