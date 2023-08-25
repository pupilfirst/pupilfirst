open CurriculumEditor__Types

let str = React.string
type state = {
  name: string,
  levelId: option<string>,
  levelSearchInput: string,
  description: string,
  hasNameError: bool,
  dirty: bool,
  isArchived: bool,
  saving: bool,
}

let tr = I18n.t(~scope="components.CurriculumEditor__TargetGroupEditor")
let ts = I18n.t(~scope="shared")

type action =
  | UpdateName(string, bool)
  | UpdateDescription(string)
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
  Js.Dict.set(payload, "authenticity_token", AuthenticityToken.fromHead() |> Js.Json.string)
  Js.Dict.set(payload, "archived", state.isArchived |> Js.Json.boolean)
  Js.Dict.set(payload, "level_id", levelId |> Js.Json.string)
  Js.Dict.set(payload, "name", state.name |> Js.Json.string)
  Js.Dict.set(payload, "description", state.description |> Js.Json.string)
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
      <School__InputGroupError message={tr("choose_level")} active=true />,
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
    levelId,
    sortIndex,
    state.isArchived,
  )
  switch targetGroup {
  | Some(_) =>
    Notification.success(ts("notifications.success"), tr("target_group_updated_notificaion"))
  | None =>
    Notification.success(ts("notifications.success"), tr("target_group_created_notification"))
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
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-s-full rounded-e-none hover:text-gray-600 focus:outline-none mt-4">
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div className={formClasses(state.saving)}>
        <div className="w-full">
          <div className="mx-auto bg-white">
            <div className="max-w-2xl pt-6 px-6 mx-auto">
              <h5 className="uppercase text-center border-b border-gray-300 pb-2">
                {tr("group_details") |> str}
              </h5>
              <div className="mt-5">
                <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
                  {tr("title") |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  autoFocus=true
                  className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                  id="name"
                  type_="text"
                  placeholder={tr("title_placeholder")}
                  value=state.name
                  onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
                />
                {state.hasNameError
                  ? <div className="drawer-right-form__error-msg">
                      <span className="me-2"> <i className="fas fa-exclamation-triangle" /> </span>
                      <span> {tr("title_name_error") |> str} </span>
                    </div>
                  : React.null}
              </div>
              <div className="mt-5">
                <label className="block tracking-wide text-xs font-semibold" htmlFor="description">
                  {" " ++ tr("description") |> str}
                </label>
                <MarkdownEditor
                  tabIndex=2
                  textareaId="description"
                  onChange={markdown => send(UpdateDescription(markdown))}
                  value=state.description
                  placeholder={tr("description_placeholder")}
                  profile=Markdown.AreaOfText
                  maxLength=10000
                  fileUpload=false
                />
              </div>
              {levelEditor(state, levels, send)}
            </div>
            <div className="border-t bg-gray-50 mt-5">
              <div className="max-w-2xl p-6 mx-auto flex w-full justify-between items-center">
                {switch targetGroup {
                | Some(_) =>
                  <div className="flex items-center me-2">
                    <label className="block tracking-wide text-xs font-semibold me-6">
                      {tr("group_archived_q") |> str}
                    </label>
                    <div
                      className="toggle-button__group archived inline-flex shrink-0 overflow-hidden">
                      <button
                        onClick={_event => {
                          ReactEvent.Mouse.preventDefault(_event)
                          send(UpdateIsArchived(true))
                        }}
                        className={booleanButtonClasses(state.isArchived == true)}>
                        {ts("_yes") |> str}
                      </button>
                      <button
                        onClick={_event => {
                          ReactEvent.Mouse.preventDefault(_event)
                          send(UpdateIsArchived(false))
                        }}
                        className={booleanButtonClasses(state.isArchived == false)}>
                        {ts("_no") |> str}
                      </button>
                    </div>
                  </div>
                | None => React.null
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
                      {tr("update_group") |> str}
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
                      {tr("create_group") |> str}
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
