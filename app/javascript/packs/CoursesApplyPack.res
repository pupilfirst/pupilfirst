type props = {
  courseName: string,
  courseId: string,
  email: option<string>,
  name: option<string>,
  privacyPolicy: bool,
  termsAndConditions: bool,
}

let decodeProps = json => {
  open Json.Decode
  {
    courseName: field("courseName", string, json),
    courseId: field("courseId", string, json),
    email: field("email", optional(string), json),
    name: field("name", optional(string), json),
    privacyPolicy: field("privacyPolicy", bool, json),
    termsAndConditions: field("termsAndConditions", bool, json),
  }
}

let props = DomUtils.parseJSONTag()->decodeProps

ReactDOMRe.renderToElementWithId(
  <CoursesApply__Root
    courseName=props.courseName
    courseId=props.courseId
    email=props.email
    name=props.name
    privacyPolicy=props.privacyPolicy
    termsAndConditions=props.termsAndConditions
  />,
  "react-root",
)
