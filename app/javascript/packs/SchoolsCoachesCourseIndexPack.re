open CoachesCourseIndex__Types;

type props = {
  courseCoachIds: list(int),
  startupCoachIds: list(int),
  schoolCoaches: list(Coach.t),
  authenticityToken: string,
  courseId: int,
};

let decodeProps = json =>
  Json.Decode.{
    courseCoachIds: json |> field("courseCoachIds", list(int)),
    startupCoachIds: json |> field("startupCoachIds", list(int)),
    schoolCoaches: json |> field("schoolCoaches", list(Coach.decode)),
    courseId: json |> field("courseId", int),
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
    startupCoachIds={props.startupCoachIds}
    schoolCoaches={props.schoolCoaches}
    courseId={props.courseId}
    authenticityToken={props.authenticityToken}
  />,
  "sa-coaches-enrollment-panel",
);
