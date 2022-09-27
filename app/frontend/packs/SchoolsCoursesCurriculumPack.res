open CurriculumEditor__Types

type props = {
  course: Course.t,
  evaluationCriteria: array<EvaluationCriterion.t>,
  levels: array<Level.t>,
  targetGroups: array<TargetGroup.t>,
  targets: array<Target.t>,
  hasVimeoAccessToken: bool,
  markdownCurriculumEditorMaxLength: int,
  vimeoPlan: option<VimeoPlan.t>,
  enabledFeatures: array<string>,
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
    markdownCurriculumEditorMaxLength: json |> field("markdownCurriculumEditorMaxLength", int),
    vimeoPlan: Belt.Option.map(json |> optional(field("vimeoPlan", string)), VimeoPlan.decode),
    enabledFeatures: json |> field("enabledFeatures", array(string)),
  }
}

Psj.matchPaths(
  [
    "school/courses/:id/curriculum",
    "school/courses/:course_id/targets/:target_id/content",
    "school/courses/:course_id/targets/:target_id/details",
    "school/courses/:course_id/targets/:target_id/versions",
  ],
  () => {
    switch ReactDOM.querySelector("#schoolrouter-innerpage") {
    | Some(element) =>
      let props = DomUtils.parseJSONTag(~id="curriculum-editor", ()) |> decodeProps

      ReactDOM.render(
        <Toggle.Provider value=props.enabledFeatures>
          <CurriculumEditor
            course=props.course
            evaluationCriteria=props.evaluationCriteria
            levels=props.levels
            targetGroups=props.targetGroups
            targets=props.targets
            hasVimeoAccessToken=props.hasVimeoAccessToken
            vimeoPlan=props.vimeoPlan
            markdownCurriculumEditorMaxLength=props.markdownCurriculumEditorMaxLength
          />
        </Toggle.Provider>,
        element,
      )
    | None => ()
    }
  },
)
