let str = React.string
let t = I18n.t(~scope="components.CurriculumEditor")

open CurriculumEditor__Types

type editorAction =
  | Hidden
  | ShowTargetGroupEditor(option<TargetGroup.t>)
  | ShowLevelEditor(option<Level.t>)

type state = {
  selectedLevel: Level.t,
  editorAction: editorAction,
  levels: array<Level.t>,
  targetGroups: array<TargetGroup.t>,
  targets: array<Target.t>,
  showArchived: bool,
}

type action =
  | SelectLevel(Level.t)
  | UpdateEditorAction(editorAction)
  | UpdateLevels(Level.t)
  | UpdateTargetGroup(TargetGroup.t)
  | UpdateTargetGroups(array<TargetGroup.t>)
  | UpdateTarget(Target.t)
  | UpdateTargets(array<Target.t>)
  | ToggleShowArchived

let reducer = (state, action) =>
  switch action {
  | SelectLevel(selectedLevel) => {...state, selectedLevel: selectedLevel}
  | UpdateEditorAction(editorAction) => {...state, editorAction: editorAction}
  | UpdateLevels(level) =>
    let newLevels = level->Level.updateArray(state.levels)
    {...state, levels: newLevels, editorAction: Hidden, selectedLevel: level}
  | UpdateTargetGroup(targetGroup) =>
    let newtargetGroups = targetGroup |> TargetGroup.updateArray(state.targetGroups)
    {...state, targetGroups: newtargetGroups}
  | UpdateTargetGroups(targetGroups) => {...state, targetGroups: targetGroups}
  | UpdateTarget(target) =>
    let newtargets = target |> Target.updateArray(state.targets)
    {...state, targets: newtargets}
  | ToggleShowArchived => {...state, showArchived: !state.showArchived}
  | UpdateTargets(targets) => {...state, targets: targets}
  }

let showArchivedButton = (targetGroupsInLevel, targets) => {
  let tgIds = targetGroupsInLevel->Js.Array2.map(TargetGroup.id)

  let numberOfArchivedTargetGroupsInLevel =
    targetGroupsInLevel->Js.Array2.filter(TargetGroup.archived)->Js.Array2.length

  let numberOfArchivedTargetsInLevel =
    targets
    ->Js.Array2.filter(target => tgIds->Js.Array2.includes(Target.targetGroupId(target)))
    ->Js.Array2.filter(target => Target.visibility(target) == Archived)
    ->Js.Array2.length

  numberOfArchivedTargetGroupsInLevel > 0 || numberOfArchivedTargetsInLevel > 0
}

let updateTargetSortIndex = (state, send, sortedTargets) => {
  let oldTargets = state.targets->Js.Array2.filter(t => !Js.Array2.includes(sortedTargets, t))

  send(UpdateTargets(Js.Array2.concat(oldTargets, Target.updateSortIndex(sortedTargets))))
}

let updateTargetGroupSortIndex = (state, send, sortedTargetGroups) => {
  let oldTargetGroups =
    state.targetGroups->Js.Array2.filter(t => !Js.Array2.includes(sortedTargetGroups, t))

  send(
    UpdateTargetGroups(
      Js.Array2.concat(TargetGroup.updateSortIndex(sortedTargetGroups), oldTargetGroups),
    ),
  )
}

let levelOfTarget = (targetId, targets, levels, targetGroups) => {
  let target =
    targets |> ArrayUtils.unsafeFind(
      target => Target.id(target) == targetId,
      "Unable to find target with ID:" ++ (targetId ++ " in CurriculumEditor"),
    )
  let targetGroup =
    targetGroups |> ArrayUtils.unsafeFind(
      tg => TargetGroup.id(tg) == Target.targetGroupId(target),
      "Unable to find target group with ID:" ++
      (Target.targetGroupId(target) ++
      " in CurriculumEditor"),
    )

  Level.unsafeFind(levels, "CurriculumEditor", TargetGroup.levelId(targetGroup))
}

let computeIntialState = ((levels, targetGroups, targets, path)) => {
  let defaultLevel =
    DomUtils.getUrlParam(~key="level")
    ->Belt.Option.flatMap(Belt.Int.fromString)
    ->Belt.Option.flatMap(levelNumber => {
      Js.Array2.find(levels, level => Level.number(level) == levelNumber)
    })
    ->Belt.Option.getWithDefault(
      Js.Array2.reduce(
        levels,
        (max, level) => Level.number(level) > Level.number(max) ? level : max,
        Js.Array2.unsafe_get(levels, 0),
      ),
    )

  let selectedLevel = switch path {
  | list{"school", "courses", _courseId, "curriculum"} => defaultLevel
  | list{"school", "courses", _courseId, "targets", targetId, ..._} =>
    levelOfTarget(targetId, targets, levels, targetGroups)
  | _ => defaultLevel
  }

  {
    selectedLevel: selectedLevel,
    editorAction: Hidden,
    targetGroups: targetGroups,
    levels: levels,
    targets: targets,
    showArchived: false,
  }
}

@react.component
let make = (
  ~course,
  ~evaluationCriteria,
  ~levels,
  ~targetGroups,
  ~targets,
  ~hasVimeoAccessToken,
  ~vimeoPlan,
  ~markdownCurriculumEditorMaxLength,
) => {
  let path = RescriptReactRouter.useUrl().path
  let (state, send) = React.useReducerWithMapState(
    reducer,
    (levels, targetGroups, targets, path),
    computeIntialState,
  )

  let hideEditorActionCB = () => send(UpdateEditorAction(Hidden))
  let currentLevel = state.selectedLevel
  let currentLevelId = Level.id(currentLevel)
  let updateLevelsCB = level => send(UpdateLevels(level))

  let targetGroupsInLevel =
    state.targetGroups
    ->Js.Array2.filter(targetGroup => TargetGroup.levelId(targetGroup) == currentLevelId)
    ->TargetGroup.sort

  let targetGroupsToDisplay = state.showArchived
    ? targetGroupsInLevel
    : targetGroupsInLevel->Js.Array2.filter(tg => !TargetGroup.archived(tg))

  let showTargetGroupEditorCB = targetGroup =>
    send(UpdateEditorAction(ShowTargetGroupEditor(targetGroup)))

  let updateTargetCB = target => {
    let targetGroup =
      state.targetGroups |> ArrayUtils.unsafeFind(
        tg => TargetGroup.id(tg) == Target.targetGroupId(target),
        "Unable to find target group with ID:" ++ Target.targetGroupId(target),
      )

    let updatedTargetGroup = switch Target.visibility(target) {
    | Archived => targetGroup
    | Draft
    | Live =>
      TargetGroup.unarchive(targetGroup)
    }

    send(UpdateTarget(target))
    send(UpdateTargetGroup(updatedTargetGroup))
  }

  let updateTargetGroupsCB = targetGroup => {
    TargetGroup.archived(targetGroup)
      ? {
          let targetIdsInTargerGroup =
            state.targets |> Target.targetIdsInTargetGroup(TargetGroup.id(targetGroup))
          let newTargets =
            state.targets->Js.Array2.map(target =>
              targetIdsInTargerGroup->Js.Array2.includes(Target.id(target))
                ? Target.archive(target)
                : target
            )
          send(UpdateTargets(newTargets))
        }
      : ()
    send(UpdateTargetGroup(targetGroup))
    send(UpdateEditorAction(Hidden))
  }

  <div className="flex-1 flex flex-col">
    <div className="bg-white p-4 md:hidden shadow border-b">
      <button
        className="sa-toggle__menu-btn sa-toggle__menu-btn--arrow hover:bg-gray-50 focus:outline-none">
        <span className="sa-toggle__menu-btn-box">
          <span className="sa-toggle__menu-btn-inner" />
        </span>
      </button>
    </div>
    <CurriculumEditor__TargetDrawer
      hasVimeoAccessToken
      markdownCurriculumEditorMaxLength
      targets=state.targets
      levels=state.levels
      targetGroups=state.targetGroups
      evaluationCriteria
      course
      updateTargetCB
      vimeoPlan
    />
    {switch state.editorAction {
    | Hidden => React.null
    | ShowTargetGroupEditor(targetGroup) =>
      <CurriculumEditor__TargetGroupEditor
        targetGroup levels=state.levels currentLevelId updateTargetGroupsCB hideEditorActionCB
      />
    | ShowLevelEditor(level) =>
      <CurriculumEditor__LevelEditor
        levels=state.levels level course hideEditorActionCB updateLevelsCB
      />
    }}
    <div className="px-6 pb-12 flex-1 bg-gray-50 relative">
      <div className="w-full py-4 relative md:sticky top-0 z-20 bg-gray-50 border-b">
        <div className="max-w-3xl flex items-center justify-between mx-auto">
          <div className="flex">
            <div className="inline-block relative w-auto md:w-64">
              <select
                onChange={event => {
                  let level_id = ReactEvent.Form.target(event)["value"]
                  send(SelectLevel(Level.selectLevel(state.levels, level_id)))
                }}
                value={Level.id(currentLevel)}
                ariaLabel="Select level"
                className="block appearance-none w-full bg-white border text-sm border-gray-300 rounded-s hover:border-gray-500 px-4 py-3 pe-8 rounded-e-none leading-tight focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
                {state.levels
                ->Level.sort
                ->Js.Array2.map(level =>
                  <option key={Level.id(level)} value={Level.id(level)}>
                    {LevelLabel.format(
                      ~name=Level.name(level),
                      Level.number(level)->string_of_int,
                    )->str}
                  </option>
                )
                ->React.array}
              </select>
              <div
                className="pointer-events-none absolute inset-y-0 end-0 flex items-center px-3 text-gray-800">
                <i className="fas fa-chevron-down text-xs" />
              </div>
            </div>
            <button
              title={t("edit_selected_level")}
              ariaLabel={t("edit_selected_level")}
              className="flex items-center text-gray-600 hover:text-gray-900 text-sm font-bold border border-gray-300 border-s-0 py-1 px-2 rounded-e focus:outline-none focus:text-gray-900 focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
              onClick={_ => send(UpdateEditorAction(ShowLevelEditor(Some(state.selectedLevel))))}>
              <i className="fas fa-pencil-alt" />
            </button>
            <button
              className="btn btn-primary ms-4"
              onClick={_ => send(UpdateEditorAction(ShowLevelEditor(None)))}>
              <i className="fas fa-plus-square me-2 text-lg" />
              <span> {t("create_level") |> str} </span>
            </button>
          </div>
          {showArchivedButton(targetGroupsInLevel, state.targets)
            ? <button className="btn btn-default" onClick={_ => send(ToggleShowArchived)}>
                {(state.showArchived ? t("hide_archived") : t("show_archived")) |> str}
              </button>
            : React.null}
        </div>
      </div>
      <div className="target-group__container max-w-3xl mt-5 mx-auto relative">
        {targetGroupsToDisplay
        |> Js.Array.mapi((targetGroup, index) =>
          <CurriculumEditor__TargetGroupShow
            key={targetGroup |> TargetGroup.id}
            targetGroup
            targetGroups=targetGroupsToDisplay
            targets=state.targets
            showTargetGroupEditorCB
            updateTargetCB
            showArchived=state.showArchived
            updateTargetSortIndexCB={updateTargetSortIndex(state, send)}
            updateTargetGroupSortIndexCB={updateTargetGroupSortIndex(state, send)}
            index
            course
          />
        )
        |> React.array}
        <button
          ariaLabel={t("create_target_group")}
          onClick={_ => send(UpdateEditorAction(ShowTargetGroupEditor(None)))}
          className="target-group__create w-full flex flex-col items-center justify-center relative bg-white border-2 border-dashed border-gray-300 p-6 z-10 hover:text-primary-500 hover:shadow-lg hover:border-primary-400 focus:outline-none focus:text-primary-500 focus:shadow-lg focus:border-primary-400 rounded-lg mt-12 cursor-pointer">
          <span className="flex bg-gray-50 p-2 rounded-full">
            <i className="fas fa-plus-circle text-2xl" />
          </span>
          <h4 className="font-semibold ms-2"> {t("create_target_group") |> str} </h4>
        </button>
      </div>
    </div>
  </div>
}
