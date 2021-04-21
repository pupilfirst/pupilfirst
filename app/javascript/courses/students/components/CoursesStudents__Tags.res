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

module UpdateTeamTagsMutation = %graphql(
  `
   mutation UpdateTeamTagsMutation($teamId: ID!, $tags: [String!]) {
    updateTeamTags(teamId: $teamId, tags: $tags) {
      success
    }
  }
  `
)

let updateTags = (team, state, send, updateCB) => {
  send(UpdateSaving(true))
  UpdateTeamTagsMutation.make(~teamId=team |> TeamInfo.id, ~tags=state.tagsToApply, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    if (response["updateTeamTags"]["success"]) {
      updateCB()
    }
    send(UpdateSaving(false))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    send(UpdateSaving(false))
    Js.Promise.resolve()
  })
  |> ignore
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
let make = (~team, ~teamTags, ~updateCB) => {
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
            updateTags(team, state, send, updateCB)}
          className="btn btn-primary">
          {"Update tags" |> str}
        </button>
      </div>
    </DisablingCover>
  </div>
}
