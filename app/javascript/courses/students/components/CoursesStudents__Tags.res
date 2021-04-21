open CoursesStudents__Types

type state = {
  tagsToApply: array<string>,
  saving: bool,
}

type action =
  | AddTag(string)
  | RemoveTag(string)
  | UpdateSaving(bool)

let str = React.string

let handleErrorCB = (send, ()) => send(UpdateSaving(false))

let handleResponseCB = (updateFormCB, state, team, _json) => {
  updateFormCB(state.tagsToApply, team)
  Notification.success(
    "Success",
    "Student updated successfully",
  )
}

let updateStudent = (student, team, state, send, responseCB) => {
  send(UpdateSaving(true))
  let payload = Js.Dict.empty()

  Js.Dict.set(payload, "authenticity_token", AuthenticityToken.fromHead() |> Js.Json.string)

  Js.Dict.set(
    payload,
    "tags",
    state.tagsToApply |> {
      open Json.Encode
      array(string)
    },
  )

  let url = "/school/students/1"
  Api.update(url, payload, responseCB, handleErrorCB(send))
}

let initialState = (team) => {
  tagsToApply: team |> TeamInfo.tags,
  saving: false,
}

let reducer = (state, action) =>
  switch action {
  | AddTag(tag) => {
      ...state,
      tagsToApply: state.tagsToApply |> Array.append([tag]),
    }
  | RemoveTag(tag) => {
      ...state,
      tagsToApply: state.tagsToApply |> Js.Array.filter(t => t !== tag),
    }
  | UpdateSaving(bool) => {...state, saving: bool}
  }

@react.component
let make = (~student, ~team, ~teamTags, ~updateFormCB) => {
  let (state, send) = React.useReducer(reducer, initialState(team))
  let isSingleStudent = team |> TeamInfo.isSingleStudent

  <div className="mt-3 text-sm">
    <div className="mb-2 text-xs font-semibold">
      {(isSingleStudent ? "Tags applied:" : "Tags applied to team:") |> str}
    </div>
    <DisablingCover disabled=state.saving message="Saving...">
      <StudentsEditor__SearchableTagList
        unselectedTags={teamTags |> Js.Array.filter(tag =>
          !(state.tagsToApply |> Array.mem(tag))
        )}
        selectedTags=state.tagsToApply
        addTagCB={tag => send(AddTag(tag))}
        removeTagCB={tag => send(RemoveTag(tag))}
        allowNewTags=true
      />
      <div className="my-5 w-auto">
        <button
          onClick={_e =>
            updateStudent(student, team, state, send, handleResponseCB(updateFormCB, state, team))}
          className="btn btn-primary">
          {"Update student's tags" |> str}
        </button>
      </div>
    </DisablingCover>
  </div>
}
