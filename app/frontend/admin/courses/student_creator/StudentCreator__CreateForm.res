open StudentsEditor__Types

type state = {
  teamsToAdd: array<TeamInfo.t>,
  notifyStudents: bool,
  tags: array<string>,
  cohorts: array<Cohort.t>,
  selectedCohort: option<Cohort.t>,
  saving: bool,
  loading: bool,
}

type action =
  | AddStudentInfo(StudentInfo.t, option<string>, array<string>)
  | RemoveStudentInfo(StudentInfo.t)
  | SetBaseData(array<Cohort.t>, array<string>)
  | ToggleNotifyStudents
  | SetSaving
  | SetSelectedCohort(Cohort.t)
  | SetLoading
  | ClearSaving

let str = React.string

let t = I18n.t(~scope="components.StudentCreator__CreateForm")
let ts = I18n.ts

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

let handleResponseCB = (state, studentIds) => {
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
      Notification.success(ts("notifications.done_exclamation"), t("added_full_description"))
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
}

module CreateStudentsQuery = %graphql(`
  mutation CreateStudentsMutation($cohortId: ID!, $notifyStudents: Boolean!, $students: [StudentEnrollmentInput!]!) {
    createStudents(cohortId: $cohortId, notifyStudents: $notifyStudents, students: $students) {
      studentIds
    }
  }
  `)

module CohortFragment = Cohort.Fragment
module StudentsCreateDataQuery = %graphql(`
  query StudentsCreateDataQuery($courseId: ID!) {
    course(id: $courseId) {
      cohorts {
        ...CohortFragment
      }
      studentTags
    }
  }
  `)

let loadData = (courseId, send) => {
  send(SetLoading)
  StudentsCreateDataQuery.fetch(StudentsCreateDataQuery.makeVariables(~courseId, ()))
  |> Js.Promise.then_((response: StudentsCreateDataQuery.t) => {
    send(
      SetBaseData(
        response.course.cohorts->Js.Array2.map(Cohort.makeFromFragment),
        response.course.studentTags,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let createStudents = (state, send, courseId, cohort, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(SetSaving)

  let students =
    Js.Array.map(
      t =>
        Js.Array.map(
          s =>
            CreateStudentsQuery.makeInputObjectStudentEnrollmentInput(
              ~name=StudentInfo.name(s),
              ~email=StudentInfo.email(s),
              ~title=StudentInfo.title(s),
              ~affiliation=StudentInfo.affiliation(s),
              ~teamName=TeamInfo.name(t),
              ~tags=TeamInfo.tags(t),
              (),
            ),
          TeamInfo.students(t),
        ),
      state.teamsToAdd,
    ) |> ArrayUtils.flattenV2

  let {notifyStudents} = state

  let variables = CreateStudentsQuery.makeVariables(
    ~cohortId=Cohort.id(cohort),
    ~notifyStudents,
    ~students,
    (),
  )
  CreateStudentsQuery.make(variables)
  |> Js.Promise.then_(response => {
    switch response["createStudents"]["studentIds"] {
    | Some(studentIds) => {
        handleResponseCB(state, studentIds)
        RescriptReactRouter.push({`/school/courses/${courseId}/students`})
      }
    | None => send(ClearSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    Notification.error(
      "Unexpected Error!",
      "Our team has been notified of this failure. Please reload this page before trying to add students again.",
    )
    send(ClearSaving)
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
          <i className="fas fa-exclamation-triangle text-orange-600 me-1" />
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
      <div className="me-1 text-xs text-gray-600"> {str(text)} </div>
    </div>
  | None => React.null
  }
}

let initialState = () => {
  teamsToAdd: [],
  tags: [],
  loading: false,
  cohorts: [],
  notifyStudents: true,
  saving: false,
  selectedCohort: None,
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
  | SetSaving => {...state, saving: true}
  | ToggleNotifyStudents => {...state, notifyStudents: !state.notifyStudents}
  | SetBaseData(cohorts, tags) => {...state, cohorts, tags, loading: false}
  | SetSelectedCohort(cohort) => {...state, selectedCohort: Some(cohort)}
  | ClearSaving => {...state, saving: false}
  | SetLoading => {...state, loading: true}
  }

let tagBoxes = tags =>
  <div className="flex flex-wrap">
    {tags
    |> Array.map(tag =>
      <div
        key=tag
        className="flex items-center bg-gray-200 border border-gray-500 rounded-lg px-2 py-px mt-1 me-1 text-xs text-gray-900 overflow-hidden">
        {str(tag)}
      </div>
    )
    |> React.array}
  </div>

let studentCard = (studentInfo, send, team, tags) => {
  let defaultClasses = "flex justify-between"

  let containerClasses = team
    ? defaultClasses ++ " border-t"
    : defaultClasses ++ " bg-white border shadow rounded-lg mt-2 px-2"

  <div key={studentInfo |> StudentInfo.email} className=containerClasses>
    <div className="flex flex-col flex-1 flex-wrap p-3">
      <div className="flex items-center">
        <div className="me-1 font-semibold"> {StudentInfo.name(studentInfo)->str} </div>
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

module Selectable = {
  type t = Cohort.t
  let id = t => Cohort.id(t)
  let name = t => Cohort.name(t)
}

module Dropdown = Select.Make(Selectable)

let findSelectedCohort = (cohorts, selectedCohort) => {
  Belt.Option.flatMap(selectedCohort, c =>
    Js.Array2.find(cohorts, u => Cohort.id(c) == Cohort.id(u))
  )
}

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, initialState())
  React.useEffect1(() => {
    loadData(courseId, send)
    None
  }, [courseId])

  <div className="grid grid-cols-2 gap-8">
    <div>
      <div className="pt-6 flex flex-col">
        <label className="block text-sm font-medium" htmlFor="email">
          {t("select_a_cohort")->str}
        </label>
        <Dropdown
          placeholder={t("pick_a_cohort")}
          selectables={state.cohorts}
          selected={findSelectedCohort(state.cohorts, state.selectedCohort)}
          onSelect={u => send(SetSelectedCohort(u))}
          disabled={state.teamsToAdd->ArrayUtils.isNotEmpty}
          loading={state.loading}
        />
      </div>
      <StudentCreator__StudentInfoForm
        addToListCB={(studentInfo, teamName, tags) =>
          send(AddStudentInfo(studentInfo, teamName, tags))}
        teamTags={allKnownTags(state.tags, TeamInfo.tagsFromArray(state.teamsToAdd))}
        emailsToAdd={TeamInfo.studentEmailsFromArray(state.teamsToAdd)}
        disabled={state.loading}
      />
    </div>
    <div className="pt-6">
      <div className="inline-block tracking-wide text-sm font-semibold">
        {str(t("student_list"))}
      </div>
      <div className="p-4 rounded-lg border bordedr-gray-300 bg-gray-100 mt-1">
        <div>
          {switch state.teamsToAdd {
          | [] =>
            <div
              className="flex items-center justify-between bg-white border rounded p-3 text-sm text-gray-600 mt-2">
              {t("teams_to_add_empty")->str}
            </div>
          | teams =>
            teams
            ->Js.Array2.map(team =>
              switch TeamInfo.nature(team) {
              | TeamInfo.MultiMember(teamName, studentsInTeam) =>
                <div className="mt-3" key=teamName>
                  {teamHeader(teamName, studentsInTeam->Array.length)}
                  {TeamInfo.tags(team)->tagBoxes}
                  <div className="bg-white border shadow rounded-lg mt-2 px-2">
                    {studentsInTeam
                    ->Js.Array2.map(studentInfo => studentCard(studentInfo, send, true, []))
                    ->React.array}
                  </div>
                </div>
              | SingleMember(studentInfo) =>
                studentCard(studentInfo, send, false, TeamInfo.tags(team))
              }
            )
            ->React.array
          }}
        </div>
        <div className="mt-4">
          <input
            onChange={_event => send(ToggleNotifyStudents)}
            checked=state.notifyStudents
            className="checkbox-input h-4 w-4 rounded border border-gray-300 text-primary-500 focus:ring-focusColor-500"
            id="notify-new-students"
            type_="checkbox"
          />
          <label
            className="checkbox-label ps-2 leading-tight cursor-pointer text-sm "
            htmlFor="notify-new-students">
            {t("notify_students_label")->str}
          </label>
        </div>
        <div className="flex mt-4">
          {switch state.selectedCohort {
          | Some(c) =>
            <button
              disabled={state.saving || state.teamsToAdd->ArrayUtils.isEmpty}
              onClick={createStudents(state, send, courseId, c)}
              className={"w-full btn btn-primary btn-large mt-3" ++ (
                formInvalid(state) ? " disabled" : ""
              )}>
              {(state.saving ? t("saving") : t("save_list_button"))->str}
            </button>
          | None =>
            <button disabled=true className={"w-full btn btn-primary btn-large mt-3 disabled"}>
              {t("select_cohort")->str}
            </button>
          }}
        </div>
      </div>
    </div>
  </div>
}
