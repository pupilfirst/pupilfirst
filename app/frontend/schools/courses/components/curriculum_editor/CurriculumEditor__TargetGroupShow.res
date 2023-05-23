open CurriculumEditor__Types

let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetGroupShow")

type state = {
  targetTitle: string,
  savingNewTarget: bool,
  validTargetTitle: bool,
}

module CreateTargetMutation = %graphql(`
   mutation CreateTargetMutation($title: String!, $targetGroupId: String!) {
     createTarget(title: $title, targetGroupId: $targetGroupId ) {
       target {
         id
         contentBlockId
         sampleContent
       }
     }
   }
   `)

type action =
  | UpdateTargetTitle(string)
  | UpdateTargetSaving

let reducer = (state, action) =>
  switch action {
  | UpdateTargetTitle(targetTitle) => {
      ...state,
      targetTitle: targetTitle,
      validTargetTitle: targetTitle |> String.length > 1,
    }
  | UpdateTargetSaving => {...state, savingNewTarget: !state.savingNewTarget}
  }

let archivedClasses = archived =>
  "target-group__header flex flex-col items-center justify-center relative cursor-pointer px-20 pb-7 text-center rounded-lg rounded-b-none overflow-hidden w-full " ++ (
    archived ? "target-group__header--archived" : ""
  )

let updateSortIndex = (targetGroups, targetGroup, up, updateTargetGroupSortIndexCB) => {
  let index = Js.Array.indexOf(targetGroup, targetGroups)

  let newTargetGroups = up
    ? ArrayUtils.swapUp(index, targetGroups)
    : ArrayUtils.swapDown(index, targetGroups)

  let targetGroupIds = Js.Array.map(TargetGroup.id, newTargetGroups)

  CurriculumEditor__SortResourcesMutation.sort(
    CurriculumEditor__SortResourcesMutation.TargetGroup,
    targetGroupIds,
  )

  updateTargetGroupSortIndexCB(newTargetGroups)
}

let sortIndexHiddenClass = bool => bool ? " invisible" : ""

@react.component
let make = (
  ~targetGroup,
  ~targetGroups,
  ~targets,
  ~showTargetGroupEditorCB,
  ~updateTargetCB,
  ~showArchived,
  ~updateTargetSortIndexCB,
  ~updateTargetGroupSortIndexCB,
  ~index,
  ~course,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {targetTitle: "", savingNewTarget: false, validTargetTitle: false},
  )
  let targetGroupArchived = targetGroup |> TargetGroup.archived

  let targetsInGroup =
    targets
    |> Js.Array.filter(target => Target.targetGroupId(target) == TargetGroup.id(targetGroup))
    |> Target.sort

  let targetsToDisplay = showArchived
    ? targetsInGroup
    : targetsInGroup |> Js.Array.filter(target => !(Target.visibility(target) == Archived))

  let handleResponseCB = target => {
    let targetId = target["id"]
    let targetGroupId = targetGroup |> TargetGroup.id
    /* let sortIndex = json |> Json.Decode.(field("sortIndex", int)); */
    let newTarget = Target.template(targetId, targetGroupId, state.targetTitle)
    send(UpdateTargetSaving)
    send(UpdateTargetTitle(""))
    updateTargetCB(newTarget)
  }
  let handleCreateTarget = (title, targetGroupId) => {
    send(UpdateTargetSaving)

    CreateTargetMutation.make({title: title, targetGroupId: targetGroupId})
    |> Js.Promise.then_(response => {
      switch response["createTarget"]["target"] {
      | Some(target) => handleResponseCB(target)
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }

  <div
    className="target-group__box relative mt-12 rounded-lg border border-b-0 border-gray-300 shadow-md">
    <div
      className="w-full target-group__header-container rounded-lg rounded-b-none relative bg-white hover:bg-gray-50 hover:text-primary-500">
      <div
        id="target_group"
        className={archivedClasses(targetGroup |> TargetGroup.archived)}
        onClick={_event => showTargetGroupEditorCB(Some(targetGroup))}>
        <div className="target-group__title pt-6 font-semibold text-lg">
          <h4> {targetGroup |> TargetGroup.name |> str} </h4>
        </div>
        {switch TargetGroup.description(targetGroup) {
        | Some(description) =>
          <div className="target-group__description">
            <MarkdownBlock
              className="text-sm pt-px" markdown=description profile=Markdown.AreaOfText
            />
          </div>
        | None => React.null
        }}
      </div>
      {targetGroups |> Js.Array.length > 1
        ? <div
            className="target-group__group-reorder flex flex-col shadow rounded-l-lg absolute h-full border border-e-0 overflow-hidden text-gray-600 justify-between items-center bg-white">
            <button
              title={t("move_up")}
              ariaLabel={t("move_up")}
              id={"target-group-move-up-" ++ (targetGroup |> TargetGroup.id)}
              className={"target-group__group-reorder-up flex items-center justify-center cursor-pointer w-9 h-9 p-1 text-gray-400 hover:bg-gray-50 focus:outline-none focus:bg-gray-50 focus:text-primary-500" ++
              sortIndexHiddenClass(index == 0)}
              onClick={_ =>
                updateSortIndex(targetGroups, targetGroup, true, updateTargetGroupSortIndexCB)}>
              <i className="fas fa-arrow-up text-sm" />
            </button>
            <button
              title={t("move_down")}
              ariaLabel={t("move_down")}
              id={"target-group-move-down-" ++ (targetGroup |> TargetGroup.id)}
              className={"target-group__group-reorder-down flex items-center justify-center cursor-pointer w-9 h-9 p-1 text-gray-400 hover:bg-gray-50 focus:outline-none focus:bg-gray-50 focus:text-primary-500" ++
              sortIndexHiddenClass(index + 1 == Js.Array.length(targetGroups))}
              onClick={_ =>
                updateSortIndex(targetGroups, targetGroup, false, updateTargetGroupSortIndexCB)}>
              <i className="fas fa-arrow-down text-sm" />
            </button>
          </div>
        : React.null}
    </div>
    {targetsToDisplay
    |> Js.Array.mapi((target, index) =>
      <CurriculumEditor__TargetShow
        key={Target.id(target)} target targets=targetsToDisplay updateTargetSortIndexCB index course
      />
    )
    |> React.array}
    {targetGroupArchived
      ? React.null
      : <div
          className="target-group__target-create relative bg-gray-50 flex items-center border border-dashed border-gray-300 text-gray-600 hover:text-gray-900 active:text-gray-900 focus:text-gray-900 hover:shadow-lg hover:border-gray-500 rounded-lg rounded-t-none overflow-hidden">
          <label
            htmlFor={"create-target-input" ++ (targetGroup |> TargetGroup.id)}
            className="absolute flex items-center h-full cursor-pointer ps-4 ">
            <i className="fas fa-plus-circle text-2xl" />
          </label>
          <input
            id={"create-target-input" ++ (targetGroup |> TargetGroup.id)}
            title={t("create_a_target")}
            value=state.targetTitle
            onChange={event => send(UpdateTargetTitle(ReactEvent.Form.target(event)["value"]))}
            placeholder={t("create_target")}
            className="target-create__input  bg-gray-50 pe-5 ps-12 py-6 rounded-b appearance-none block w-full text-sm text-gray-900 font-medium leading-tight hover:bg-gray-50 focus:outline-none focus:bg-white focus:border-gray-500"
          />
          {state.validTargetTitle
            ? <button
                onClick={_e => handleCreateTarget(state.targetTitle, targetGroup |> TargetGroup.id)}
                disabled=state.savingNewTarget
                className="flex items-center whitespace-nowrap text-sm font-medium py-2 px-4 me-4 rounded btn-primary appearance-none focus:outline-none text-center">
                {t("create") |> str}
              </button>
            : React.null}
        </div>}
  </div>
}
