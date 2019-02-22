open StudentsPanel__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Student.t);

type state = {
  teams: list(Team.t),
  selectedStudents: list(Student.t),
  searchString: string,
  formVisible,
};

type action =
  | UpdateTeams(list(Team.t))
  | SelectStudent(Student.t)
  | DeselectStudent(Student.t)
  | SelectAllStudents
  | DeselectAllStudents
  | UpdateSearchString(string)
  | UpdateFormVisible(formVisible);

let selectedAcrossTeams = selectedStudents => {
  selectedStudents |> List.map(s => s |> Student.teamId) |> List.sort_uniq((id1, id2) => id1 - id2) |> List.length > 1;
};

let selectedPartialTeam = (selectedStudents, teams) => {
  let selectedTeam = teams |> List.find(t => Team.id(t) == (selectedStudents |> List.hd |> Student.teamId));
  selectedStudents |> List.length < (selectedTeam |> Team.students |> List.length);
};

let selectedWithinLevel = (selectedStudents, teams) => {
  let teamIds = selectedStudents |> List.map(student => student |> Student.teamId);
  let selectedUniqTeams = teams |> List.filter(team => List.mem(team |> Team.id, teamIds));
  let selectedLevelNumbers = selectedUniqTeams |> List.map(team => team |> Team.levelNumber);
  selectedLevelNumbers |> List.sort_uniq((ln1, ln2) => ln1 - ln2) |> List.length == 1;
};

let isGroupable = (selectedStudents, teams) => {
  selectedStudents
  |> List.length > 1
  && selectedWithinLevel(selectedStudents, teams)
  && (selectedAcrossTeams(selectedStudents) || selectedPartialTeam(selectedStudents, teams));
};

let isMoveOutable = (selectedStudents, teams) => {
  selectedStudents
  |> List.length == 1
  && teams
  |> List.find(team => team |> Team.id == (selectedStudents |> List.hd |> Student.teamId))
  |> Team.students
  |> List.length > 1;
};

let filteredTeams = (searchString, teams) => {
  teams
  |> List.filter(team =>
       team
       |> Team.students
       |> List.map(s => s |> Student.name)
       |> List.filter(n => n |> String.lowercase |> Js.String.includes(searchString |> String.lowercase))
       |> List.length > 0
     );
};

let handleTeamUpResponse = (send, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  send(UpdateTeams(teams));
  send(DeselectAllStudents);
  Notification.success("Success!", "Teams updated successfully");
};

let teamUp = (students, responseCB, authenticityToken) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(payload, "authenticity_token", authenticityToken |> Js.Json.string);
  Js.Dict.set(payload, "founder_ids", students |> List.map(s => s |> Student.id) |> Json.Encode.(list(int)));

  let url = "/school/students/team_up";
  Api.create(url, payload, responseCB);
};

let component = ReasonReact.reducerComponent("SA_StudentsPanel");

let make = (~teams, ~courseId, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {teams, selectedStudents: [], searchString: "", formVisible: None},
  reducer: (action, state) =>
    switch (action) {
    | UpdateTeams(teams) => ReasonReact.Update({...state, teams})
    | SelectStudent(student) =>
      ReasonReact.Update({...state, selectedStudents: [student, ...state.selectedStudents]})
    | DeselectStudent(student) =>
      ReasonReact.Update({
        ...state,
        selectedStudents: state.selectedStudents |> List.filter(s => Student.id(s) !== Student.id(student)),
      })
    | SelectAllStudents =>
      ReasonReact.Update({
        ...state,
        selectedStudents: state.teams |> List.map(t => t |> Team.students) |> List.flatten,
      })
    | DeselectAllStudents => ReasonReact.Update({...state, selectedStudents: []})
    | UpdateSearchString(searchString) => ReasonReact.Update({...state, searchString})
    | UpdateFormVisible(formVisible) => ReasonReact.Update({...state, formVisible})
    },
  render: ({state, send}) => {
    <div className="flex-1 flex flex-col bg-white overflow-hidden">
      {let closeFormCB = () => send(UpdateFormVisible(None))
       let submitFormCB = teams => {send(UpdateTeams(teams))
                                    send(UpdateFormVisible(None))}
       switch (state.formVisible) {
       | None => ReasonReact.null
       | CreateForm => <SA_StudentsPanel_CreateForm courseId closeFormCB submitFormCB authenticityToken />
       | UpdateForm(student) => <SA_StudentsPanel_UpdateForm student closeFormCB submitFormCB authenticityToken />
       }}
      <div>
        <div className="border-b flex px-6 py-2 items-center justify-between">
          <div className="inline-block relative w-64">
            <select
              className="block appearance-none w-full bg-white border border-grey-light hover:border-grey px-4 py-2 pr-8 rounded leading-tight leading-normal focus:outline-none">
              <option> {"Level 1" |> str} </option>
              <option> {"Level 2" |> str} </option>
              <option> {"Level 3" |> str} </option>
            </select>
            <div className="pointer-events-none absolute pin-y pin-r flex items-center px-2 text-grey-darker">
              <svg className="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" />
              </svg>
            </div>
          </div>
          <div className="absolute pin-l pin-t mt-3 mx-4 text-purple-lighter">
            <svg
              version="1.1"
              className="h-3 text-dark"
              xmlns="http://www.w3.org/2000/svg"
              xmlnsXlink="http://www.w3.org/1999/xlink"
              x="0px"
              y="0px"
              viewBox="0 0 52.966 52.966"
              xmlSpace="preserve">
              <path
                d="M51.704,51.273L36.845,35.82c3.79-3.801,6.138-9.041,6.138-14.82c0-11.58-9.42-21-21-21s-21,9.42-21,21s9.42,21,21,21
            c5.083,0,9.748-1.817,13.384-4.832l14.895,15.491c0.196,0.205,0.458,0.307,0.721,0.307c0.25,0,0.499-0.093,0.693-0.279
            C52.074,52.304,52.086,51.671,51.704,51.273z M21.983,40c-10.477,0-19-8.523-19-19s8.523-19,19-19s19,8.523,19,19
            S32.459,40,21.983,40z"
              />
            </svg>
          </div>
        </div>
        <div className="bg-grey-lightest flex px-6 mr-3 pb-3">
          <div
            className="max-w-lg bg-white mx-auto relative rounded rounded-b-none border-b py-2 px-3 mt-3 w-full flex items-center justify-between">
            <div className="flex">
              <label className="block leading-tight mr-4 my-auto">
                <input
                  className="leading-tight"
                  type_="checkbox"
                  checked={state.selectedStudents |> List.length > 0}
                  onChange={
                    state.selectedStudents |> List.length > 0 ?
                      _e => send(DeselectAllStudents) : (_e => send(SelectAllStudents))
                  }
                />
              </label>
              <input
                type_="search"
                className="bg-white border rounded block appearance-none leading-normal mr-2"
                placeholder="Search by student name..."
                value={state.searchString}
                onChange={event => send(UpdateSearchString(ReactEvent.Form.target(event)##value))}
              />
            </div>
            <div className="flex">
              {state.selectedStudents |> List.length > 0 ?
                 <button
                   className="bg-grey-lighter hover:bg-grey-light hover:text-grey-darker focus:outline-none text-grey-dark text-sm font-semibold py-2 px-4 rounded inline-flex items-center mx-2">
                   {"Add tags" |> str}
                 </button> :
                 ReasonReact.null}
              {isGroupable(state.selectedStudents, state.teams) ?
                 <button
                   onClick={_e => teamUp(state.selectedStudents, handleTeamUpResponse(send), authenticityToken)}
                   className="bg-transparent hover:bg-purple-dark focus:outline-none text-purple-dark text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                   {"Group as Team" |> str}
                 </button> :
                 ReasonReact.null}
              {isMoveOutable(state.selectedStudents, state.teams) ?
                 <button
                   onClick={_e => teamUp(state.selectedStudents, handleTeamUpResponse(send), authenticityToken)}
                   className="bg-transparent hover:bg-purple-dark focus:outline-none text-purple-dark text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                   {"Move out from Team" |> str}
                 </button> :
                 ReasonReact.null}
              {state.selectedStudents |> List.length > 0 ?
                 ReasonReact.null :
                 <button
                   onClick={_e => send(UpdateFormVisible(CreateForm))}
                   className="hover:bg-purple-dark text-purple-dark font-semibold hover:text-white focus:outline-none border border-dashed border-blue hover:border-transparent flex items-center px-2 py-1 rounded-lg cursor-pointer">
                   <svg className="svg-icon w-6 h-6" viewBox="0 0 20 20">
                     <path
                       fill="#A8B7C7"
                       d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
                     />
                   </svg>
                   <h5 className="font-semibold ml-2"> {"Add New Students" |> str} </h5>
                 </button>}
            </div>
          </div>
        </div>
      </div>
      <div className="px-6 pb-4 flex-1 bg-grey-lightest overflow-y-scroll">
        <div className="max-w-lg mx-auto relative">
          {filteredTeams(state.searchString, state.teams)
           |> List.sort((team1, team2) => Team.id(team2) - Team.id(team1))
           |> List.map(team => {
                let isSingleFounder = team |> Team.students |> List.length == 1;
                <div
                  key={team |> Team.name}
                  className={
                    "student-team-container flex items-center shadow bg-white rounded-lg overflow-hidden mb-4"
                    ++ (isSingleFounder ? " hover:bg-grey-lighter" : "")
                  }>
                  <div className="flex-1 w-3/5">
                    {team
                     |> Team.students
                     |> List.map(student => {
                          let isChecked = state.selectedStudents |> List.mem(student);
                          <div
                            key={student |> Student.id |> string_of_int}
                            className="student-team__card cursor-pointer flex items-center bg-white hover:bg-grey-lighter">
                            <div className="flex-1 w-3/5">
                              <div className="flex items-center">
                                <label className="block text-grey leading-tight font-bold px-4 py-5">
                                  <input
                                    className="leading-tight"
                                    type_="checkbox"
                                    checked=isChecked
                                    onChange={
                                      isChecked ?
                                        _e => send(DeselectStudent(student)) : (_e => send(SelectStudent(student)))
                                    }
                                  />
                                </label>
                                <div
                                  className="flex flex-1 items-center py-4 pr-4"
                                  onClick={_e => send(UpdateFormVisible(UpdateForm(student)))}>
                                  <img className="w-10 h-10 rounded-full mr-4" src={student |> Student.avatarUrl} />
                                  <div className="text-sm">
                                    <p
                                      className={
                                        "text-black font-semibold inline-block "
                                        ++ (
                                          state.searchString
                                          |> String.length > 0
                                          && student
                                          |> Student.name
                                          |> String.lowercase
                                          |> Js.String.includes(state.searchString |> String.lowercase) ?
                                            "bg-yellow-light" : ""
                                        )
                                      }>
                                      {student |> Student.name |> str}
                                    </p>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>;
                        })
                     |> Array.of_list
                     |> ReasonReact.array}
                  </div>
                  <div className="flex w-2/5 items-center">
                    <div className="w-3/5 py-4 px-3">
                      {isSingleFounder ?
                         ReasonReact.null :
                         <div className="students-team--name mb-5">
                           <p className="mb-1 text-xs"> {"Team" |> str} </p>
                           <h4> {team |> Team.name |> str} </h4>
                         </div>}
                      <div className="coaches-avatar-group">
                        <p className="mb-2 text-xs"> {"Coaches" |> str} </p>
                        <div className="flex items-center">
                          {team
                           |> Team.coaches
                           |> List.map(coach =>
                                <img
                                  key={coach |> Coach.avatarUrl}
                                  className="w-6 h-6 rounded-full mr-2"
                                  src={coach |> Coach.avatarUrl}
                                  alt="Avatar of Jonathan Reinink"
                                />
                              )
                           |> Array.of_list
                           |> ReasonReact.array}
                        </div>
                      </div>
                    </div>
                    <div className="w-2/5 text-center">
                      <span className="inline-flex flex-col rounded bg-indigo-lightest px-2 py-1">
                        <div className="text-xs"> {"Level" |> str} </div>
                        <div className="text-xl font-semibold">
                          {team |> Team.levelNumber |> string_of_int |> str}
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
    </div>;
  },
};

type props = {
  teams: list(Team.t),
  courseId: int,
  authenticityToken: string,
};

let decode = json =>
  Json.Decode.{
    teams: json |> field("teams", list(Team.decode)),
    courseId: json |> field("courseId", int),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~teams=props.teams, ~courseId=props.courseId, ~authenticityToken=props.authenticityToken, [||]);
    },
  );
