open CoachesCourseIndex__Types;

type props = {
  courseCoachIds: array(string),
  schoolCoaches: array(Coach.t),
  authenticityToken: string,
  courseId: string,
};

let decodeProps = json =>
  Json.Decode.{
    courseCoachIds: json |> field("courseCoachIds", array(string)),
    schoolCoaches: json |> field("schoolCoaches", array(Coach.decode)),
    courseId: json |> field("courseId", string),
    authenticityToken: json |> field("authenticityToken", string),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="sa-coaches-enrollment-panel",
    ~attribute="data-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SA_Coaches_CourseIndex
    courseCoachIds={props.courseCoachIds}
    schoolCoaches={props.schoolCoaches}
    courseId={props.courseId}
    authenticityToken={props.authenticityToken}
  />,
  "sa-coaches-enrollment-panel",
);
