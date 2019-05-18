open InactiveStudentsPanel__Types;

open SchoolAdmin__Utils;

let str = ReasonReact.string;

type state = {
  teams: list(Team.t),
  students: list(Student.t),
  selectedTeams: list(Team.t),
  userProfiles: list(UserProfile.t),
  searchString: string,
  tags: list(string),
  tagsFilteredBy: list(string),
  filterVisible: bool,
};

type action =
  | RefreshData(list(Team.t))
  | SelectTeam(Team.t)
  | DeselectTeam(Team.t)
  | UpdateSearchString(string)
  | AddTagFilter(string)
  | RemoveTagFilter(string);

let studentsInTeam = (students, team) =>
  students
  |> List.filter(student => Student.teamId(student) === Team.id(team));

let studentUserProfile = (userProfiles, student) =>
  userProfiles
  |> List.find(profile =>
       UserProfile.userId(profile) === Student.userId(student)
     );

let canBeMarkedActive = (selectedTeams, students) =>
  ListUtils.isEmpty(selectedTeams) ?
    false :
    {
      let teamId = selectedTeams |> List.hd |> Student.teamId;
      let selectedAllStudents =
        selectedTeams
        |> List.length
        === (
              students
              |> List.filter(student => Student.teamId(student) === teamId)
              |> List.length
            );
      selectedTeams
      |> List.for_all(student => Student.teamId(student) === teamId)
      && selectedAllStudents;
    };

let filteredTeams = state => {
  let tagFilteredTeams =
    switch (state.tagsFilteredBy) {
    | [] => state.teams
    | tags =>
      state.teams
      |> List.filter(team =>
           tags
           |> List.for_all(tag =>
                team
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
       |> studentsInTeam(state.students)
       |> List.map(s =>
            s |> studentUserProfile(state.userProfiles) |> UserProfile.name
          )
       |> List.filter(n =>
            n
            |> String.lowercase
            |> Js.String.includes(state.searchString |> String.lowercase)
          )
       |> List.length > 0
     );
};

let handleErrorCB = () => ();

let markActive = (teams, courseId, responseCB, authenticityToken) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "team_ids",
    teams
    |> List.map(s => s |> Team.id |> int_of_string)
    |> Json.Encode.(list(int)),
  );
  let url = "/school/courses/" ++ courseId ++ "/mark_teams_active";
  Api.create(url, payload, responseCB, handleErrorCB);
};

let handleActiveTeamResponse = (send, json) => {
  let message = json |> Json.Decode.(field("message", string));
  Notification.success("Success!", message);
};

let handleErrorCB = () => ();

let component = ReasonReact.reducerComponent("SA_StudentsPanel");

let make =
    (
      ~teams,
      ~courseId,
      ~students,
      ~userProfiles,
      ~authenticityToken,
      ~studentTags,
      _children,
    ) => {
  ...component,
  initialState: () => {
    teams,
    students,
    userProfiles,
    selectedTeams: [],
    searchString: "",
    tagsFilteredBy: [],
    tags: studentTags,
    filterVisible: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | RefreshData(teams) =>
      ReasonReact.Update({...state, teams})
    | SelectTeam(team) =>
      ReasonReact.Update({
        ...state,
        selectedTeams: [team, ...state.selectedTeams],
      })
    | DeselectTeam(team) =>
      ReasonReact.Update({
        ...state,
        selectedTeams:
          state.selectedTeams
          |> List.filter(s => Team.id(s) !== Team.id(team)),
      })
    | UpdateSearchString(searchString) =>
      ReasonReact.Update({...state, searchString})
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
    },
  render: ({state, send}) =>
    <div className="flex flex-1 flex-col bg-grey-lightest overflow-hidden">
      <div className="overflow-y-scroll">
        <div className="px-3">
          <div
            className="max-w-lg bg-white mx-auto relative rounded rounded-b-none border-b px-4 py-3 mt-3 w-full">
            <div className="flex items-center justify-between">
              <input
                type_="search"
                className="bg-white border rounded-lg block w-64 text-sm appearance-none leading-normal mr-2 px-3 py-2"
                placeholder="Search by student name..."
                value={state.searchString}
                onChange={
                  event =>
                    send(
                      UpdateSearchString(
                        ReactEvent.Form.target(event)##value,
                      ),
                    )
                }
              />
              <a
                className="btn btn-default no-underline"
                href={
                  "/school/courses/"
                  ++ courseId
                  ++ "/inactive_students?search="
                  ++ state.searchString
                }>
                {"Search" |> str}
              </a>
              {
                state.selectedTeams |> ListUtils.isEmpty ?
                  ReasonReact.null :
                  <button
                    onClick={
                      _e =>
                        markActive(
                          state.selectedTeams,
                          courseId,
                          handleActiveTeamResponse(send),
                          authenticityToken,
                        )
                    }
                    className="bg-transparent hover:bg-purple-dark focus:outline-none text-purple-dark text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                    {"Mark Team Active" |> str}
                  </button>
              }
            </div>
          </div>
        </div>
        <div className="flex bg-grey-lightest pb-6">
          <div className="flex flex-col max-w-lg mx-auto w-full">
            <div className="w-full py-3 rounded-b-lg">
              {
                filteredTeams(state) |> List.length > 0 ?
                  filteredTeams(state)
                  |> List.sort((team1, team2) =>
                       (team2 |> Team.id |> int_of_string)
                       - (team1 |> Team.id |> int_of_string)
                     )
                  |> List.map(team => {
                       let isSingleFounder =
                         team
                         |> studentsInTeam(state.students)
                         |> List.length == 1;
                       <div
                         key={team |> Team.id}
                         id={team |> Team.name}
                         className={
                           "student-team-container flex items-center shadow bg-white rounded-lg mb-4 overflow-hidden"
                           ++ (
                             isSingleFounder ? " hover:bg-grey-lightest" : ""
                           )
                         }>
                         {
                           let isChecked =
                             state.selectedTeams |> List.mem(team);
                           let checkboxId =
                             "select-team-" ++ (team |> Team.id);
                           <label
                             className="block text-grey leading-tight font-bold px-4 py-5"
                             htmlFor=checkboxId>
                             <input
                               className="leading-tight"
                               type_="checkbox"
                               id=checkboxId
                               checked=isChecked
                               onChange={
                                 isChecked ?
                                   _e => send(DeselectTeam(team)) :
                                   (_e => send(SelectTeam(team)))
                               }
                             />
                           </label>;
                         }
                         <div className="flex-1 w-3/5">
                           {
                             team
                             |> studentsInTeam(state.students)
                             |> List.map(student => {
                                  <div
                                    key={student |> Student.id}
                                    id={
                                      student
                                      |> studentUserProfile(
                                           state.userProfiles,
                                         )
                                      |> UserProfile.name
                                    }
                                    className="student-team__card cursor-pointer flex items-center bg-white hover:bg-grey-lightest">
                                    <div className="flex-1 w-3/5">
                                      <div className="flex items-center">
                                        <a
                                          className="flex flex-1 items-center py-4 pr-4"
                                          id={
                                            (
                                              student
                                              |> studentUserProfile(
                                                   state.userProfiles,
                                                 )
                                              |> UserProfile.name
                                            )
                                            ++ "_edit"
                                          }>
                                          <img
                                            className="w-10 h-10 rounded-full mr-4"
                                            src={
                                              student
                                              |> studentUserProfile(
                                                   state.userProfiles,
                                                 )
                                              |> UserProfile.avatarUrl
                                            }
                                          />
                                          <div
                                            className="text-sm flex flex-col">
                                            <p
                                              className={
                                                "text-black font-semibold inline-block "
                                                ++ (
                                                  state.searchString
                                                  |> String.length > 0
                                                  && student
                                                  |> studentUserProfile(
                                                       state.userProfiles,
                                                     )
                                                  |> UserProfile.name
                                                  |> String.lowercase
                                                  |> Js.String.includes(
                                                       state.searchString
                                                       |> String.lowercase,
                                                     ) ?
                                                    "bg-yellow-light" : ""
                                                )
                                              }>
                                              {
                                                student
                                                |> studentUserProfile(
                                                     state.userProfiles,
                                                   )
                                                |> UserProfile.name
                                                |> str
                                              }
                                            </p>
                                            <div className="flex">
                                              {
                                                student
                                                |> Student.tags
                                                |> List.map(tag =>
                                                     <div
                                                       key=tag
                                                       className="border border-indigo rounded mt-2 mr-1 py-1 px-2 text-xs text-indigo">
                                                       {tag |> str}
                                                     </div>
                                                   )
                                                |> Array.of_list
                                                |> ReasonReact.array
                                              }
                                            </div>
                                          </div>
                                        </a>
                                      </div>
                                    </div>
                                  </div>;
                                })
                             |> Array.of_list
                             |> ReasonReact.array
                           }
                         </div>
                         <div className="flex w-2/5 items-center">
                           <div className="w-3/5 py-4 px-3">
                             {
                               isSingleFounder ?
                                 ReasonReact.null :
                                 <div className="students-team--name mb-5">
                                   <p className="mb-1 text-xs">
                                     {"Team" |> str}
                                   </p>
                                   <h4> {team |> Team.name |> str} </h4>
                                 </div>
                             }
                           </div>
                         </div>
                       </div>;
                     })
                  |> Array.of_list
                  |> ReasonReact.array :
                  <div className="shadow bg-white rounded-lg mb-4 p-4">
                    {"No student matches your search/filter criteria." |> str}
                  </div>
              }
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
  userProfiles: list(UserProfile.t),
  studentTags: list(string),
  authenticityToken: string,
};

let decode = json =>
  Json.Decode.{
    teams: json |> field("teams", list(Team.decode)),
    courseId: json |> field("courseId", string),
    students: json |> field("students", list(Student.decode)),
    userProfiles: json |> field("userProfiles", list(UserProfile.decode)),
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
        ~userProfiles=props.userProfiles,
        ~studentTags=props.studentTags,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );