open StudentsPanel__Types;

let str = ReasonReact.string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t);

type state = {
  teams: list(Team.t),
  students: list(Student.t),
  selectedStudents: list(Student.t),
  searchString: string,
  formVisible,
  selectedLevelNumber: option(int),
  tags: list(string),
  tagsFilteredBy: list(string),
  filterVisible: bool,
};

type action =
  | UpdateTeams(list(Team.t))
  | UpdateStudents(list(Student.t))
  | RefreshData(list(Team.t), list(Student.t))
  | SelectStudent(Student.t)
  | DeselectStudent(Student.t)
  | SelectAllStudents
  | DeselectAllStudents
  | UpdateSearchString(string)
  | UpdateFormVisible(formVisible)
  | UpdateSelectedLevelNumber(option(int))
  | AddNewTags(list(string))
  | AddTagFilter(string)
  | RemoveTagFilter(string)
  | ToggleFilterVisibility;

let selectedAcrossTeams = selectedStudents =>
  selectedStudents
  |> List.map(s => s |> Student.teamId)
  |> ListUtils.distinct
  |> List.length > 1;

let studentsInTeam = (students, teamId) =>
  students |> List.filter(student => Student.teamId(student) === teamId);

let selectedPartialTeam = (selectedStudents, teams, students) => {
  let selectedTeam =
    teams
    |> List.find(t =>
         Team.id(t) == (selectedStudents |> List.hd |> Student.teamId)
       );
  let studentsInSelectedTeam =
    studentsInTeam(students, selectedTeam |> Team.id);
  selectedStudents |> List.length < (studentsInSelectedTeam |> List.length);
};

let selectedWithinLevel = (selectedStudents, teams) => {
  let teamIds =
    selectedStudents |> List.map(student => student |> Student.teamId);
  let selectedUniqTeams =
    teams |> List.filter(team => List.mem(team |> Team.id, teamIds));
  let selectedLevelNumbers =
    selectedUniqTeams |> List.map(team => team |> Team.levelNumber);
  selectedLevelNumbers
  |> List.sort_uniq((ln1, ln2) => ln1 - ln2)
  |> List.length == 1;
};

let isGroupable = (selectedStudents, teams, students) =>
  selectedStudents
  |> List.length > 1
  && selectedWithinLevel(selectedStudents, teams)
  && (
    selectedAcrossTeams(selectedStudents)
    || selectedPartialTeam(selectedStudents, teams, students)
  );

let isMoveOutable = (selectedStudents, students) =>
  selectedStudents
  |> List.length == 1
  && selectedStudents
  |> List.hd
  |> Student.teamId
  |> studentsInTeam(students)
  |> List.length > 1;

let filteredTeams = state => {
  let levelFilteredTeams =
    switch (state.selectedLevelNumber) {
    | None => state.teams
    | Some(n) =>
      state.teams |> List.filter(team => team |> Team.levelNumber == n)
    };
  let tagFilteredTeams =
    switch (state.tagsFilteredBy) {
    | [] => levelFilteredTeams
    | tags =>
      levelFilteredTeams
      |> List.filter(team =>
           tags
           |> List.for_all(tag =>
                team
                |> Team.id
                |> studentsInTeam(state.students)
                |> List.map(student => student |> Student.tags)
                |> List.flatten
                |> List.mem(tag)
              )
         )
    };
  tagFilteredTeams
  |> List.filter(team =>
       team
       |> Team.id
       |> studentsInTeam(state.students)
       |> List.map(s => s |> Student.name)
       |> List.filter(n =>
            n
            |> String.lowercase
            |> Js.String.includes(state.searchString |> String.lowercase)
          )
       |> List.length > 0
     );
};

let handleTeamUpResponse = (send, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  let students =
    json |> Json.Decode.(field("students", list(Student.decode)));
  send(RefreshData(teams, students));
  send(DeselectAllStudents);
  Notification.success("Success!", "Teams updated successfully");
};

let handleErrorCB = () => ();

let teamUp = (students, responseCB, authenticityToken) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "founder_ids",
    students |> List.map(s => s |> Student.id) |> Json.Encode.(list(string)),
  );
  let url = "/school/students/team_up";
  Api.create(url, payload, responseCB, handleErrorCB);
};

let component = ReasonReact.reducerComponent("SA_StudentsPanel");

let make =
    (
      ~teams,
      ~courseId,
      ~students,
      ~courseCoachIds,
      ~schoolCoaches,
      ~authenticityToken,
      ~levels,
      ~studentTags,
      _children,
    ) => {
  ...component,
  initialState: () => {
    teams,
    students,
    selectedStudents: [],
    searchString: "",
    formVisible: None,
    selectedLevelNumber: None,
    tagsFilteredBy: [],
    tags: studentTags,
    filterVisible: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | RefreshData(teams, students) =>
      ReasonReact.Update({...state, teams, students})

    | UpdateTeams(teams) => ReasonReact.Update({...state, teams})
    | UpdateStudents(students) => ReasonReact.Update({...state, students})
    | SelectStudent(student) =>
      ReasonReact.Update({
        ...state,
        selectedStudents: [student, ...state.selectedStudents],
      })
    | DeselectStudent(student) =>
      ReasonReact.Update({
        ...state,
        selectedStudents:
          state.selectedStudents
          |> List.filter(s => Student.id(s) !== Student.id(student)),
      })
    | SelectAllStudents =>
      ReasonReact.Update({
        ...state,
        selectedStudents:
          state.teams
          |> List.map(t => t |> Team.id |> studentsInTeam(state.students))
          |> List.flatten,
      })
    | DeselectAllStudents =>
      ReasonReact.Update({...state, selectedStudents: []})
    | UpdateSearchString(searchString) =>
      ReasonReact.Update({...state, searchString})
    | UpdateFormVisible(formVisible) =>
      ReasonReact.Update({...state, formVisible})
    | UpdateSelectedLevelNumber(selectedLevelNumber) =>
      ReasonReact.Update({...state, selectedLevelNumber})
    | AddTagFilter(tag) =>
      ReasonReact.Update({
        ...state,
        tagsFilteredBy: [tag, ...state.tagsFilteredBy],
      })
    | RemoveTagFilter(tag) =>
      ReasonReact.Update({
        ...state,
        tagsFilteredBy: state.tagsFilteredBy |> List.filter(t => t !== tag),
      })
    | AddNewTags(tags) =>
      ReasonReact.Update({
        ...state,
        tags:
          List.append(tags, state.tags) |> List.sort_uniq(String.compare),
      })
    | ToggleFilterVisibility =>
      ReasonReact.Update({...state, filterVisible: !state.filterVisible})
    },
  render: ({state, send}) =>
    <div className="flex flex-1 flex-col bg-gray-100 overflow-hidden">
      {
        let closeFormCB = () => send(UpdateFormVisible(None));
        let submitFormCB = (teams, students, tags) => {
          send(RefreshData(teams, students));
          send(AddNewTags(tags));
          send(UpdateFormVisible(None));
        };
        switch (state.formVisible) {
        | None => ReasonReact.null
        | CreateForm =>
          <SA_StudentsPanel_CreateForm
            courseId
            closeFormCB
            submitFormCB
            studentTags={state.tags}
            authenticityToken
          />
        | UpdateForm(student) =>
          let teamCoachIds =
            state.teams
            |> List.find(team => Team.id(team) == Student.teamId(student))
            |> Team.coachIds;

          let isSingleFounder =
            student
            |> Student.teamId
            |> studentsInTeam(state.students)
            |> List.length == 1;

          <SA_StudentsPanel_UpdateForm
            student
            isSingleFounder
            teams={state.teams}
            studentTags={state.tags}
            teamCoachIds
            courseCoachIds
            schoolCoaches
            closeFormCB
            submitFormCB
            authenticityToken
          />;
        };
      }
      <div
        className="border-b px-6 py-2 bg-white flex items-center justify-between z-20">
        <div className="inline-block relative w-64">
          <select
            onChange={event => {
              let level_number = ReactEvent.Form.target(event)##value;
              send(
                UpdateSelectedLevelNumber(
                  level_number == "all"
                    ? None : Some(level_number |> int_of_string),
                ),
              );
            }}
            value={
              switch (state.selectedLevelNumber) {
              | None => "all"
              | Some(n) => n |> string_of_int
              }
            }
            className="block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded leading-tight leading-normal focus:outline-none">
            <option value="all"> {"All levels" |> str} </option>
            {levels
             |> List.map(level =>
                  <option
                    key={level |> Level.number |> string_of_int}
                    value={level |> Level.number |> string_of_int}>
                    {"Level "
                     ++ (level |> Level.number |> string_of_int)
                     ++ ": "
                     ++ (level |> Level.name)
                     |> str}
                  </option>
                )
             |> Array.of_list
             |> ReasonReact.array}
          </select>
          <div
            className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-gray-800">
            <i className="fas fa-chevron-down text-sm" />
          </div>
        </div>
        <div>
          <a
            className="btn btn-default no-underline"
            href={"/school/courses/" ++ courseId ++ "/inactive_students"}>
            {"Inactive Students" |> str}
          </a>
        </div>
      </div>
      <div className="overflow-y-scroll">
        <div className="px-6">
          <div
            className="max-w-3xl h-16 mx-auto relative rounded border-b p-4 mt-3 w-full flex items-center justify-between">
            <div className="flex">
              <label className="flex items-center leading-tight mr-4 my-auto">
                <input
                  className="leading-tight"
                  type_="checkbox"
                  htmlFor="selected-students"
                  checked={state.selectedStudents |> List.length > 0}
                  onChange={
                    state.selectedStudents |> List.length > 0
                      ? _e => send(DeselectAllStudents)
                      : (_e => send(SelectAllStudents))
                  }
                />
                <span
                  id="selected-students"
                  className="ml-2 text-sm text-gray-600">
                  {
                    let selectedCount = state.selectedStudents |> List.length;
                    let studentCount =
                      filteredTeams(state)
                      |> List.map(team =>
                           team |> Team.id |> studentsInTeam(state.students)
                         )
                      |> List.flatten
                      |> List.length;
                    selectedCount > 0
                      ? (selectedCount |> string_of_int) ++ " selected" |> str
                      : (studentCount |> string_of_int) ++ " students" |> str;
                  }
                </span>
              </label>
            </div>
            <div className="flex">
              {false
                 ? <button
                     className="bg-gray-200 hover:bg-gray-400 hover:text-gray-800 focus:outline-none text-gray-600 text-sm font-semibold py-2 px-4 rounded inline-flex items-center mx-2">
                     {"Add tags" |> str}
                   </button>
                 : ReasonReact.null}
              {isGroupable(state.selectedStudents, state.teams, students)
                 ? <button
                     onClick={_e =>
                       teamUp(
                         state.selectedStudents,
                         handleTeamUpResponse(send),
                         authenticityToken,
                       )
                     }
                     className="bg-transparent hover:bg-purple-600 focus:outline-none text-purple-600 text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                     {"Group as Team" |> str}
                   </button>
                 : ReasonReact.null}
              {isMoveOutable(state.selectedStudents, state.students)
                 ? <button
                     onClick={_e =>
                       teamUp(
                         state.selectedStudents,
                         handleTeamUpResponse(send),
                         authenticityToken,
                       )
                     }
                     className="bg-transparent hover:bg-purple-600 focus:outline-none text-purple-600 text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                     {"Move out from Team" |> str}
                   </button>
                 : ReasonReact.null}
              {state.selectedStudents |> List.length > 0
                 ? ReasonReact.null
                 : <button
                     onClick={_e => send(UpdateFormVisible(CreateForm))}
                     className="btn btn-primary ml-4">
                     <i className="fas fa-user-plus mr-2" />
                     <span> {"Add New Students" |> str} </span>
                   </button>}
            </div>
          </div>
          <div
            className="max-w-3xl bg-white mx-auto relative rounded rounded-b-none border-b py-3 mt-3 w-full">
            <div className="flex items-center justify-between pl-3">
              <input
                type_="search"
                className="bg-white border rounded-lg block w-64 text-sm appearance-none leading-normal mr-2 px-3 py-2"
                placeholder="Search by student name..."
                value={state.searchString}
                onChange={event =>
                  send(
                    UpdateSearchString(ReactEvent.Form.target(event)##value),
                  )
                }
              />
              <div
                onClick={_e => send(ToggleFilterVisibility)}
                className="flex text-indigo items-center mr-3">
                <p className="text-sm font-semibold mr-1">
                  {(state.filterVisible ? "Hide" : "Show") ++ " Filters" |> str}
                </p>
                <FaIcon.Jsx2
                  classes={
                    "fas ml-1 text-sm"
                    ++ (
                      state.filterVisible
                        ? " fa-chevron-up" : " fa-chevron-down"
                    )
                  }
                />
              </div>
            </div>
          </div>
        </div>
        <div className="flex bg-gray-100 pb-6 px-6">
          <div className="flex flex-col max-w-3xl mx-auto w-full">
            {state.filterVisible && state.tags |> List.length > 0
               ? <div className="px-4 py-3 border-b bg-gray-200 shadow">
                   <div className="flex flex-col pt-2">
                     <div className="mb-1 text-sm"> {"Filters:" |> str} </div>
                     <SA_StudentsPanel_SearchableTagList
                       unselectedTags={
                         state.tags
                         |> List.filter(tag =>
                              !(state.tagsFilteredBy |> List.mem(tag))
                            )
                       }
                       selectedTags={state.tagsFilteredBy}
                       addTagCB={tag => send(AddTagFilter(tag))}
                       removeTagCB={tag => send(RemoveTagFilter(tag))}
                       allowNewTags=false
                     />
                   </div>
                 </div>
               : ReasonReact.null}
            <div className="w-full py-3 rounded-b-lg">
              {filteredTeams(state) |> List.length > 0
                 ? filteredTeams(state)
                   |> List.map(team => {
                        let isSingleFounder =
                          team
                          |> Team.id
                          |> studentsInTeam(state.students)
                          |> List.length == 1;
                        <div
                          key={team |> Team.id}
                          id={team |> Team.name}
                          className="student-team-container flex items-strecth shadow bg-white rounded-lg mb-4 overflow-hidden">
                          <div className="flex flex-col flex-1 w-3/5">
                            {team
                             |> Team.id
                             |> studentsInTeam(state.students)
                             |> List.map(student => {
                                  let isChecked =
                                    state.selectedStudents
                                    |> List.mem(student);
                                  let checkboxId =
                                    "select-student-"
                                    ++ (student |> Student.id);
                                  <div
                                    key={student |> Student.id}
                                    id={student |> Student.name}
                                    className="student-team__card h-full cursor-pointer flex items-center bg-white">
                                    <div className="flex flex-1 w-3/5 h-full">
                                      <div
                                        className="flex items-center w-full">
                                        <label
                                          className="flex items-center h-full border-r text-gray-500 leading-tight font-bold px-4 py-5 hover:bg-gray-100"
                                          htmlFor=checkboxId>
                                          <input
                                            className="leading-tight"
                                            type_="checkbox"
                                            id=checkboxId
                                            checked=isChecked
                                            onChange={
                                              isChecked
                                                ? _e =>
                                                    send(
                                                      DeselectStudent(
                                                        student,
                                                      ),
                                                    )
                                                : (
                                                  _e =>
                                                    send(
                                                      SelectStudent(student),
                                                    )
                                                )
                                            }
                                          />
                                        </label>
                                        <a
                                          className="flex flex-1 self-stretch items-center py-4 px-4 hover:bg-gray-100"
                                          id={
                                            (student |> Student.name)
                                            ++ "_edit"
                                          }
                                          onClick={_e =>
                                            send(
                                              UpdateFormVisible(
                                                UpdateForm(student),
                                              ),
                                            )
                                          }>
                                          {switch (
                                             student |> Student.avatarUrl
                                           ) {
                                           | Some(avatarUrl) =>
                                             <img
                                               className="w-10 h-10 rounded-full mr-4 object-cover"
                                               src=avatarUrl
                                             />
                                           | None =>
                                             <Avatar.Jsx2
                                               name={student |> Student.name}
                                               className="w-10 h-10 mr-4"
                                             />
                                           }}
                                          <div
                                            className="text-sm flex flex-col">
                                            <p
                                              className={
                                                "text-black font-semibold inline-block "
                                                ++ (
                                                  state.searchString
                                                  |> String.length > 0
                                                  && student
                                                  |> Student.name
                                                  |> String.lowercase
                                                  |> Js.String.includes(
                                                       state.searchString
                                                       |> String.lowercase,
                                                     )
                                                    ? "bg-yellow-400" : ""
                                                )
                                              }>
                                              {student |> Student.name |> str}
                                            </p>
                                            <div className="flex flex-wrap">
                                              {student
                                               |> Student.tags
                                               |> List.map(tag =>
                                                    <div
                                                      key=tag
                                                      className="bg-gray-200 border border-gray-500 rounded-lg mt-1 mr-1 py-px px-2 text-xs text-gray-900">
                                                      {tag |> str}
                                                    </div>
                                                  )
                                               |> Array.of_list
                                               |> ReasonReact.array}
                                            </div>
                                          </div>
                                        </a>
                                      </div>
                                    </div>
                                  </div>;
                                })
                             |> Array.of_list
                             |> ReasonReact.array}
                          </div>
                          <div className="flex w-2/5 items-center">
                            <div className="w-3/5 py-4 px-3">
                              {isSingleFounder
                                 ? ReasonReact.null
                                 : <div className="students-team--name mb-5">
                                     <p className="text-xs">
                                       {"Team" |> str}
                                     </p>
                                     <h4> {team |> Team.name |> str} </h4>
                                   </div>}
                              {team |> Team.coachIds |> ListUtils.isEmpty
                                 ? ReasonReact.null
                                 : <div className="coaches-avatar-group">
                                     <p className="text-xs pb-1">
                                       {(
                                          isSingleFounder
                                            ? "Personal Coaches"
                                            : "Team Coaches"
                                        )
                                        |> str}
                                     </p>
                                     <div
                                       className="flex items-center flex-wrap">
                                       {
                                         let teamCoaches =
                                           schoolCoaches
                                           |> List.filter(coach =>
                                                team
                                                |> Team.coachIds
                                                |> List.exists(teamCoachId =>
                                                     teamCoachId
                                                     == Coach.id(coach)
                                                   )
                                              );
                                         teamCoaches
                                         |> List.map(coach =>
                                              <Avatar.Jsx2
                                                key={coach |> Coach.id}
                                                name={coach |> Coach.name}
                                                className="w-6 h-6 rounded-full mr-1 mt-1"
                                              />
                                            )
                                         |> Array.of_list
                                         |> ReasonReact.array;
                                       }
                                     </div>
                                   </div>}
                            </div>
                            <div className="w-2/5 text-center">
                              <span
                                className="inline-flex flex-col items-center rounded bg-gray-200 px-2 pt-2 pb-1 border">
                                <div className="text-xs font-semibold">
                                  {"Level" |> str}
                                </div>
                                <div className="font-bold">
                                  {team
                                   |> Team.levelNumber
                                   |> string_of_int
                                   |> str}
                                </div>
                              </span>
                            </div>
                          </div>
                        </div>;
                      })
                   |> Array.of_list
                   |> ReasonReact.array
                 : <div className="shadow bg-white rounded-lg mb-4 p-4">
                     {"No student matches your search/filter criteria." |> str}
                   </div>}
            </div>
          </div>
        </div>
      </div>
    </div>,
};

type props = {
  teams: list(Team.t),
  courseId: string,
  students: list(Student.t),
  courseCoachIds: list(string),
  schoolCoaches: list(Coach.t),
  levels: list(Level.t),
  studentTags: list(string),
  authenticityToken: string,
};

let decode = json =>
  Json.Decode.{
    teams: json |> field("teams", list(Team.decode)),
    courseId: json |> field("courseId", string),
    students: json |> field("students", list(Student.decode)),
    courseCoachIds: json |> field("courseCoachIds", list(string)),
    schoolCoaches: json |> field("schoolCoaches", list(Coach.decode)),
    levels: json |> field("levels", list(Level.decode)),
    studentTags: json |> field("studentTags", list(string)),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~teams=props.teams,
        ~courseId=props.courseId,
        ~students=props.students,
        ~courseCoachIds=props.courseCoachIds,
        ~schoolCoaches=props.schoolCoaches,
        ~levels=props.levels,
        ~studentTags=props.studentTags,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );
