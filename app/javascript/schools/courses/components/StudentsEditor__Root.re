[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = React.string;

type teamId = string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t, teamId);

type selectedStudent = {
  name: string,
  id: string,
  teamId: string,
  avatarUrl: option(string),
  levelId: string,
  isSingleStudent: bool,
};

type state = {
  pagedTeams: Page.t,
  filter: Filter.t,
  selectedStudents: array(selectedStudent),
  formVisible,
  tags: array(string),
};

type action =
  | SelectStudent(selectedStudent)
  | DeselectStudent(string)
  | DeselectAllStudents
  | UpdateFormVisible(formVisible)
  | UpdateTeams(Page.t)
  | UpdateFilter(Filter.t)
  | RefreshData(array(string));

let selectedAcrossTeams = selectedStudents =>
  selectedStudents
  |> Array.map(s => s.teamId)
  |> ArrayUtils.distinct
  |> Array.length > 1;

let studentsInSelectedTeam = (teams, selectedTeamId) => {
  selectedTeamId |> Team.unsafeFind(teams, "Root") |> Team.students;
};

let selectedWithinLevel = selectedStudents => {
  selectedStudents
  |> Array.map(s => s.levelId)
  |> ArrayUtils.sort_uniq(String.compare)
  |> Array.length == 1;
};

let isGroupable = selectedStudents =>
  if (selectedStudents |> Array.length > 1) {
    selectedWithinLevel(selectedStudents)
    && selectedAcrossTeams(selectedStudents);
  } else {
    false;
  };

let isMoveOutable = selectedStudents => {
  selectedStudents |> Array.map(s => s.isSingleStudent) == [|false|];
};

let handleTeamUpResponse = (send, _json) => {
  send(RefreshData([||]));
  Notification.success("Success!", "Teams updated successfully");
};

let handleErrorCB = () => ();

let teamUp = (selectedStudents, responseCB) => {
  let studentIds = selectedStudents |> Array.map(s => s.id);
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    AuthenticityToken.fromHead() |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "founder_ids",
    studentIds |> Json.Encode.(array(string)),
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
  | SelectStudent(selectedStudent) => {
      ...state,
      selectedStudents:
        state.selectedStudents |> Array.append([|selectedStudent|]),
    }

  | DeselectStudent(id) => {
      ...state,
      selectedStudents:
        state.selectedStudents |> Js.Array.filter(s => s.id != id),
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

let selectStudent = (send, student, team) => {
  let selectedStudent = {
    name: student |> Student.name,
    id: student |> Student.id,
    teamId: team |> Team.id,
    avatarUrl: student.avatarUrl,
    levelId: team |> Team.levelId,
    isSingleStudent: team |> Team.isSingleStudent,
  };
  send(SelectStudent(selectedStudent));
};

let deselectStudent = (send, studentId) => send(DeselectStudent(studentId));

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  let (state, send) = React.useReducer(reducer, initialState(studentTags));

  let updateTeams = pagedTeams => send(UpdateTeams(pagedTeams));
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
    <div className="max-w-3xl w-full mx-auto flex justify-between py-2 mt-4">
      <a
        className="btn btn-default no-underline"
        href={"/school/courses/" ++ courseId ++ "/inactive_students"}>
        {"Inactive Students" |> str}
      </a>
      {state.selectedStudents |> Array.length > 0
         ? React.null
         : <button
             onClick={_e => send(UpdateFormVisible(CreateForm))}
             className="btn btn-primary ml-4">
             <i className="fas fa-user-plus mr-2" />
             <span> {"Add New Students" |> str} </span>
           </button>}
    </div>
    <div className="w-full">
      <div className="mx-auto max-w-3xl">
        <StudentsEditor__Search
          filter={state.filter}
          updateFilterCB=updateFilter
          tags={state.tags}
          levels
        />
        <div className="flex flex-wrap">
          {state.selectedStudents
           |> Array.map(selectedStudent =>
                <div
                  className="flex items-center bg-white border border-gray-300 px-2 py-1 mr-1 rounded-lg mt-2">
                  {switch (selectedStudent.avatarUrl) {
                   | Some(avatarUrl) =>
                     <img
                       className="w-5 h-5 rounded-full mr-2 object-cover"
                       src=avatarUrl
                     />
                   | None =>
                     <Avatar
                       name={selectedStudent.name}
                       className="w-5 h-5 mr-2"
                     />
                   }}
                  <div className="text-sm">
                    <span className="text-black font-semibold inline-block ">
                      {selectedStudent.name |> str}
                    </span>
                    <button
                      className="ml-2 hover:bg-gray-300 cursor-pointer"
                      onClick={_ => deselectStudent(send, selectedStudent.id)}>
                      <i className="fas fa-times" />
                    </button>
                  </div>
                </div>
              )
           |> React.array}
        </div>
      </div>
    </div>
    <div>
      {state.selectedStudents |> ArrayUtils.isEmpty
         ? React.null
         : <div className="px-6">
             <div
               className="max-w-3xl h-16 mx-auto relative rounded border-b p-4 mt-3 w-full flex items-center justify-between">
               <div className="flex">
                 <label
                   className="flex items-center leading-tight mr-4 my-auto">
                   <input
                     className="leading-tight"
                     type_="checkbox"
                     htmlFor="selected-students"
                     checked={state.selectedStudents |> Array.length > 0}
                     onChange={_ => send(DeselectAllStudents)}
                   />
                   <span
                     id="selected-students"
                     className="ml-2 text-sm text-gray-600">
                     {let selectedCount =
                        state.selectedStudents |> Array.length;

                      selectedCount > 0
                        ? (selectedCount |> string_of_int)
                          ++ " selected"
                          |> str
                        : React.null}
                   </span>
                 </label>
               </div>
               <div className="flex">
                 {isGroupable(state.selectedStudents)
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
                 {isMoveOutable(state.selectedStudents)
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
               </div>
             </div>
           </div>}
    </div>
    <div className="overflow-y-scroll">
      <StudentsEditor__TeamsList
        levels
        courseId
        filter={state.filter}
        pagedTeams={state.pagedTeams}
        selectedStudentIds={state.selectedStudents |> Array.map(s => s.id)}
        selectStudentCB={selectStudent(send)}
        deselectStudentCB={deselectStudent(send)}
        showEditFormCB=showEditForm
        updateTeamsCB=updateTeams
      />
    </div>
  </div>;
};
