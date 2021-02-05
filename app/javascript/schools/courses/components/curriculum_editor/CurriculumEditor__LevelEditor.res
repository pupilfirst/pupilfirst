%bs.raw(`require("./CurriculumEditor__LevelEditor.css")`)

open CurriculumEditor__Types

let str = ReasonReact.string

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
}

type action =
  | UpdateName(string, bool)
  | UpdateUnlockAt(option<Js.Date.t>)
  | BeginSaving
  | FailSaving
  | UpdateTab(tab)
  | SelectLevelToMergeInto(string)

let reducer = (state, action) =>
  switch action {
  | UpdateName(name, hasNameError) => {
      ...state,
      name: name,
      hasNameError: hasNameError,
      dirty: true,
    }
  | UpdateUnlockAt(date) => {...state, unlockAt: date, dirty: true}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | UpdateTab(tab) => {...state, tab: tab}
  | SelectLevelToMergeInto(mergeIntoLevelId) => {...state, mergeIntoLevelId: mergeIntoLevelId}
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
    name: name,
    unlockAt: unlockAt,
    hasNameError: false,
    dirty: false,
    saving: false,
    tab: Details,
    mergeIntoLevelId: "0",
  }
}

let drawerTitle = level =>
  switch level {
  | Some(level) => "Edit Level " ++ Level.number(level)->string_of_int
  | None => "Create New Level"
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
  | Some(_) => Notification.success("Success", "Level updated successfully")
  | None => Notification.success("Success", "Level created successfully")
  }

  updateLevelsCB(newLevel)
}

let createLevel = (course, updateLevelsCB, state, send) => {
  send(BeginSaving)

  let handleErrorCB = () => send(FailSaving)
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

  let handleErrorCB = () => send(FailSaving)
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
        {"Level Name" |> str}
      </label>
      <input
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
        id="name"
        type_="text"
        placeholder="Type level name here"
        value=state.name
        onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
      />
      {state.hasNameError
        ? <div className="drawer-right-form__error-msg"> {"not a valid name" |> str} </div>
        : ReasonReact.null}
    </div>
    <div className="mt-5">
      <label className="tracking-wide text-xs font-semibold" htmlFor="unlock-on-input">
        {"Unlock level on" |> str}
      </label>
      <span className="text-xs"> {str(" (optional)")} </span>
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
          {"Update Level" |> str}
        </button>

      | None =>
        <button
          disabled={saveDisabled(state)}
          onClick={_event => createLevel(course, updateLevelsCB, state, send)}
          className="w-full btn btn-large btn-primary">
          {"Create New Level" |> str}
        </button>
      }}
    </div>
  </div>
}

let handleSelectLevelForDeletion = (send, event) => {
  let target = event |> ReactEvent.Form.target
  send(SelectLevelToMergeInto(target["value"]))
}

module MergeLevelsQuery = %graphql(
  `
  mutation MergeLevelsQuery($deleteLevelId: ID!, $mergeIntoLevelId: ID!) {
    mergeLevels(deleteLevelId: $deleteLevelId, mergeIntoLevelId: $mergeIntoLevelId) {
      success
    }
  }
`
)

let deleteSelectedLevel = (state, send, level, _event) =>
  WindowUtils.confirm("Are you sure? This action cannot be undone.", () => {
    send(BeginSaving)

    MergeLevelsQuery.make(
      ~deleteLevelId=Level.id(level),
      ~mergeIntoLevelId=state.mergeIntoLevelId,
      (),
    )
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(result => {
      if result["mergeLevels"]["success"] {
        DomUtils.reload()
      } else {
        send(FailSaving)
      }

      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      Notification.error(
        "Oops!",
        "Something went wrong when we tried to merge & delete this level. Please reload this page before trying again.",
      )
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
        {"Delete & Merge Into" |> str}
      </label>
      <HelpIcon className="ml-1 text-sm">
        {str(
          "Pick another level to merge this level into. This action will shift all targets and students in level.",
        )}
      </HelpIcon>
      <select
        id="delete-and-merge-level"
        onChange={handleSelectLevelForDeletion(send)}
        className="cursor-pointer appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
        value=state.mergeIntoLevelId>
        <option key="0" value="0"> {str("Select a different level")} </option>
        {otherLevels
        |> Array.map(level =>
          <option key={Level.id(level)} value={Level.id(level)}>
            {LevelLabel.format(~short=true, ~name=Level.name(level), (Level.number(level) |> string_of_int)) |> str}
          </option>
        )
        |> React.array}
      </select>
      <button
        disabled={state.mergeIntoLevelId == "0"}
        onClick={deleteSelectedLevel(state, send, level)}
        className="btn btn-primary mt-2">
        {str("Merge and Delete")}
      </button>
    </div>
  </div>
}

let tab = (tab, state, send) => {
  let defaultClasses = "level-editor__tab cursor-pointer"

  let (title, iconClass) = switch tab {
  | Actions => ("Actions", "fa-cogs")
  | Details => ("Details", "fa-list-alt")
  }

  let selected = tab == state.tab

  let classes = selected ? defaultClasses ++ " level-editor__tab--selected" : defaultClasses

  <button onClick={_e => send(UpdateTab(tab))} className=classes>
    <i className={"fas " ++ iconClass} /> <span className="ml-2"> {title |> str} </span>
  </button>
}

@react.component
let make = (~level, ~levels, ~course, ~hideEditorActionCB, ~updateLevelsCB) => {
  let (state, send) = React.useReducerWithMapState(reducer, level, computeInitialState)

  <SchoolAdmin__EditorDrawer closeDrawerCB=hideEditorActionCB>
    <DisablingCover disabled=state.saving>
      <div className="bg-gray-200 pt-6">
        <div className="max-w-2xl px-6 mx-auto"> <h3> {drawerTitle(level)->str} </h3> </div>
        {switch level {
        | Some(_) =>
          <div className="flex w-full max-w-2xl mx-auto px-6 text-sm -mb-px mt-2">
            {tab(Details, state, send)} {tab(Actions, state, send)}
          </div>
        | None => <div className="h-4" />
        }}
      </div>
      <div className="bg-white">
        <div className="border-t border-gray-400">
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
