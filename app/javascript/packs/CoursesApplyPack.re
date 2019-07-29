[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  courseName: string,
  courseDescription: string,
  courseId: string,
  applicant: option(CoursesApply__Applicant.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    courseName: json |> field("courseName", string),
    courseDescription: json |> field("courseDescription", string),
    courseId: json |> field("courseId", string),
    applicant:
      json
      |> field("applicant", nullable(CoursesApply__Applicant.decode))
      |> Js.Null.toOption,
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="courses-apply",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesApply
    authenticityToken={props.authenticityToken}
    courseName={props.courseName}
    courseDescription={props.courseDescription}
    courseId={props.courseId}
    applicant={props.applicant}
  />,
  "courses-apply",
);
