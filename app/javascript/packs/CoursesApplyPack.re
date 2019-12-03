[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  courseName: string,
  courseDescription: string,
  courseId: string,
  email: option(string),
  name: option(string),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    courseName: json |> field("courseName", string),
    courseDescription: json |> field("courseDescription", string),
    courseId: json |> field("courseId", string),
    email: json |> field("email", optional(string)),
    name: json |> field("name", optional(string)),
  };

let props =
  DomUtils.parseJsonAttribute(~id="courses-apply", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesApply__Root
    authenticityToken={props.authenticityToken}
    courseName={props.courseName}
    courseDescription={props.courseDescription}
    courseId={props.courseId}
    email={props.email}
    name={props.name}
  />,
  "courses-apply",
);
