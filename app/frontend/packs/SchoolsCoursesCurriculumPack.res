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
    course: field("course", Course.decode, json),
    evaluationCriteria: field("evaluationCriteria", array(EvaluationCriterion.decode), json),
    levels: field("levels", array(Level.decode), json),
    targetGroups: field("targetGroups", array(TargetGroup.decode), json),
    targets: field("targets", array(Target.decode), json),
    hasVimeoAccessToken: field("hasVimeoAccessToken", bool, json),
    markdownCurriculumEditorMaxLength: field("markdownCurriculumEditorMaxLength", int, json),
    vimeoPlan: Belt.Option.map(option(field("vimeoPlan", string), json), VimeoPlan.decode),
    enabledFeatures: field("enabledFeatures", array(string), json),
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
      let props = decodeProps(DomUtils.parseJSONTag(~id="curriculum-editor", ()))

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
