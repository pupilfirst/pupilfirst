[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = React.string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t);

type filter = {
  searchString: option(string),
  tags: array(string),
  levelId: option(string),
};

type state = {
  teams: Page.t,
  filter,
  selectedStudents: list(Student.t),
  formVisible,
  tags: list(string),
  filterVisible: bool,
};

type action =
  | SelectStudent(Student.t)
  | DeselectStudent(Student.t)
  | DeselectAllStudents
  | UpdateFormVisible(formVisible)
  | ToggleFilterVisibility
  | UpdateTeams(Page.t);

// let selectedAcrossTeams = selectedStudents =>
//   selectedStudents
//   |> List.map(s => s |> Student.id)
//   |> ListUtils.distinct
//   |> List.length > 1;

// let studentsInTeam = (students, teamId) =>
//   students |> List.filter(student => Student.teamId(student) === teamId);

// let selectedPartialTeam = (selectedStudents, teams, students) => {
//   let selectedTeam =
//     teams
//     |> List.find(t =>
//          Team.id(t) == (selectedStudents |> List.hd |> Student.teamId)
//        );
//   let studentsInSelectedTeam =
//     studentsInTeam(students, selectedTeam |> Team.id);
//   selectedStudents |> List.length < (studentsInSelectedTeam |> List.length);
// };

// let selectedWithinLevel = (selectedStudents, teams) => {
//   let teamIds =
//     selectedStudents |> List.map(student => student |> Student.teamId);
//   let selectedUniqTeams =
//     teams |> List.filter(team => List.mem(team |> Team.id, teamIds));
//   let selectedLevelNumbers =
//     selectedUniqTeams
//     |> List.map(team => team |> Team.levelId |> int_of_string);
//   selectedLevelNumbers
//   |> List.sort_uniq((ln1, ln2) => ln1 - ln2)
//   |> List.length == 1;
// };

// let isGroupable = (selectedStudents, teams, students) =>
//   selectedStudents
//   |> List.length > 1
//   && selectedWithinLevel(selectedStudents, teams)
//   && (
//     selectedAcrossTeams(selectedStudents)
//     || selectedPartialTeam(selectedStudents, teams, students)
//   );

// let isMoveOutable = (selectedStudents, students) =>
//   selectedStudents
//   |> List.length == 1
//   && selectedStudents
//   |> List.hd
//   |> Student.teamId
//   |> studentsInTeam(students)
//   |> List.length > 1;

let handleTeamUpResponse = (send, json) => {
  // let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  // let students =
  //   json |> Json.Decode.(field("students", list(Student.decode)));
  // send(RefreshDataAfterTeamUp(teams, students));
  Notification.success(
    "Success!",
    "Teams updated successfully",
  );
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

let emptyFilter = () => {searchString: None, tags: [||], levelId: None};

let initialState = tags => {
  teams: Unloaded,
  selectedStudents: [],
  filter: emptyFilter(),
  formVisible: None,
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
  | UpdateFormVisible(formVisible) => {...state, formVisible}
  | ToggleFilterVisibility => {...state, filterVisible: !state.filterVisible}
  | UpdateTeams(pagedTeams) => {...state, teams: pagedTeams}
  };

[@react.component]
let make = (~courseId, ~courseCoachIds, ~schoolCoaches, ~levels, ~studentTags) => {
  let (state, send) = React.useReducer(reducer, initialState(studentTags));

  let updateTeams = pagedTeams => send(UpdateTeams(pagedTeams));
  let selectStudent = student => send(SelectStudent(student));
  let deselectStudent = student => send(DeselectStudent(student));
  let showEditForm = student =>
    send(UpdateFormVisible(UpdateForm(student)));

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
       //  let teamCoachIds =
       //    state.teams
       //    |> List.find(team => Team.id(team) == Student.teamId(student))
       //    |> Team.coachIds;
       React.null
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
    <div className="px-6 py-2">
      <a
        className="btn btn-default no-underline"
        href={"/school/courses/" ++ courseId ++ "/inactive_students"}>
        {"Inactive Students" |> str}
      </a>
    </div>
    <div className="overflow-y-scroll">
      <StudentsEditor__TeamsList
        levels
        courseId
        tags=studentTags
        selectedLevelId={state.filter.levelId}
        search={state.filter.searchString}
        teams={state.teams}
        selectedStudents={state.selectedStudents}
        selectStudentCB=selectStudent
        deselectStudentCB=deselectStudent
        showEditFormCB=showEditForm
        updateTeamsCB=updateTeams
      />
    </div>
  </div>;
};
