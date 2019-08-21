[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  courseName: string,
  courseDescription: string,
  courseId: string,
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    courseName: json |> field("courseName", string),
    courseDescription: json |> field("courseDescription", string),
    courseId: json |> field("courseId", string),
  };

let props =
  DomUtils.parseJsonAttribute(~id="courses-apply", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesApply__Root
    authenticityToken={props.authenticityToken}
    courseName={props.courseName}
    courseDescription={props.courseDescription}
    courseId={props.courseId}
  />,
  "courses-apply",
);
