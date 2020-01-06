[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = React.string;

type teamId = string;

type tags = array(string);

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t, teamId);

type state = {
  pagedTeams: Page.t,
  filter: Filter.t,
  selectedStudents: array(SelectedStudent.t),
  formVisible,
  tags,
  loading: bool,
};

type action =
  | SelectStudent(SelectedStudent.t)
  | DeselectStudent(string)
  | DeselectAllStudents
  | UpdateFormVisible(formVisible)
  | UpdateTeams(Page.t)
  | UpdateFilter(Filter.t)
  | RefreshData(tags)
  | UpdateTeam(Team.t, tags)
  | SetLoading(bool);

let handleTeamUpResponse = (send, _json) => {
  send(RefreshData([||]));
  Notification.success("Success!", "Teams updated successfully");
};

let handleErrorCB = () => ();

let addTags = (oldtags, newTags) =>
  oldtags |> Array.append(newTags) |> ArrayUtils.sort_uniq(String.compare);

let teamUp = (selectedStudents, responseCB) => {
  let studentIds = selectedStudents |> Array.map(s => s |> SelectedStudent.id);
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
  loading: false,
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
        state.selectedStudents
        |> Js.Array.filter(s => s |> SelectedStudent.id != id),
    }

  | DeselectAllStudents => {...state, selectedStudents: [||]}
  | UpdateFormVisible(formVisible) => {...state, formVisible}
  | UpdateTeams(pagedTeams) => {...state, pagedTeams, loading: false}
  | UpdateFilter(filter) => {
      ...state,
      filter,
      pagedTeams: state.filter == filter ? state.pagedTeams : Unloaded,
    }
  | RefreshData(tags) => {
      ...state,
      pagedTeams: Unloaded,
      tags: addTags(state.tags, tags),
      formVisible: None,
      selectedStudents: [||],
    }
  | UpdateTeam(team, tags) => {
      ...state,
      pagedTeams: state.pagedTeams |> Page.updateTeam(team),
      tags: addTags(state.tags, tags),
      formVisible: None,
      selectedStudents: [||],
    }
  | SetLoading(loading) => {...state, loading}
  };

let teamsList = pagedTeams =>
  switch (pagedTeams) {
  | Page.Unloaded => [||]
  | Page.PartiallyLoaded(teams, _cursor) => teams
  | Page.FullyLoaded(teams) => teams
  };

let selectStudent = (send, student, team) => {
  let selectedStudent =
    SelectedStudent.make(
      ~name=student |> Student.name,
      ~id=student |> Student.id,
      ~teamId=team |> Team.id,
      ~avatarUrl=student.avatarUrl,
      ~levelId=team |> Team.levelId,
      ~studentsCount=team |> Team.students |> Array.length,
    );

  send(SelectStudent(selectedStudent));
};

let deselectStudent = (send, studentId) => send(DeselectStudent(studentId));

let updateFilter = (send, filter) => send(UpdateFilter(filter));

let dropDownContents = (updateFilterCB, filter) => {
  filter
  |> Filter.sortByListForDropdown
  |> Array.map(sortBy => {
       let (text, iconClass) =
         switch ((sortBy: Filter.sortBy)) {
         | Name => ("Name", "fas fa-user")
         | CreatedAt => ("Created At", "fas fa-user")
         | UpdatedAt => ("Updated At", "fas fa-user")
         };
       <div
         onClick={_ => updateFilterCB(filter |> Filter.updateSortBy(sortBy))}
         className="block bg-white leading-snug border border-gray-400 rounded-lg focus:outline-none focus:bg-white focus:border-gray-500 px-6 py-3 ">
         <i className=iconClass />
         <span className="ml-2"> {text |> str} </span>
       </div>;
     });
};

let dropDownSelected = filter => {
  let (text, iconClass) =
    switch (filter |> Filter.sortBy) {
    | Name => ("Name", "fas fa-user")
    | CreatedAt => ("Created At", "fas fa-user")
    | UpdatedAt => ("Updated At", "fas fa-user")
    };
  <div
    className="block bg-white leading-snug border border-gray-400 rounded-lg focus:outline-none focus:bg-white focus:border-gray-500 px-6 py-3 ">
    <i className=iconClass />
    <span className="ml-2"> {text |> str} </span>
  </div>;
};

let updateTeams = (send, pagedTeams) => send(UpdateTeams(pagedTeams));
let showEditForm = (send, student, teamId) =>
  send(UpdateFormVisible(UpdateForm(student, teamId)));

let submitForm = (send, tagsToApply) => send(RefreshData(tagsToApply));

let updateForm = (send, tagsToApply, team) =>
  send(UpdateTeam(team, tagsToApply));

let setLoading = (send, loading) => send(SetLoading(loading));

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  let (state, send) = React.useReducer(reducer, initialState(studentTags));

  let teams = teamsList(state.pagedTeams);
  <div className="flex flex-1 flex-col bg-gray-100 overflow-hidden">
    {switch (state.formVisible) {
     | None => ReasonReact.null
     | CreateForm =>
       <SchoolAdmin__EditorDrawer
         closeDrawerCB={() => send(UpdateFormVisible(None))}>
         <StudentsEditor__CreateForm
           courseId
           submitFormCB={submitForm(send)}
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
           updateFormCB={updateForm(send)}
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
        <div className="flex w-full items-center">
          <StudentsEditor__Search
            filter={state.filter}
            updateFilterCB={updateFilter(send)}
            tags={state.tags}
            levels
          />
          <div className="w-1/4 ml-2 mt-2">
            {<Dropdown
               selected={dropDownSelected(state.filter)}
               contents={dropDownContents(updateFilter(send), state.filter)}
             />}
          </div>
        </div>
        <div className="flex flex-wrap">
          {state.selectedStudents
           |> Array.map(selectedStudent =>
                <div
                  className="flex items-center bg-white border border-gray-300 px-2 py-1 mr-1 rounded-lg mt-2">
                  {switch (selectedStudent |> SelectedStudent.avatarUrl) {
                   | Some(avatarUrl) =>
                     <img
                       className="w-5 h-5 rounded-full mr-2 object-cover"
                       src=avatarUrl
                     />
                   | None =>
                     <Avatar
                       name={selectedStudent |> SelectedStudent.name}
                       className="w-5 h-5 mr-2"
                     />
                   }}
                  <div className="text-sm">
                    <span className="text-black font-semibold inline-block ">
                      {selectedStudent |> SelectedStudent.name |> str}
                    </span>
                    <button
                      className="ml-2 hover:bg-gray-300 cursor-pointer"
                      onClick={_ =>
                        deselectStudent(
                          send,
                          selectedStudent |> SelectedStudent.id,
                        )
                      }>
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
                 {state.selectedStudents |> SelectedStudent.isGroupable
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
                 {state.selectedStudents |> SelectedStudent.isMoveOutable
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
        selectedStudentIds={
          state.selectedStudents |> Array.map(s => s |> SelectedStudent.id)
        }
        selectStudentCB={selectStudent(send)}
        deselectStudentCB={deselectStudent(send)}
        showEditFormCB={showEditForm(send)}
        updateTeamsCB={updateTeams(send)}
        loading={state.loading}
        setLoadingCB={setLoading(send)}
      />
    </div>
  </div>;
};
