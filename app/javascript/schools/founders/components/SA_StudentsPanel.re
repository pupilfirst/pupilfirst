open StudentsPanel__Types;

let str = ReasonReact.string;

type state = {selectedStudents: list(Student.t)};

type action =
  | SelectStudent(Student.t)
  | DeselectStudent(Student.t)
  | SelectAllStudents
  | DeselectAllStudents;

let selectedAcrossTeams = selectedStudents => {
  selectedStudents |> List.map(s => s |> Student.teamId) |> List.sort_uniq((id1, id2) => id1 - id2) |> List.length > 1;
};

let selectedPartialTeam = (selectedStudents, teams) => {
  let selectedTeam = teams |> List.find(t => Team.id(t) == (selectedStudents |> List.hd |> Student.teamId));
  selectedStudents |> List.length < (selectedTeam |> Team.students |> List.length);
};

let isGroupable = (selectedStudents, teams) => {
  selectedStudents
  |> List.length > 1
  && (selectedAcrossTeams(selectedStudents) || selectedPartialTeam(selectedStudents, teams));
};

let component = ReasonReact.reducerComponent("SA_StudentsPanel");

let make = (~teams, _children) => {
  ...component,
  initialState: () => {selectedStudents: []},
  reducer: (action, state) =>
    switch (action) {
    | SelectStudent(student) => ReasonReact.Update({selectedStudents: [student, ...state.selectedStudents]})
    | DeselectStudent(student) =>
      ReasonReact.Update({
        selectedStudents: state.selectedStudents |> List.filter(s => Student.id(s) !== Student.id(student)),
      })
    | SelectAllStudents =>
      ReasonReact.Update({selectedStudents: teams |> List.map(t => t |> Team.students) |> List.flatten})
    | DeselectAllStudents => ReasonReact.Update({selectedStudents: []})
    },
  render: ({state, send}) =>
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
        <div className="relative ml-3 my-2 md:w-1/4">
          <input
            type_="search"
            className="bg-white border rounded py-2 pr-4 pl-10 block w-full appearance-none leading-normal"
            placeholder="Search..."
          />
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
      <div className="bg-grey-lightest flex px-6 mr-3">
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
            <button
              className="hover:bg-purple-dark text-purple-dark font-semibold hover:text-white focus:outline-none border border-dashed border-blue hover:border-transparent flex items-center px-2 py-1 rounded-lg cursor-pointer">
              <svg className="svg-icon w-6 h-6" viewBox="0 0 20 20">
                <path
                  fill="#A8B7C7"
                  d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
                />
              </svg>
              <h5 className="font-semibold ml-2"> {"Add new Student" |> str} </h5>
            </button>
          </div>
          <div className="flex">
            <button
              className="bg-grey-lighter hover:bg-grey-light hover:text-grey-darker focus:outline-none text-grey-dark text-sm font-semibold py-2 px-4 rounded inline-flex items-center mx-2">
              {"Add tags" |> str}
            </button>
            {isGroupable(state.selectedStudents, teams) ?
               <button
                 className="bg-transparent hover:bg-purple-dark focus:outline-none text-purple-dark text-sm font-semibold hover:text-white py-2 px-4 border border-puple hover:border-transparent rounded">
                 {"Group as Team" |> str}
               </button> :
               ReasonReact.null}
          </div>
        </div>
      </div>
      <div className="px-6 pb-4 flex-1 bg-grey-lightest overflow-y-scroll">
        <div className="max-w-lg mx-auto relative">
          {teams
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
                                <div className="flex items-center py-4 pr-4">
                                  <img className="w-10 h-10 rounded-full mr-4" src={student |> Student.avatarUrl} />
                                  <div className="text-sm">
                                    <p className="text-black font-semibold"> {student |> Student.name |> str} </p>
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
                      <span className="inline-flex rounded bg-indigo-lightest px-2 py-1 text-xs font-semibold">
                        {"Level 1" |> str}
                      </span>
                    </div>
                  </div>
                </div>;
              })
           |> Array.of_list
           |> ReasonReact.array}
        </div>
      </div>
    </div>,
};

type props = {teams: list(Team.t)};

let decode = json => Json.Decode.{teams: json |> field("teams", list(Team.decode))};

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~teams=props.teams, [||]);
    },
  );
