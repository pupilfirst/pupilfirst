open StudentsEditor__Types

type state = {
  teamsToAdd: array<TeamInfo.t>,
  notifyStudents: bool,
  saving: bool,
}

type action =
  | AddStudentInfo(StudentInfo.t, option<string>, array<string>)
  | RemoveStudentInfo(StudentInfo.t)
  | ToggleNotifyStudents
  | SetSaving(bool)

let str = React.string
let t = I18n.t(~scope="components.StudentsEditor__CreateForm")

let formInvalid = state => ArrayUtils.isEmpty(state.teamsToAdd)

/* Get the tags applied to a list of students. */
let appliedTags = teams =>
  teams
  |> Array.map(team => team |> TeamInfo.tags |> Array.to_list)
  |> Array.to_list
  |> List.flatten
  |> ListUtils.distinct
  |> Array.of_list

/*
 * This is a union of tags reported by the parent component, and tags currently applied to students listed in the form. This allows the
 * form to suggest tags that haven't yet been persisted, but have been applied to at least one of the students in the list.
 */
let allKnownTags = (incomingTags, appliedTags) =>
  incomingTags |> Js.Array.concat(appliedTags) |> ArrayUtils.distinct

let handleResponseCB = (submitCB, state, studentIds) => {
  let studentsAdded = Js.Array.length(studentIds)

  if studentsAdded == 0 {
    Notification.notice(t("added_none_title"), t("added_none_description"))
  } else {
    let studentsRequested = Js.Array.reduce(
      (acc, team) => {acc + TeamInfo.students(team)->Js.Array.length},
      0,
      state.teamsToAdd,
    )

    if studentsAdded == studentsRequested {
      Notification.success(t("done_exclamation"), t("added_full_description"))
    } else {
      let description = t(
        ~variables=[
          ("students_added", string_of_int(studentsAdded)),
          ("students_requested", string_of_int(studentsRequested)),
        ],
        "added_partial_description",
      )
      Notification.notice(t("added_partial_title"), description)
    }
  }

  appliedTags(state.teamsToAdd)->submitCB
}

module CreateStudentsQuery = %graphql(
  `
  mutation CreateStudentsMutation($courseId: ID!, $notifyStudents: Boolean!, $students: [StudentEnrollmentInput!]!) {
    createStudents(courseId: $courseId, notifyStudents: $notifyStudents, students: $students) {
      studentIds
    }
  }
  `
)

let createStudents = (state, send, courseId, submitFormCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send(SetSaving(true))

  let students = Js.Array.map(TeamInfo.toJsArray, state.teamsToAdd) |> ArrayUtils.flattenV2
  let {notifyStudents} = state

  CreateStudentsQuery.make(~courseId, ~notifyStudents, ~students, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    switch response["createStudents"]["studentIds"] {
    | Some(studentIds) => handleResponseCB(submitFormCB, state, studentIds)
    | None => send(SetSaving(false))
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    Notification.error(
      "Unexpected Error!",
      "Our team has been notified of this failure. Please reload this page before trying to add students again.",
    )
    send(SetSaving(false))
    Js.Promise.resolve()
  })
  |> ignore
}

let teamHeader = (teamName, studentsCount) =>
  <div className="flex justify-between mb-1">
    <span className="text-tiny font-semibold">
      <span> {t(~variables=[("team_name", teamName)], "team_header_label")->str} </span>
    </span>
    {studentsCount < 2
      ? <span className="text-tiny">
          <i className="fas fa-exclamation-triangle text-orange-600 mr-1" />
          {t("team_header_add_more_members")->str}
        </span>
      : React.null}
  </div>

let renderTitleAndAffiliation = (title, affiliation) => {
  let text = switch (title == "", affiliation == "") {
  | (true, true) => None
  | (true, false) => Some(affiliation)
  | (false, true) => Some(title)
  | (false, false) => Some(title ++ (", " ++ affiliation))
  }

  switch text {
  | Some(text) =>
    <div className="flex items-center">
      <div className="mr-1 text-xs text-gray-600"> {str(text)} </div>
    </div>
  | None => React.null
  }
}

let initialState = () => {
  teamsToAdd: [],
  notifyStudents: true,
  saving: false,
}

let reducer = (state, action) =>
  switch action {
  | AddStudentInfo(studentInfo, teamName, tags) => {
      ...state,
      teamsToAdd: state.teamsToAdd->TeamInfo.addStudentToArray(studentInfo, teamName, tags),
    }
  | RemoveStudentInfo(studentInfo) => {
      ...state,
      teamsToAdd: state.teamsToAdd->TeamInfo.removeStudentFromArray(studentInfo),
    }
  | SetSaving(saving) => {...state, saving: saving}
  | ToggleNotifyStudents => {...state, notifyStudents: !state.notifyStudents}
  }

let tagBoxes = tags =>
  <div className="flex flex-wrap">
    {tags
    |> Array.map(tag =>
      <div
        key=tag
        className="flex items-center bg-gray-200 border border-gray-500 rounded-lg px-2 py-px mt-1 mr-1 text-xs text-gray-900 overflow-hidden">
        {str(tag)}
      </div>
    )
    |> React.array}
  </div>

let studentCard = (studentInfo, send, team, tags) => {
  let defaultClasses = "flex justify-between"

  let containerClasses = team
    ? defaultClasses ++ " border-t"
    : defaultClasses ++ " bg-white-100 border shadow rounded-lg mt-2 px-2"

  <div key={studentInfo |> StudentInfo.email} className=containerClasses>
    <div className="flex flex-col flex-1 flex-wrap p-3">
      <div className="flex items-center">
        <div className="mr-1 font-semibold"> {StudentInfo.name(studentInfo)->str} </div>
        <div className="text-xs text-gray-600">
          {" (" ++ StudentInfo.email(studentInfo) ++ ")" |> str}
        </div>
      </div>
      {renderTitleAndAffiliation(
        studentInfo |> StudentInfo.title,
        studentInfo |> StudentInfo.affiliation,
      )}
      {tagBoxes(tags)}
    </div>
    <button
      className="p-3 text-gray-700 hover:text-gray-900 hover:bg-gray-100"
      onClick={_event => send(RemoveStudentInfo(studentInfo))}>
      <i className="fas fa-trash-alt" />
    </button>
  </div>
}

@react.component
let make = (~courseId, ~submitFormCB, ~teamTags) => {
  let (state, send) = React.useReducer(reducer, initialState())

  <div className="mx-auto bg-white">
    <div className="max-w-2xl p-6 mx-auto">
      <h5 className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
        {t("drawer_heading")->str}
      </h5>
      <StudentsEditor__StudentInfoForm
        addToListCB={(studentInfo, teamName, tags) =>
          send(AddStudentInfo(studentInfo, teamName, tags))}
        teamTags={allKnownTags(teamTags, TeamInfo.tagsFromArray(state.teamsToAdd))}
        emailsToAdd={state.teamsToAdd |> TeamInfo.studentEmailsFromArray}
      />
      <div>
        <div className="mt-5">
          <div className="inline-block tracking-wide text-xs font-semibold">
            {t("teams_to_add_label")->str}
          </div>
          {switch state.teamsToAdd {
          | [] =>
            <div
              className="flex items-center justify-between bg-gray-100 border rounded p-3 italic mt-2">
              {t("teams_to_add_empty")->str}
            </div>
          | teams => teams |> Js.Array.map(team =>
              switch TeamInfo.nature(team) {
              | TeamInfo.MultiMember(teamName, studentsInTeam) =>
                <div className="mt-3" key=teamName>
                  {teamHeader(teamName, studentsInTeam |> Array.length)}
                  {TeamInfo.tags(team)->tagBoxes}
                  <div className="bg-white-100 border shadow rounded-lg mt-2 px-2">
                    {studentsInTeam
                    |> Array.map(studentInfo => studentCard(studentInfo, send, true, []))
                    |> React.array}
                  </div>
                </div>
              | SingleMember(studentInfo) =>
                studentCard(studentInfo, send, false, TeamInfo.tags(team))
              }
            ) |> React.array
          }}
        </div>
      </div>
      <div className="mt-4">
        <input
          onChange={_event => send(ToggleNotifyStudents)}
          checked=state.notifyStudents
          className="hidden checkbox-input"
          id="notify-new-students"
          type_="checkbox"
        />
        <label className="checkbox-label" htmlFor="notify-new-students">
          <span>
            <svg width="12px" height="10px" viewBox="0 0 12 10">
              <polyline points="1.5 6 4.5 9 10.5 1" />
            </svg>
          </span>
          <span className="text-sm"> {t("notify_students_label")->str} </span>
        </label>
      </div>
      <div className="flex mt-4">
        <button
          disabled={state.saving || state.teamsToAdd |> ArrayUtils.isEmpty}
          onClick={createStudents(state, send, courseId, submitFormCB)}
          className={"w-full btn btn-primary btn-large mt-3" ++ (
            formInvalid(state) ? " disabled" : ""
          )}>
          {(state.saving ? t("saving") : t("save_list_button"))->str}
        </button>
      </div>
    </div>
  </div>
}
