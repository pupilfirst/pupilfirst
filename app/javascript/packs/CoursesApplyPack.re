[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  courseName: string,
  courseDescription: string,
  courseId: string,
  thumbnailUrl: option(string),
  email: option(string),
  name: option(string),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    courseName: json |> field("courseName", string),
    courseDescription: json |> field("courseDescription", string),
    courseId: json |> field("courseId", string),
    thumbnailUrl: json |> field("thumbnailUrl", optional(string)),
    email: json |> field("email", optional(string)),
    name: json |> field("name", optional(string)),
  };

let props =
  DomUtils.parseJsonAttribute(~id="courses-apply", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesApply__Root
    authenticityToken={props.authenticityToken}
    courseName={props.courseName}
    courseId={props.courseId}
    thumbnailUrl={props.thumbnailUrl}
    email={props.email}
    name={props.name}
  />,
  "courses-apply",
);
