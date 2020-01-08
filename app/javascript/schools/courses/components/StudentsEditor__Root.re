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
  loading: Loading.t,
};

type action =
  | SelectStudent(SelectedStudent.t)
  | DeselectStudent(string)
  | UpdateFormVisible(formVisible)
  | UpdateTeams(Page.t)
  | UpdateFilter(Filter.t)
  | RefreshData(tags)
  | UpdateTeam(Team.t, tags)
  | SetLoading(Loading.t);

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
  loading: Loading.NotLoading,
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

  | UpdateFormVisible(formVisible) => {...state, formVisible}
  | UpdateTeams(pagedTeams) => {
      ...state,
      pagedTeams,
      loading: Loading.NotLoading,
    }
  | UpdateFilter(filter) => {...state, filter}
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
       let title = sortBy |> Filter.sortByTitle;
       <button
         key=title
         title={"Order by " ++ title}
         onClick={_ => updateFilterCB(filter |> Filter.updateSortBy(sortBy))}
         className="w-full font-semibold text-xs p-3 text-left focus:outline-none   ">
         <i className={sortBy |> Filter.sortByIcon} />
         <span className="ml-2"> {title |> str} </span>
       </button>;
     });
};

let dropDownSelected = filter => {
  let title = filter |> Filter.sortBy |> Filter.sortByTitle;
  <button
    title={"Order by " ++ title}
    className="block bg-white leading-snug font-semibold border border-gray-400 rounded focus:outline-none focus:bg-white focus:border-gray-500 p-3 text-xs ">
    <i className={filter |> Filter.sortBy |> Filter.sortByIcon} />
    <span className="ml-2"> {title |> str} </span>
    <i className="fas fa-caret-down ml-3" />
  </button>;
};

let updateTeams = (send, pagedTeams) => send(UpdateTeams(pagedTeams));

let showEditForm = (send, student, teamId) =>
  send(UpdateFormVisible(UpdateForm(student, teamId)));

let submitForm = (send, tagsToApply) => send(RefreshData(tagsToApply));

let updateForm = (send, tagsToApply, team) => {
  switch (team) {
  | Some(t) => send(UpdateTeam(t, tagsToApply))
  | None => send(RefreshData(tagsToApply))
  };
};

let reloadTeams = (send, ()) => send(RefreshData([||]));

let setLoading = (send, loading) => send(SetLoading(loading));

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  let (state, send) = React.useReducer(reducer, initialState(studentTags));

  <div className="flex flex-1 flex-col">
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
       let team =
         teamId |> Team.unsafeFind(state.pagedTeams |> Page.teams, "Root");
       <SchoolAdmin__EditorDrawer
         closeDrawerCB={() => send(UpdateFormVisible(None))}>
         <StudentsEditor__UpdateForm
           student
           team
           studentTags={state.tags}
           courseCoachIds
           schoolCoaches
           updateFormCB={updateForm(send)}
           reloadTeamsCB={reloadTeams(send)}
         />
       </SchoolAdmin__EditorDrawer>;
     }}
    <div className="px-6 pb-4 flex-1 bg-gray-100 relative overflow-y-scroll">
      <div
        className="max-w-3xl w-full mx-auto flex justify-between border-b mt-4">
        <ul className="flex font-semibold text-sm items-end">
          <li
            className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
            <span> {"All Students" |> str} </span>
          </li>
          <li
            className="rounded-t-lg cursor-pointer border-b-3 border-transparent hover:bg-gray-200 hover:text-gray-900">
            <a
              className="block px-3 py-3 md:py-2 text-gray-800"
              href={"/school/courses/" ++ courseId ++ "/inactive_students"}>
              {"Inactive Students" |> str}
            </a>
          </li>
        </ul>
        {state.selectedStudents |> Array.length > 0
           ? React.null
           : <div className="pb-2">
               <button
                 onClick={_e => send(UpdateFormVisible(CreateForm))}
                 className="btn btn-primary ml-4">
                 <i className="fas fa-user-plus mr-2" />
                 <span> {"Add New Students" |> str} </span>
               </button>
             </div>}
      </div>
      <div className="bg-gray-100 sticky top-0 py-3">
        <div className="border rounded-lg mx-auto max-w-3xl p-5 bg-white ">
          <div>
            <div className="flex w-full items-end">
              <StudentsEditor__Search
                filter={state.filter}
                updateFilterCB={updateFilter(send)}
                tags={state.tags}
                levels
              />
              <div className="ml-2 flex-shrink-0">
                <label className="block text-tiny uppercase font-semibold">
                  {"Sort by:" |> str}
                </label>
                <div className="mt-1">
                  {<Dropdown
                     right=true
                     selected={dropDownSelected(state.filter)}
                     contents={dropDownContents(
                       updateFilter(send),
                       state.filter,
                     )}
                   />}
                </div>
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
                        <span
                          className="text-black font-semibold inline-block ">
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
      </div>
      {state.selectedStudents |> ArrayUtils.isEmpty
         ? React.null
         : <div className="px-6">
             <div
               className="max-w-3xl h-16 mx-auto relative rounded border-b p-4 mt-3 w-full flex items-center justify-between">
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
      <div>
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
          updateFilterCB={updateFilter(send)}
        />
      </div>
    </div>
    {let loading =
       switch (state.loading) {
       | NotLoading => false
       | Reloading => true
       | LoadingMore => false
       };
     <LoadingSpinner loading />}
  </div>;
};
