open CourseCoaches__Types

type props = {
  courseCoaches: array<CourseCoach.t>,
  schoolCoaches: array<SchoolCoach.t>,
  authenticityToken: string,
  courseId: string,
}

let decodeProps = json => {
  open Json.Decode
  {
    courseCoaches: json |> field("courseCoaches", array(CourseCoach.decode)),
    schoolCoaches: json |> field("schoolCoaches", array(SchoolCoach.decode)),
    courseId: json |> field("courseId", string),
    authenticityToken: json |> field("authenticityToken", string),
  }
}

let props = DomUtils.parseJSONTag(~id="course-coaches__props", ()) |> decodeProps

switch ReactDOM.querySelector("#sa-coaches-enrollment-panel") {
| Some(element) =>
  ReactDOM.render(
    <CourseCoaches__Root
      courseCoaches=props.courseCoaches
      schoolCoaches=props.schoolCoaches
      courseId=props.courseId
      authenticityToken=props.authenticityToken
    />,
    element,
  )
| None => ()
}
