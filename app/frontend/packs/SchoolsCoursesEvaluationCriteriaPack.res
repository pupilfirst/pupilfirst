type props = {
  courseId: string,
  evaluationCriteria: array<EvaluationCriterion.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    courseId: json |> field("courseId", string),
    evaluationCriteria: json |> field("evaluationCriteria", array(EvaluationCriterion.decode)),
  }
}

let props =
  DomUtils.parseJSONTag(~id="schools-courses-evaluation-criteria__props", ()) |> decodeProps

switch ReactDOM.querySelector("#schools-courses-evaluation-criteria__root") {
| Some(root) =>
  ReactDOM.render(
    <EvaluationCriteria__Index
      courseId=props.courseId evaluationCriteria=props.evaluationCriteria
    />,
    root,
  )
| None => ()
}
