%%raw(`import "./CurriculumEditor__LevelEditor.css"`)

let t = I18n.t(~scope="components.CurriculumEditor__LevelEditor")

open CurriculumEditor__Types

let str = React.string

type tab =
  | Details
  | Actions

type state = {
  name: string,
  unlockAt: option<Js.Date.t>,
  hasNameError: bool,
  dirty: bool,
  saving: bool,
  tab: tab,
  mergeIntoLevelId: string,
  cloneIntoCourseId: string,
}

type action =
  | UpdateName(string, bool)
  | UpdateUnlockAt(option<Js.Date.t>)
  | BeginSaving
  | FinishSaving
  | UpdateTab(tab)
  | SelectLevelToMergeInto(string)
  | SelectCourseToCloneInto(string)

let reducer = (state, action) =>
  switch action {
  | UpdateName(name, hasNameError) => {
      ...state,
      name,
      hasNameError,
      dirty: true,
    }
  | UpdateUnlockAt(date) => {...state, unlockAt: date, dirty: true}
  | BeginSaving => {...state, saving: true}
  | FinishSaving => {...state, saving: false}
  | UpdateTab(tab) => {...state, tab}
  | SelectLevelToMergeInto(mergeIntoLevelId) => {...state, mergeIntoLevelId}
  | SelectCourseToCloneInto(cloneIntoCourseId) => {...state, cloneIntoCourseId}
  }

let updateName = (send, name) => {
  let hasError = name |> String.trim |> String.length < 2
  send(UpdateName(name, hasError))
}

let saveDisabled = state => state.hasNameError || (!state.dirty || state.saving)

let setPayload = (authenticityToken, state) => {
  let payload = Js.Dict.empty()

  Js.Dict.set(payload, "authenticity_token", authenticityToken |> Js.Json.string)

  Js.Dict.set(payload, "name", state.name |> Js.Json.string)

  Js.Dict.set(
    payload,
    "unlock_at",
    state.unlockAt->Belt.Option.mapWithDefault(Js.Json.string(""), DateFns.encodeISO),
  )

  payload
}
let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full"

let computeInitialState = level => {
  let (name, unlockAt) = switch level {
  | Some(level) => (level |> Level.name, level |> Level.unlockAt)
  | None => ("", None)
  }

  {
    name,
    unlockAt,
    hasNameError: false,
    dirty: false,
    saving: false,
    tab: Details,
    mergeIntoLevelId: "0",
    cloneIntoCourseId: "0",
  }
}

let drawerTitle = level =>
  switch level {
  | Some(level) => t(~variables=[("number", Level.number(level)->string_of_int)], "edit_level")
  | None => t("create_level")
  }

let handleResponseCB = (level, updateLevelsCB, state, json) => {
  let id = json |> {
    open Json.Decode
    field("id", string)
  }
  let number = json |> {
    open Json.Decode
    field("number", int)
  }
  let newLevel = Level.create(id, state.name, number, state.unlockAt)

  switch level {
  | Some(_) => Notification.success(t("success"), t("update_success"))
  | None => Notification.success(t("success"), t("create_success"))
  }

  updateLevelsCB(newLevel)
}

let createLevel = (course, updateLevelsCB, state, send) => {
  send(BeginSaving)

  let handleErrorCB = () => send(FinishSaving)
  let url = "/school/courses/" ++ (Course.id(course) ++ "/levels")

  Api.create(
    url,
    setPayload(AuthenticityToken.fromHead(), state),
    handleResponseCB(None, updateLevelsCB, state),
    handleErrorCB,
  )
}

let updateLevel = (level, updateLevelsCB, state, send) => {
  send(BeginSaving)

  let handleErrorCB = () => send(FinishSaving)
  let url = "/school/levels/" ++ Level.id(level)

  Api.update(
    url,
    setPayload(AuthenticityToken.fromHead(), state),
    handleResponseCB(Some(level), updateLevelsCB, state),
    handleErrorCB,
  )
}

let detailsForm = (level, course, updateLevelsCB, state, send) => {
  let visibiltyClass = switch state.tab {
  | Details => None
  | Actions => Some("hidden")
  }

  <div className=?visibiltyClass>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
        {t("level_name_label") |> str}
      </label>
      <input
        autoFocus=true
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="name"
        type_="text"
        placeholder={t("level_name_placeholder")}
        value=state.name
        onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
      />
      {state.hasNameError
        ? <div className="drawer-right-form__error-msg"> {t("level_name_invalid") |> str} </div>
        : React.null}
    </div>
    <div className="mt-5">
      <label className="tracking-wide text-xs font-semibold" htmlFor="unlock-on-input">
        {t("unlock_on_label") |> str}
      </label>
      <span className="text-xs"> {str(t("optional"))} </span>
      <DatePicker
        id="unlock-on-input" selected=?state.unlockAt onChange={date => send(UpdateUnlockAt(date))}
      />
    </div>
    <div className="flex mt-5">
      {switch level {
      | Some(level) =>
        <button
          disabled={saveDisabled(state)}
          onClick={_event => updateLevel(level, updateLevelsCB, state, send)}
          className="w-full btn btn-large btn-primary">
          {t("update_level") |> str}
        </button>

      | None =>
        <button
          disabled={saveDisabled(state)}
          onClick={_event => createLevel(course, updateLevelsCB, state, send)}
          className="w-full btn btn-large btn-primary">
          {t("create_level") |> str}
        </button>
      }}
    </div>
  </div>
}

let handleSelectLevelForDeletion = (send, event) => {
  let target = event |> ReactEvent.Form.target
  send(SelectLevelToMergeInto(target["value"]))
}

module MergeLevelsQuery = %graphql(`
  mutation MergeLevelsQuery($deleteLevelId: ID!, $mergeIntoLevelId: ID!) {
    mergeLevels(deleteLevelId: $deleteLevelId, mergeIntoLevelId: $mergeIntoLevelId) {
      success
    }
  }
`)

let deleteSelectedLevel = (state, send, level, _event) =>
  WindowUtils.confirm(t("merge_levels_confirm"), () => {
    send(BeginSaving)

    MergeLevelsQuery.make(
      MergeLevelsQuery.makeVariables(
        ~deleteLevelId=Level.id(level),
        ~mergeIntoLevelId=state.mergeIntoLevelId,
        (),
      ),
    )
    |> Js.Promise.then_(result => {
      if result["mergeLevels"]["success"] {
        DomUtils.reload()
      } else {
        send(FinishSaving)
      }

      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      Notification.error(t("actions_error_title"), t("merge_levels_error_message"))
      Js.Promise.resolve()
    })
    |> ignore
  })

let handleSelectCourseForCloneInto = (send, courseId) => {
  send(SelectCourseToCloneInto(courseId))
}

module CloneLevelQuery = %graphql(`
  mutation CloneLevelQuery($levelId: ID!, $cloneIntoCourseId: ID!) {
    cloneLevel(levelId: $levelId, cloneIntoCourseId: $cloneIntoCourseId) {
      success
    }
  }
`)

let cloneSelectedLevel = (state, send, level, _event) =>
  WindowUtils.confirm(t("clone_level_confirm"), () => {
    send(BeginSaving)

    CloneLevelQuery.make({
      levelId: Level.id(level),
      cloneIntoCourseId: state.cloneIntoCourseId,
    })
    |> Js.Promise.then_(_result => {
      send(FinishSaving)
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      Notification.error(t("actions_error_title"), t("clone_level_error_message"))
      Js.Promise.resolve()
    })
    |> ignore
  })

let actionsForm = (level, levels, state, send) => {
  let visibiltyClass = switch state.tab {
  | Details => Some("hidden")
  | Actions => None
  }

  let otherLevels = Js.Array.filter(
    l => Level.id(level) != Level.id(l) && Level.number(l) != 0,
    levels,
  )
  <div className=?visibiltyClass>
    <div className="mt-5">
      <label
        className="inline-block tracking-wide text-xs font-semibold"
        htmlFor="delete-and-merge-level">
        {t("merge_levels_label") |> str}
      </label>
      <HelpIcon className="ms-1 text-sm"> {str(t("merge_levels_hint"))} </HelpIcon>
      <select
        id="delete-and-merge-level"
        onChange={handleSelectLevelForDeletion(send)}
        className="cursor-pointer appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        value=state.mergeIntoLevelId>
        <option key="0" value="0"> {str(t("merge_levels_select"))} </option>
        {otherLevels
        |> Array.map(level =>
          <option key={Level.id(level)} value={Level.id(level)}>
            {LevelLabel.format(
              ~short=true,
              ~name=Level.name(level),
              Level.number(level) |> string_of_int,
            ) |> str}
          </option>
        )
        |> React.array}
      </select>
      <button
        disabled={state.mergeIntoLevelId == "0"}
        onClick={deleteSelectedLevel(state, send, level)}
        className="btn btn-primary mt-2">
        {str(t("merge_levels_button"))}
      </button>
    </div>
    {Toggle.enabled("clone_level")
      ? <div className="mt-5 pt-1 border-t">
          <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="clone-level">
            {t("clone_level_label") |> str}
          </label>
          <HelpIcon className="ms-1 text-sm"> {str(t("clone_level_hint"))} </HelpIcon>
          <CourseSelect
            id="clone-level"
            onChange={handleSelectCourseForCloneInto(send)}
            value=state.cloneIntoCourseId
          />
          <button
            disabled={state.cloneIntoCourseId == "0"}
            onClick={cloneSelectedLevel(state, send, level)}
            className="btn btn-primary mt-2">
            {str(t("clone_level_button"))}
          </button>
        </div>
      : React.null}
  </div>
}

let tab = (tab, state, send) => {
  let defaultClasses = "level-editor__tab cursor-pointer focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500"

  let (title, iconClass) = switch tab {
  | Actions => (t("tabs.actions"), "fa-cogs")
  | Details => (t("tabs.details"), "fa-list-alt")
  }

  let selected = tab == state.tab

  let classes = selected ? defaultClasses ++ " level-editor__tab--selected" : defaultClasses

  <button onClick={_e => send(UpdateTab(tab))} className=classes>
    <i className={"fas " ++ iconClass} />
    <span className="ms-2"> {title |> str} </span>
  </button>
}

@react.component
let make = (~level, ~levels, ~course, ~hideEditorActionCB, ~updateLevelsCB) => {
  let (state, send) = React.useReducerWithMapState(reducer, level, computeInitialState)

  <SchoolAdmin__EditorDrawer closeDrawerCB=hideEditorActionCB>
    <DisablingCover disabled=state.saving>
      <div className="bg-white  border-t border-gray-200 pt-6">
        <div className="max-w-2xl px-6 mx-auto">
          <h3> {drawerTitle(level)->str} </h3>
        </div>
        {switch level {
        | Some(_) =>
          <div className="flex w-full max-w-2xl mx-auto px-6 text-sm -mb-px mt-2">
            {tab(Details, state, send)}
            {tab(Actions, state, send)}
          </div>
        | None => <div className="h-4" />
        }}
      </div>
      <div className="bg-white">
        <div className="border-t border-gray-300">
          <div className="max-w-2xl mx-auto px-6">
            {detailsForm(level, course, updateLevelsCB, state, send)}
            {switch level {
            | Some(level) => actionsForm(level, levels, state, send)
            | None => React.null
            }}
          </div>
        </div>
      </div>
    </DisablingCover>
  </SchoolAdmin__EditorDrawer>
}
