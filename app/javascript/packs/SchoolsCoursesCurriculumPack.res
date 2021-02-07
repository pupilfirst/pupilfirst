open CurriculumEditor__Types

type props = {
  course: Course.t,
  evaluationCriteria: array<EvaluationCriterion.t>,
  levels: array<Level.t>,
  targetGroups: array<TargetGroup.t>,
  targets: array<Target.t>,
  hasVimeoAccessToken: bool,
  vimeoPlan: option<VimeoPlan.t>,
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
    vimeoPlan: Belt.Option.map(json |> optional(field("vimeoPlan", string)), VimeoPlan.decode),
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
    vimeoPlan=props.vimeoPlan
  />,
  "curriculum-editor",
)
