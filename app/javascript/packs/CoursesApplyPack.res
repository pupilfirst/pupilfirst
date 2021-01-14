type props = {
  courseName: string,
  courseId: string,
  thumbnailUrl: option<string>,
  email: option<string>,
  name: option<string>,
  privacyPolicy: bool,
  termsAndConditions: bool,
}

let decodeProps = json => {
  open Json.Decode
  {
    courseName: json |> field("courseName", string),
    courseId: json |> field("courseId", string),
    thumbnailUrl: json |> field("thumbnailUrl", optional(string)),
    email: json |> field("email", optional(string)),
    name: json |> field("name", optional(string)),
    privacyPolicy: json |> field("privacyPolicy", bool),
    termsAndConditions: json |> field("termsAndConditions", bool),
  }
}

let props = DomUtils.parseJSONTag() |> decodeProps

ReactDOMRe.renderToElementWithId(
  <CoursesApply__Root
    courseName=props.courseName
    courseId=props.courseId
    thumbnailUrl=props.thumbnailUrl
    email=props.email
    name=props.name
    privacyPolicy=props.privacyPolicy
    termsAndConditions=props.termsAndConditions
  />,
  "react-root",
)
