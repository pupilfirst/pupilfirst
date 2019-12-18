[@bs.config {jsx: 3}];

type props = {courseId: string};

let decodeProps = json =>
  Json.Decode.{courseId: json |> field("courseId", string)};

let props =
  DomUtils.parseJsonAttribute(
    ~id="schools-courses-evaluation-criteria__root",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <EvaluationCriteria__Index courseId={props.courseId} />,
  "schools-courses-evaluation-criteria__root",
);
