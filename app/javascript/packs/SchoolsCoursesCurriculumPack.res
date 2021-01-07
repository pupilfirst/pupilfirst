open CurriculumEditor__Types

type props = {
  course: Course.t,
  evaluationCriteria: array<EvaluationCriterion.t>,
  levels: array<Level.t>,
  targetGroups: array<TargetGroup.t>,
  targets: array<Target.t>,
  hasVimeoAccessToken: bool,
}

let decodeProps = json => {
  open Json.Decode
  {
    course: json |> field("course", Course.decode),
    evaluationCriteria: json |> field("evaluationCriteria", array(EvaluationCriterion.decode)),
    levels: json |> field("levels", array(Level.decode)),
    targetGroups: json |> field("targetGroups", array(TargetGroup.decode)),
    targets: json |> field("targets", array(Target.decode)),
    hasVimeoAccessToken: json |> field("hasVimeoAccessToken", bool),
  }
}

let props =
  DomUtils.parseJSONAttribute(~id="curriculum-editor", ~attribute="data-props", ()) |> decodeProps

ReactDOMRe.renderToElementWithId(
  <CurriculumEditor
    course=props.course
    evaluationCriteria=props.evaluationCriteria
    levels=props.levels
    targetGroups=props.targetGroups
    targets=props.targets
    hasVimeoAccessToken=props.hasVimeoAccessToken
  />,
  "curriculum-editor",
)
