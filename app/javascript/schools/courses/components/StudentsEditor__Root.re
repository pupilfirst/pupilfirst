[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = React.string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t);

type state = {
  teams: list(Team.t),
  selectedStudents: list(Student.t),
  searchString: string,
  formVisible,
  selectedLevelId: option(int),
  tags: list(string),
  tagsFilteredBy: list(string),
  filterVisible: bool,
};

type action =
  | SelectStudent(Student.t)
  | DeselectStudent(Student.t)
  | DeselectAllStudents
  | UpdateSearchString(string)
  | UpdateFormVisible(formVisible)
  | UpdateSelectedLevelId(option(int))
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
    selectedUniqTeams
    |> List.map(team => team |> Team.levelId |> int_of_string);
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

let handleTeamUpResponse = (send, json) => {
  // let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  let students =
    json |> Json.Decode.(field("students", list(Student.decode)));
  // send(RefreshDataAfterTeamUp(teams, students));
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

let initialState = tags => {
  teams: [],
  selectedStudents: [],
  searchString: "",
  formVisible: None,
  selectedLevelId: None,
  tagsFilteredBy: [],
  tags,
  filterVisible: false,
};

let reducer = (state, action) =>
  switch (action) {
  | SelectStudent(student) => {
      ...state,
      selectedStudents: [student, ...state.selectedStudents],
    }

  | DeselectStudent(student) => {
      ...state,
      selectedStudents:
        state.selectedStudents
        |> List.filter(s => Student.id(s) !== Student.id(student)),
    }

  | DeselectAllStudents => {...state, selectedStudents: []}
  | UpdateSearchString(searchString) => {...state, searchString}
  | UpdateFormVisible(formVisible) => {...state, formVisible}
  | UpdateSelectedLevelId(selectedLevelId) => {...state, selectedLevelId}
  | AddTagFilter(tag) => {
      ...state,
      tagsFilteredBy: [tag, ...state.tagsFilteredBy],
    }
  | RemoveTagFilter(tag) => {
      ...state,
      tagsFilteredBy: state.tagsFilteredBy |> List.filter(t => t !== tag),
    }
  | ToggleFilterVisibility => {...state, filterVisible: !state.filterVisible}
  };

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  let (state, send) = React.useReducer(reducer, initialState(studentTags));
  <div className="flex flex-1 flex-col bg-gray-100 overflow-hidden">
    {let submitFormCB = (teams, students, tags) => ();
     switch (state.formVisible) {
     | None => ReasonReact.null
     | CreateForm =>
       <SchoolAdmin__EditorDrawer
         closeDrawerCB={() => send(UpdateFormVisible(None))}>
         <SA_StudentsPanel_CreateForm
           courseId
           submitFormCB
           studentTags={state.tags}
           authenticityToken=""
         />
       </SchoolAdmin__EditorDrawer>
     | UpdateForm(student) =>
       let teamCoachIds =
         state.teams
         |> List.find(team => Team.id(team) == Student.teamId(student))
         |> Team.coachIds;
       React.null;
     //  <SchoolAdmin__EditorDrawer
     //    closeDrawerCB={() => send(UpdateFormVisible(None))}>
     //   //  <SA_StudentsPanel_UpdateForm
     //   //    student
     //   //    isSingleFounder=false
     //   //    teams={state.teams}
     //   //    studentTags={state.tags}
     //   //    teamCoachIds
     //   //    courseCoachIds
     //   //    schoolCoaches
     //   //    submitFormCB
     //   //    authenticityToken=""
     //   //  />
     //  </SchoolAdmin__EditorDrawer>;
     }}
    <div
      className="border-b px-6 py-2 bg-white flex items-center justify-between z-20">
      <div>
        <a
          className="btn btn-default no-underline"
          href={"/school/courses/" ++ courseId ++ "/inactive_students"}>
          {"Inactive Students" |> str}
        </a>
      </div>
    </div>
    <div className="overflow-y-scroll">
      <div className="flex bg-gray-100 pb-6 px-6">
        <div className="flex flex-col max-w-3xl mx-auto w-full">
          <div className="w-full py-3 rounded-b-lg">
            {state.teams
             |> List.map(team => {
                  let singleStudent = team |> Team.singleStudent;
                  <div
                    key={team |> Team.id}
                    id={team |> Team.name}
                    className="student-team-container flex items-strecth shadow bg-white rounded-lg mb-4 overflow-hidden">
                    <div className="flex flex-col flex-1 w-3/5">
                      {team
                       |> Team.students
                       |> Array.map(student => {
                            let isChecked =
                              state.selectedStudents |> List.mem(student);
                            let checkboxId =
                              "select-student-" ++ (student |> Student.id);
                            <div
                              key={student |> Student.id}
                              id={student |> Student.name}
                              className="student-team__card h-full cursor-pointer flex items-center bg-white">
                              <div className="flex flex-1 w-3/5 h-full">
                                <div className="flex items-center w-full">
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
                                              send(DeselectStudent(student))
                                          : (
                                            _e =>
                                              send(SelectStudent(student))
                                          )
                                      }
                                    />
                                  </label>
                                  <a
                                    className="flex flex-1 self-stretch items-center py-4 px-4 hover:bg-gray-100"
                                    id={(student |> Student.name) ++ "_edit"}
                                    onClick={_e =>
                                      send(
                                        UpdateFormVisible(
                                          UpdateForm(student),
                                        ),
                                      )
                                    }>
                                    {switch (student |> Student.avatarUrl) {
                                     | Some(avatarUrl) =>
                                       <img
                                         className="w-10 h-10 rounded-full mr-4 object-cover"
                                         src=avatarUrl
                                       />
                                     | None =>
                                       <Avatar
                                         name={student |> Student.name}
                                         className="w-10 h-10 mr-4"
                                       />
                                     }}
                                    <div className="text-sm flex flex-col">
                                      <p
                                        className={
                                          "text-black font-semibold inline-block "
                                          ++ (
                                            state.searchString
                                            |> String.length > 0
                                            && student
                                            |> Student.name
                                            |> String.lowercase_ascii
                                            |> Js.String.includes(
                                                 state.searchString
                                                 |> String.lowercase_ascii,
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
                       |> React.array}
                    </div>
                    <div className="flex w-2/5 items-center">
                      <div className="w-3/5 py-4 px-3">
                        {singleStudent
                           ? ReasonReact.null
                           : <div className="students-team--name mb-5">
                               <p className="text-xs"> {"Team" |> str} </p>
                               <h4> {team |> Team.name |> str} </h4>
                             </div>}
                        {team |> Team.coachIds |> ListUtils.isEmpty
                           ? ReasonReact.null
                           : <div className="coaches-avatar-group">
                               <p className="text-xs pb-1">
                                 {(
                                    singleStudent
                                      ? "Personal Coaches" : "Team Coaches"
                                  )
                                  |> str}
                               </p>
                               <div className="flex items-center flex-wrap">
                                 {let teamCoaches =
                                    schoolCoaches
                                    |> List.filter(coach =>
                                         team
                                         |> Team.coachIds
                                         |> List.exists(teamCoachId =>
                                              teamCoachId == Coach.id(coach)
                                            )
                                       );
                                  teamCoaches
                                  |> List.map(coach =>
                                       <Avatar
                                         key={coach |> Coach.id}
                                         name={coach |> Coach.name}
                                         className="w-6 h-6 rounded-full mr-1 mt-1"
                                       />
                                     )
                                  |> Array.of_list
                                  |> ReasonReact.array}
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
                            {team |> Team.levelId |> str}
                          </div>
                        </span>
                      </div>
                    </div>
                  </div>;
                })
             |> Array.of_list
             |> ReasonReact.array}
          </div>
        </div>
      </div>
    </div>
  </div>;
};
