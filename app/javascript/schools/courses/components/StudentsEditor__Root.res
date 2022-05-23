open StudentsEditor__Types

let t = I18n.t(~scope="components.StudentsEditor__Root")
let ts = I18n.ts

let str = React.string

type teamId = string

type tags = array<string>

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t, teamId)
  | BulkImportForm

type state = {
  pagedTeams: Page.t,
  totalCount: int,
  filter: Filter.t,
  selectedStudents: array<SelectedStudent.t>,
  formVisible: formVisible,
  readonlyTags: tags,
  editableTags: tags,
  loading: Loading.t,
  refreshTeams: bool,
}

type action =
  | SelectStudent(SelectedStudent.t)
  | DeselectStudent(string)
  | UpdateFormVisible(formVisible)
  | UpdateStudentCertification(Student.t, Team.t)
  | UpdateTeams(Page.t, int)
  | UpdateFilter(Filter.t)
  | RefreshData(tags)
  | UpdateTeam(Team.t, tags)
  | SetLoading(Loading.t)

let handleTeamUpResponse = (send, _json) => {
  send(RefreshData([]))
  Notification.success(ts("notifications.success"), t("teams_updated_success"))
}

let handleErrorCB = () => ()

let addTags = (oldtags, newTags) =>
  oldtags |> Array.append(newTags) |> ArrayUtils.sort_uniq(String.compare)

let teamUp = (selectedStudents, responseCB) => {
  let studentIds = selectedStudents |> Array.map(s => s |> SelectedStudent.id)
  let payload = Js.Dict.empty()
  Js.Dict.set(payload, "authenticity_token", AuthenticityToken.fromHead() |> Js.Json.string)
  Js.Dict.set(
    payload,
    "founder_ids",
    studentIds |> {
      open Json.Encode
      array(string)
    },
  )
  let url = "/school/students/team_up"
  Api.create(url, payload, responseCB, handleErrorCB)
}

let initialState = (readonlyTags, editableTags) => {
  pagedTeams: Unloaded,
  totalCount: 0,
  selectedStudents: [],
  filter: Filter.make(),
  formVisible: None,
  readonlyTags: readonlyTags,
  editableTags: editableTags,
  loading: Loading.NotLoading,
  refreshTeams: false,
}

let reducer = (state, action) =>
  switch action {
  | SelectStudent(selectedStudent) => {
      ...state,
      selectedStudents: state.selectedStudents |> Array.append([selectedStudent]),
    }

  | DeselectStudent(id) => {
      ...state,
      selectedStudents: state.selectedStudents |> Js.Array.filter(s =>
        s |> SelectedStudent.id != id
      ),
    }

  | UpdateFormVisible(formVisible) => {...state, formVisible: formVisible}
  | UpdateTeams(pagedTeams, totalCount) => {
      ...state,
      pagedTeams: pagedTeams,
      totalCount: totalCount,
      loading: Loading.NotLoading,
    }
  | UpdateFilter(filter) => {
      ...state,
      filter: filter,
      refreshTeams: !state.refreshTeams,
    }
  | RefreshData(tags) => {
      ...state,
      refreshTeams: !state.refreshTeams,
      editableTags: addTags(state.editableTags, tags),
      formVisible: None,
      selectedStudents: [],
    }
  | UpdateTeam(team, tags) => {
      ...state,
      pagedTeams: state.pagedTeams |> Page.updateTeam(team),
      editableTags: addTags(state.editableTags, tags),
      formVisible: None,
      selectedStudents: [],
    }
  | SetLoading(loading) => {...state, loading: loading}
  | UpdateStudentCertification(updatedStudent, team) =>
    let updatedTeam = Team.updateStudent(team, updatedStudent)
    let pagedTeams = Page.updateTeam(updatedTeam, state.pagedTeams)
    let teamId = Team.id(team)
    {...state, pagedTeams: pagedTeams, formVisible: UpdateForm(updatedStudent, teamId)}
  }

let selectStudent = (send, student, team) => {
  let selectedStudent = SelectedStudent.make(
    ~name=student |> Student.name,
    ~id=student |> Student.id,
    ~teamId=team |> Team.id,
    ~avatarUrl=student.avatarUrl,
    ~levelId=team |> Team.levelId,
    ~teamSize=team |> Team.students |> Array.length,
  )

  send(SelectStudent(selectedStudent))
}

let deselectStudent = (send, studentId) => send(DeselectStudent(studentId))

let updateFilter = (send, filter) => send(UpdateFilter(filter))

module Sortable = {
  type t = Filter.sortBy

  let criterion = c =>
    switch c {
    | Filter.Name => t("sort_criterion_name")
    | CreatedAt => t("sort_criterion_last_created")
    | UpdatedAt => t("sort_criterion_last_updated")
    }

  let criterionType = c =>
    switch c {
    | Filter.Name => #String
    | CreatedAt
    | UpdatedAt =>
      #Number
    }
}

module StudentsSorter = Sorter.Make(Sortable)

let studentsSorter = (send, filter) =>
  <div className="ml-2 flex-shrink-0">
    <label className="block text-tiny uppercase font-semibold">
      {t("sort_criterion_label") |> str}
    </label>
    <div className="mt-1">
      <StudentsSorter
        criteria=[Filter.Name, CreatedAt, UpdatedAt]
        selectedCriterion={Filter.sortBy(filter)}
        direction={Filter.sortDirection(filter)}
        onDirectionChange={sortDirection =>
          updateFilter(send, {...filter, sortDirection: sortDirection})}
        onCriterionChange={sortBy => updateFilter(send, {...filter, sortBy: sortBy})}
      />
    </div>
  </div>

let updateTeams = (send, pagedTeams, totalCount) => send(UpdateTeams(pagedTeams, totalCount))

let showEditForm = (send, student, teamId) => send(UpdateFormVisible(UpdateForm(student, teamId)))

let submitForm = (send, tagsToApply) => send(RefreshData(tagsToApply))

let updateForm = (send, tagsToApply, team) =>
  switch team {
  | Some(t) => send(UpdateTeam(t, tagsToApply))
  | None => send(RefreshData(tagsToApply))
  }

let reloadTeams = (send, ()) => send(RefreshData([]))

let setLoading = (send, loading) => send(SetLoading(loading))

@react.component
let make = (
  ~courseId,
  ~courseCoachIds,
  ~schoolCoaches,
  ~levels,
  ~userTags,
  ~teamTags,
  ~certificates,
  ~currentUserName,
) => {
  let (state, send) = React.useReducer(reducer, initialState(userTags, teamTags))
  let allTags =
    Js.Array.concat(state.readonlyTags, state.editableTags) |> ArrayUtils.sort_uniq(String.compare)

  <div className="flex flex-1 flex-col">
    {switch state.formVisible {
    | None => React.null
    | CreateForm =>
      <SchoolAdmin__EditorDrawer closeDrawerCB={() => send(UpdateFormVisible(None))}>
        <StudentsEditor__CreateForm
          courseId submitFormCB={submitForm(send)} teamTags=state.editableTags
        />
      </SchoolAdmin__EditorDrawer>

    | UpdateForm(student, teamId) =>
      let team = teamId |> Team.unsafeFind(state.pagedTeams |> Page.teams, "Root")
      let courseCoaches =
        schoolCoaches |> Js.Array.filter(coach => courseCoachIds |> Array.mem(Coach.id(coach)))
      <SchoolAdmin__EditorDrawer closeDrawerCB={() => send(UpdateFormVisible(None))}>
        <StudentsEditor__UpdateForm
          student
          team
          teamTags=state.editableTags
          currentUserName
          courseCoaches
          certificates
          updateFormCB={updateForm(send)}
          reloadTeamsCB={reloadTeams(send)}
          updateStudentCertificationCB={updatedStudent =>
            send(UpdateStudentCertification(updatedStudent, team))}
        />
      </SchoolAdmin__EditorDrawer>
    | BulkImportForm =>
      <SchoolAdmin__EditorDrawer2 closeDrawerCB={() => send(UpdateFormVisible(None))}>
        <StudentsEditor__BulkImportForm
          courseId closeDrawerCB={() => send(UpdateFormVisible(None))}
        />
      </SchoolAdmin__EditorDrawer2>
    }}
    <div className="px-6 pb-4 flex-1 bg-gray-50 relative overflow-y-scroll">
      <div className="max-w-3xl w-full mx-auto flex justify-between items-center border-b mt-4">
        <ul className="flex font-semibold text-sm">
          <li className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
            <span> {t("button_all_students") |> str} </span>
          </li>
          <li
            className="rounded-t-lg cursor-pointer border-b-3 border-transparent hover:bg-gray-50 hover:text-gray-900 focus-within:outline-none focus-within:bg-gray-50 focus-within:text-gray-900 focus-within:ring-2 focus-within:ring-focusColor-500">
            <a
              className="block px-3 py-3 md:py-2 text-gray-800 focus:outline-none"
              href={"/school/courses/" ++ (courseId ++ "/inactive_students")}>
              {t("button_inactive_students") |> str}
            </a>
          </li>
        </ul>
        {state.selectedStudents |> Array.length > 0
          ? React.null
          : <div className="flex justify-between">
              <button
                onClick={_e => send(UpdateFormVisible(BulkImportForm))}
                className="btn btn-primary-ghost ml-4">
                <i className="fas fa-file-csv mr-2" />
                <span> {t("button_bulk_import") |> str} </span>
              </button>
              <button
                onClick={_e => send(UpdateFormVisible(CreateForm))}
                className="btn btn-primary ml-4">
                <i className="fas fa-user-plus mr-2" />
                <span> {t("button_add_new_students") |> str} </span>
              </button>
            </div>}
      </div>
      <div className="bg-gray-50 sticky top-0 py-3">
        <div className="border rounded-lg mx-auto max-w-3xl bg-white ">
          <div>
            <div className="flex w-full items-start p-4">
              <StudentsEditor__Search
                filter=state.filter updateFilterCB={updateFilter(send)} tags=allTags levels
              />
              {studentsSorter(send, state.filter)}
            </div>
            {state.selectedStudents |> ArrayUtils.isEmpty
              ? React.null
              : <div className="flex justify-between bg-gray-50 px-4 pb-3 pt-1 rounded-b-lg">
                  <div className="flex flex-wrap">
                    {state.selectedStudents
                    |> Array.map(selectedStudent =>
                      <div
                        className="flex items-center bg-white border border-gray-300 rounded-full mr-2 mt-2 overflow-hidden">
                        {switch selectedStudent |> SelectedStudent.avatarUrl {
                        | Some(avatarUrl) =>
                          <img
                            className="w-5 h-5 rounded-full mr-2 ml-px my-px object-cover"
                            src=avatarUrl
                          />
                        | None =>
                          <Avatar
                            name={selectedStudent |> SelectedStudent.name}
                            className="w-5 h-5 mr-2 ml-px my-px"
                          />
                        }}
                        <div className="flex h-full items-center">
                          <span className="text-xs font-semibold pr-2 leading-tight ">
                            {selectedStudent |> SelectedStudent.name |> str}
                          </span>
                          <button
                            ariaLabel={"Remove " ++ (selectedStudent |> SelectedStudent.name)}
                            className="flex items-center h-full text-xs text-red-700 px-2 py-px border-l focus:outline-none bg-gray-50 hover:bg-red-700 hover:text-white focus:bg-red-700 focus:text-white "
                            onClick={_ =>
                              deselectStudent(send, selectedStudent |> SelectedStudent.id)}>
                            <Icon className="if i-times-regular" />
                          </button>
                        </div>
                      </div>
                    )
                    |> React.array}
                  </div>
                  <div className="pt-1">
                    {state.selectedStudents |> SelectedStudent.isGroupable
                      ? <button
                          onClick={_e => teamUp(state.selectedStudents, handleTeamUpResponse(send))}
                          className="btn btn-small btn-primary">
                          {t("group_as_team") |> str}
                        </button>
                      : React.null}
                    {state.selectedStudents |> SelectedStudent.isMoveOutable
                      ? <button
                          onClick={_e => teamUp(state.selectedStudents, handleTeamUpResponse(send))}
                          className="btn btn-small btn-danger">
                          {t("move_out_team") |> str}
                        </button>
                      : React.null}
                  </div>
                </div>}
          </div>
        </div>
      </div>
      <div>
        <StudentsEditor__TeamsList
          levels
          courseId
          filter=state.filter
          pagedTeams=state.pagedTeams
          totalTeamsCount=state.totalCount
          selectedStudentIds={state.selectedStudents |> Array.map(s => s |> SelectedStudent.id)}
          selectStudentCB={selectStudent(send)}
          deselectStudentCB={deselectStudent(send)}
          showEditFormCB={showEditForm(send)}
          updateTeamsCB={updateTeams(send)}
          loading=state.loading
          setLoadingCB={setLoading(send)}
          updateFilterCB={updateFilter(send)}
          refreshTeams=state.refreshTeams
        />
      </div>
    </div>
    {
      let loading = switch state.pagedTeams {
      | Unloaded => false
      | _ =>
        switch state.loading {
        | NotLoading => false
        | Reloading => true
        | LoadingMore => false
        }
      }
      <LoadingSpinner loading />
    }
  </div>
}
