[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = React.string;

type teamId = string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t, teamId);

type state = {
  pagedTeams: Page.t,
  filter: Filter.t,
  selectedStudents: array((Student.t, teamId)),
  formVisible,
  tags: array(string),
};

type action =
  | SelectStudent(Student.t, teamId)
  | DeselectStudent(Student.t)
  | DeselectAllStudents
  | UpdateFormVisible(formVisible)
  | UpdateTeams(Page.t)
  | UpdateFilter(Filter.t)
  | RefreshData(array(string));

let selectedAcrossTeams = selectedStudents =>
  selectedStudents
  |> Array.map(((_, teamId)) => teamId)
  |> ArrayUtils.distinct
  |> Array.length > 1;

let studentsInSelectedTeam = (teams, selectedTeamId) => {
  selectedTeamId |> Team.unsafeFind(teams, "Root") |> Team.students;
};

let selectedPartialTeam = (selectedStudents, teams) => {
  // Todo: Re-write logic with a safer function
  let (_selectedStudent, selectedTeamId) = selectedStudents[0];

  selectedStudents
  |> Array.length
  < (studentsInSelectedTeam(teams, selectedTeamId) |> Array.length);
};

let selectedWithinLevel = (selectedStudents, teams) => {
  let teamIds =
    selectedStudents |> Array.map(((_student, teamId)) => teamId);

  let selectedUniqTeams =
    teams |> Js.Array.filter(team => Array.mem(team |> Team.id, teamIds));

  let selectedLevelNumbers =
    selectedUniqTeams
    |> Array.map(team => team |> Team.levelId |> int_of_string);

  selectedLevelNumbers
  |> ArrayUtils.sort_uniq((ln1, ln2) => ln1 - ln2)
  |> Array.length == 1;
};

let isGroupable = (selectedStudents, teams) =>
  if (selectedStudents |> Array.length > 1) {
    selectedWithinLevel(selectedStudents, teams)
    && (
      selectedAcrossTeams(selectedStudents)
      || selectedPartialTeam(selectedStudents, teams)
    );
  } else {
    false;
  };

let isMoveOutable = (selectedStudents, teams) => {
  let onlyOneSelected = selectedStudents |> Array.length == 1;

  if (onlyOneSelected == true) {
    // Todo: Re-write logic with a safer function
    let (_selectedStudent, selectedTeamId) = selectedStudents[0];
    studentsInSelectedTeam(teams, selectedTeamId) |> Array.length > 1;
  } else {
    false;
  };
};

let handleTeamUpResponse = (send, _json) => {
  send(RefreshData([||]));
  Notification.success("Success!", "Teams updated successfully");
};

let handleErrorCB = () => ();

let teamUp = (selectedStudents, responseCB) => {
  let students = selectedStudents |> Array.map(((s, _)) => s);
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    AuthenticityToken.fromHead() |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "founder_ids",
    students |> Array.map(s => s |> Student.id) |> Json.Encode.(array(string)),
  );
  let url = "/school/students/team_up";
  Api.create(url, payload, responseCB, handleErrorCB);
};

let initialState = tags => {
  pagedTeams: Unloaded,
  selectedStudents: [||],
  filter: Filter.empty(),
  formVisible: None,
  tags,
};

let reducer = (state, action) =>
  switch (action) {
  | SelectStudent(student, teamId) => {
      ...state,
      selectedStudents:
        state.selectedStudents |> Array.append([|(student, teamId)|]),
    }

  | DeselectStudent(student) => {
      ...state,
      selectedStudents:
        state.selectedStudents
        |> Js.Array.filter(((s, _)) =>
             Student.id(s) !== Student.id(student)
           ),
    }

  | DeselectAllStudents => {...state, selectedStudents: [||]}
  | UpdateFormVisible(formVisible) => {...state, formVisible}
  | UpdateTeams(pagedTeams) => {...state, pagedTeams}
  | UpdateFilter(filter) => {
      ...state,
      filter,
      pagedTeams: state.filter == filter ? state.pagedTeams : Unloaded,
    }
  | RefreshData(tags) => {
      ...state,
      pagedTeams: Unloaded,
      tags:
        state.tags
        |> Array.append(tags)
        |> ArrayUtils.sort_uniq(String.compare),
      formVisible: None,
    }
  };

let teamsList = pagedTeams =>
  switch (pagedTeams) {
  | Page.Unloaded => [||]
  | Page.PartiallyLoaded(teams, _cursor) => teams
  | Page.FullyLoaded(teams) => teams
  };

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  let (state, send) = React.useReducer(reducer, initialState(studentTags));

  let updateTeams = pagedTeams => send(UpdateTeams(pagedTeams));
  let selectStudent = (student, teamId) => {
    send(SelectStudent(student, teamId));
  };
  let deselectStudent = student => send(DeselectStudent(student));
  let showEditForm = (student, teamId) =>
    send(UpdateFormVisible(UpdateForm(student, teamId)));
  let teams = teamsList(state.pagedTeams);
  let updateFilter = filter => send(UpdateFilter(filter));

  <div className="flex flex-1 flex-col bg-gray-100 overflow-hidden">
    {let submitFormCB = tagsToApply => send(RefreshData(tagsToApply));
     switch (state.formVisible) {
     | None => ReasonReact.null
     | CreateForm =>
       <SchoolAdmin__EditorDrawer
         closeDrawerCB={() => send(UpdateFormVisible(None))}>
         <StudentsEditor__CreateForm
           courseId
           submitFormCB
           studentTags={state.tags}
         />
       </SchoolAdmin__EditorDrawer>

     | UpdateForm(student, teamId) =>
       let team = teamId |> Team.unsafeFind(teams, "Root");

       <SchoolAdmin__EditorDrawer
         closeDrawerCB={() => send(UpdateFormVisible(None))}>
         <StudentsEditor__UpdateForm
           student
           team
           studentTags={state.tags}
           courseCoachIds
           schoolCoaches
           submitFormCB
         />
       </SchoolAdmin__EditorDrawer>;
     }}
    <div className="px-6 py-2">
      <a
        className="btn btn-default no-underline"
        href={"/school/courses/" ++ courseId ++ "/inactive_students"}>
        {"Inactive Students" |> str}
      </a>
    </div>
    <div className="w-full">
      <div className="mx-auto max-w-3xl">
        <StudentsEditor__Search
          filter={state.filter}
          updateFilterCB=updateFilter
          tags=state.tags
          levels
        />
      </div>
    </div>
    <div>
      <div className="px-6">
        <div
          className="max-w-3xl h-16 mx-auto relative rounded border-b p-4 mt-3 w-full flex items-center justify-between">
          <div className="flex">
            <label className="flex items-center leading-tight mr-4 my-auto">
              <input
                className="leading-tight"
                type_="checkbox"
                htmlFor="selected-students"
                checked={state.selectedStudents |> Array.length > 0}
                onChange={_ => send(DeselectAllStudents)}
              />
              <span
                id="selected-students" className="ml-2 text-sm text-gray-600">
                {let selectedCount = state.selectedStudents |> Array.length;

                 selectedCount > 0
                   ? (selectedCount |> string_of_int) ++ " selected" |> str
                   : React.null}
              </span>
            </label>
          </div>
          <div className="flex">
            {false
               ? <button
                   className="bg-gray-200 hover:bg-gray-400 hover:text-gray-800 focus:outline-none text-gray-600 text-sm font-semibold py-2 px-4 rounded inline-flex items-center mx-2">
                   {"Add tags" |> str}
                 </button>
               : React.null}
            {isGroupable(state.selectedStudents, teams)
               ? <button
                   onClick={_e =>
                     teamUp(
                       state.selectedStudents,
                       handleTeamUpResponse(send),
                     )
                   }
                   className="bg-transparent hover:bg-purple-600 focus:outline-none text-purple-600 text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                   {"Group as Team" |> str}
                 </button>
               : React.null}
            {isMoveOutable(state.selectedStudents, teams)
               ? <button
                   onClick={_e =>
                     teamUp(
                       state.selectedStudents,
                       handleTeamUpResponse(send),
                     )
                   }
                   className="bg-transparent hover:bg-purple-600 focus:outline-none text-purple-600 text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                   {"Move out from Team" |> str}
                 </button>
               : React.null}
            {state.selectedStudents |> Array.length > 0
               ? React.null
               : <button
                   onClick={_e => send(UpdateFormVisible(CreateForm))}
                   className="btn btn-primary ml-4">
                   <i className="fas fa-user-plus mr-2" />
                   <span> {"Add New Students" |> str} </span>
                 </button>}
          </div>
        </div>
      </div>
    </div>
    <div className="overflow-y-scroll">
      <StudentsEditor__TeamsList
        levels
        courseId
        filter={state.filter}
        pagedTeams={state.pagedTeams}
        selectedStudents={state.selectedStudents}
        selectStudentCB=selectStudent
        deselectStudentCB=deselectStudent
        showEditFormCB=showEditForm
        updateTeamsCB=updateTeams
      />
    </div>
  </div>;
};
