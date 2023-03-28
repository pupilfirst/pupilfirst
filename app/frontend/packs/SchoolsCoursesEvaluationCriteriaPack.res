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

Psj.match("schools/courses#evaluation_criteria", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(root) =>
    let props =
      DomUtils.parseJSONTag(~id="schools-courses-evaluation-criteria__props", ()) |> decodeProps

    ReactDOM.render(
      <EvaluationCriteria__Index
        courseId=props.courseId evaluationCriteria=props.evaluationCriteria
      />,
      root,
    )
  | None => ()
  }
})
