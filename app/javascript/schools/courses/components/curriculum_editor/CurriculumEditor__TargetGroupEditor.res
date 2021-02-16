open CurriculumEditor__Types

let str = ReasonReact.string
type state = {
  name: string,
  levelId: option<string>,
  levelSearchInput: string,
  description: string,
  milestone: bool,
  hasNameError: bool,
  dirty: bool,
  isArchived: bool,
  saving: bool,
}

let ts = I18n.t(~scope="shared")

type action =
  | UpdateName(string, bool)
  | UpdateDescription(string)
  | UpdateMilestone(bool)
  | UpdateIsArchived(bool)
  | SetLevel(string)
  | ClearLevel
  | UpdateLevelSearchInput(string)
  | UpdateSaving

let reducer = (state, action) =>
  switch action {
  | UpdateName(name, hasNameError) => {
      ...state,
      name: name,
      hasNameError: hasNameError,
      dirty: true,
    }
  | UpdateDescription(description) => {...state, description: description, dirty: true}
  | UpdateMilestone(milestone) => {...state, milestone: milestone, dirty: true}
  | UpdateIsArchived(isArchived) => {...state, isArchived: isArchived, dirty: true}
  | SetLevel(levelId) => {
      ...state,
      levelId: Some(levelId),
      levelSearchInput: "",
      dirty: true,
    }
  | ClearLevel => {...state, levelId: None, dirty: true}
  | UpdateLevelSearchInput(levelSearchInput) => {
      ...state,
      levelSearchInput: levelSearchInput,
      dirty: true,
    }
  | UpdateSaving => {...state, saving: !state.saving}
  }

let updateName = (send, name) => {
  let hasError = name |> String.length < 2
  send(UpdateName(name, hasError))
}

let saveDisabled = state =>
  state.hasNameError ||
  (!state.dirty ||
  (state.saving || state.levelId->Belt.Option.mapWithDefault(true, _ => false)))

let setPayload = (state, levelId) => {
  let payload = Js.Dict.empty()
  let milestone = state.milestone == true ? "true" : "false"
  Js.Dict.set(payload, "authenticity_token", AuthenticityToken.fromHead() |> Js.Json.string)
  Js.Dict.set(payload, "archived", state.isArchived |> Js.Json.boolean)
  Js.Dict.set(payload, "level_id", levelId |> Js.Json.string)
  Js.Dict.set(payload, "name", state.name |> Js.Json.string)
  Js.Dict.set(payload, "description", state.description |> Js.Json.string)
  Js.Dict.set(payload, "milestone", milestone |> Js.Json.string)
  payload
}

module SelectableLevel = {
  type t = Level.t

  let label = _t => None

  let value = t => t |> Level.levelNumberWithName

  let searchString = t => t |> value

  let color = _t => "orange"
}

module LevelSelector = MultiselectDropdown.Make(SelectableLevel)

let unselectedlevels = (levels, levelId) =>
  levelId->Belt.Option.mapWithDefault(levels, levelId =>
    levels |> Js.Array.filter(l => l |> Level.id != levelId)
  )

let selectedLevel = (levels, levelId) =>
  levelId->Belt.Option.mapWithDefault([], levelId => [
    levelId |> Level.unsafeFind(levels, "TargetGroupEditor.selectedTargetGroup"),
  ])

let levelEditor = (state, levels, send) =>
  <div id="level_id" className="mt-5">
    <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="level_id">
      {ts("level") |> str}
    </label>
    <LevelSelector
      id="level_id"
      unselected={unselectedlevels(levels, state.levelId)}
      selected={selectedLevel(levels, state.levelId)}
      onSelect={selectable => send(SetLevel(selectable |> Level.id))}
      onDeselect={_ => send(ClearLevel)}
      value=state.levelSearchInput
      onChange={searchString => send(UpdateLevelSearchInput(searchString))}
    />
    {state.levelId->Belt.Option.mapWithDefault(
      <School__InputGroupError message="Choose a level" active=true />,
      _ => React.null,
    )}
  </div>

let booleanButtonClasses = selected => {
  let classes = "toggle-button__button"
  classes ++ (selected ? " toggle-button__button--active" : "")
}
let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full"

let handleErrorCB = (send, _) => send(UpdateSaving)

let handleResponseCB = (state, levelId, targetGroup, updateTargetGroupsCB, json) => {
  let id = json |> {
    open Json.Decode
    field("id", string)
  }
  let sortIndex = json |> {
    open Json.Decode
    field("sortIndex", int)
  }
  let newTargetGroup = TargetGroup.create(
    id,
    state.name,
    Some(state.description),
    state.milestone,
    levelId,
    sortIndex,
    state.isArchived,
  )
  switch targetGroup {
  | Some(_) => Notification.success("Success", "Target Group updated successfully")
  | None => Notification.success("Success", "Target Group created successfully")
  }
  updateTargetGroupsCB(newTargetGroup)
}

let createTargetGroup = (state, send, targetGroup, updateTargetGroupsCB, currentLevelId) => {
  send(UpdateSaving)
  let levelId = state.levelId->Belt.Option.mapWithDefault(currentLevelId, l => l)
  let payload = setPayload(state, levelId)
  let url = "/school/levels/" ++ (levelId ++ "/target_groups")
  Api.create(
    url,
    payload,
    handleResponseCB(state, levelId, targetGroup, updateTargetGroupsCB),
    handleErrorCB(send),
  )
}

let updateTargetGroup = (
  state,
  send,
  targetGroup,
  updateTargetGroupsCB,
  currentLevelId,
  targetGroupId,
) => {
  send(UpdateSaving)
  let levelId = state.levelId->Belt.Option.mapWithDefault(currentLevelId, l => l)
  let payload = setPayload(state, levelId)
  let url = "/school/target_groups/" ++ targetGroupId
  Api.update(
    url,
    payload,
    handleResponseCB(state, levelId, targetGroup, updateTargetGroupsCB),
    handleErrorCB(send),
  )
}

let computeInitialState = (currentLevelId, targetGroup) =>
  switch targetGroup {
  | Some(targetGroup) => {
      name: targetGroup |> TargetGroup.name,
      description: switch targetGroup |> TargetGroup.description {
      | Some(description) => description
      | None => ""
      },
      levelId: Some(targetGroup |> TargetGroup.levelId),
      levelSearchInput: "",
      milestone: targetGroup |> TargetGroup.milestone,
      hasNameError: false,
      dirty: false,
      isArchived: targetGroup |> TargetGroup.archived,
      saving: false,
    }
  | None => {
      name: "",
      description: "",
      levelId: Some(currentLevelId),
      levelSearchInput: "",
      milestone: true,
      hasNameError: false,
      dirty: false,
      isArchived: false,
      saving: false,
    }
  }

@react.component
let make = (~targetGroup, ~currentLevelId, ~levels, ~updateTargetGroupsCB, ~hideEditorActionCB) => {
  let (state, send) = React.useReducerWithMapState(
    reducer,
    targetGroup,
    computeInitialState(currentLevelId),
  )
  <div>
    <div className="blanket" />
    <div className="drawer-right">
      <div className="drawer-right__close absolute">
        <button
          title="close"
          onClick={_ => hideEditorActionCB()}
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-600 focus:outline-none mt-4">
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div className={formClasses(state.saving)}>
        <div className="w-full">
          <div className="mx-auto bg-white">
            <div className="max-w-2xl pt-6 px-6 mx-auto">
              <h5 className="uppercase text-center border-b border-gray-400 pb-2">
                {"Target Group Details" |> str}
              </h5>
              <div className="mt-5">
                <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
                  {"Title" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  id="name"
                  type_="text"
                  placeholder="Type target group name here"
                  value=state.name
                  onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
                />
                {state.hasNameError
                  ? <div className="drawer-right-form__error-msg">
                      <span className="mr-2"> <i className="fas fa-exclamation-triangle" /> </span>
                      <span> {"not a valid Title" |> str} </span>
                    </div>
                  : ReasonReact.null}
              </div>
              <div className="mt-5">
                <label className="block tracking-wide text-xs font-semibold" htmlFor="description">
                  {" Description" |> str}
                </label>
                <MarkdownEditor
                  tabIndex=2
                  textareaId="description"
                  onChange={markdown => send(UpdateDescription(markdown))}
                  value=state.description
                  placeholder="Type target group description"
                  profile=Markdown.AreaOfText
                  maxLength=10000
                  fileUpload=false
                />
              </div>
              {levelEditor(state, levels, send)}
              <div className="mt-5">
                <div className="flex items-center flex-shrink-0">
                  <label className="block tracking-wide text-xs font-semibold mr-3">
                    {"Is this a milestone target group?" |> str}
                  </label>
                  <div
                    className="milestone flex-shrink-0 rounded-lg overflow-hidden border border-gray-400">
                    <button
                      onClick={_event => {
                        ReactEvent.Mouse.preventDefault(_event)
                        send(UpdateMilestone(true))
                      }}
                      className={booleanButtonClasses(state.milestone == true)}>
                      {"Yes" |> str}
                    </button>
                    <button
                      onClick={_event => {
                        ReactEvent.Mouse.preventDefault(_event)
                        send(UpdateMilestone(false))
                      }}
                      className={booleanButtonClasses(state.milestone == false)}>
                      {"No" |> str}
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <div className="border-t bg-gray-100 mt-5">
              <div className="max-w-2xl p-6 mx-auto flex w-full justify-between items-center">
                {switch targetGroup {
                | Some(_) =>
                  <div className="flex items-center mr-2">
                    <label className="block tracking-wide text-xs font-semibold mr-6">
                      {"Is this target group archived?" |> str}
                    </label>
                    <div
                      className="toggle-button__group archived inline-flex flex-shrink-0 rounded-lg overflow-hidden">
                      <button
                        onClick={_event => {
                          ReactEvent.Mouse.preventDefault(_event)
                          send(UpdateIsArchived(true))
                        }}
                        className={booleanButtonClasses(state.isArchived == true)}>
                        {"Yes" |> str}
                      </button>
                      <button
                        onClick={_event => {
                          ReactEvent.Mouse.preventDefault(_event)
                          send(UpdateIsArchived(false))
                        }}
                        className={booleanButtonClasses(state.isArchived == false)}>
                        {"No" |> str}
                      </button>
                    </div>
                  </div>
                | None => ReasonReact.null
                }}
                {switch targetGroup {
                | Some(targetGroup) =>
                  let id = targetGroup |> TargetGroup.id
                  <div className="w-auto">
                    <button
                      disabled={saveDisabled(state)}
                      onClick={_e =>
                        updateTargetGroup(
                          state,
                          send,
                          Some(targetGroup),
                          updateTargetGroupsCB,
                          currentLevelId,
                          id,
                        )}
                      className="btn btn-primary btn-large">
                      {"Update Target Group" |> str}
                    </button>
                  </div>

                | None =>
                  <div className="w-full">
                    <button
                      disabled={saveDisabled(state)}
                      onClick={_e =>
                        createTargetGroup(
                          state,
                          send,
                          targetGroup,
                          updateTargetGroupsCB,
                          currentLevelId,
                        )}
                      className="w-full btn btn-primary btn-large">
                      {"Create Target Group" |> str}
                    </button>
                  </div>
                }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}
