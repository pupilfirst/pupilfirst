open StudentsPanel__Types;

open SchoolAdmin__Utils;

type teamCoachlist = (int, string, bool);

type state = {
  name: string,
  teamName: string,
  hasNameError: bool,
  hasTeamNameError: bool,
  tagsToApply: list(string),
  exited: bool,
  teamCoaches: list(teamCoachlist),
  coachEnrollmentsChanged: bool,
  excludedFromLeaderboard: bool,
};

type action =
  | UpdateName(string)
  | UpdateTeamName(string)
  | UpdateErrors(bool, bool)
  | AddTag(string)
  | RemoveTag(string)
  | UpdateExited(bool)
  | UpdateCoachesList(int, string, bool)
  | UpdateExcludedFromLeaderboard(bool);

let component = ReasonReact.reducerComponent("SA_StudentsPanel_UpdateForm");

let str = ReasonReact.string;

let updateName = (send, state, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name));
  send(UpdateErrors(hasError, state.hasTeamNameError));
};

let updateTeamName = (send, state, teamName) => {
  let hasError = teamName |> String.length < 3;
  send(UpdateTeamName(teamName));
  send(UpdateErrors(state.hasNameError, hasError));
};

let formInvalid = state => state.hasNameError || state.hasTeamNameError;

let handleErrorCB = () => ();

let handleResponseCB = (submitCB, state, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  let students =
    json |> Json.Decode.(field("students", list(Student.decode)));
  let userProfiles =
    json |> Json.Decode.(field("userProfiles", list(UserProfile.decode)));
  submitCB(teams, students, userProfiles, state.tagsToApply);
  Notification.success("Success", "Student updated successfully");
};

let updateStudent = (student, state, authenticityToken, responseCB) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  let enrolledCoachIds =
    state.teamCoaches
    |> List.filter(((_, _, selected)) => selected == true)
    |> List.map(((key, _, _)) => key);
  let updatedStudent =
    student |> Student.updateInfo(state.exited, state.excludedFromLeaderboard);
  Js.Dict.set(
    payload,
    "founder",
    Student.encode(state.name, state.teamName, updatedStudent),
  );
  Js.Dict.set(
    payload,
    "tags",
    state.tagsToApply |> Json.Encode.(list(string)),
  );
  Js.Dict.set(
    payload,
    "coach_ids",
    enrolledCoachIds |> Json.Encode.(list(int)),
  );
  Js.Dict.set(
    payload,
    "clear_coaches",
    List.length(enrolledCoachIds) < 1 |> Json.Encode.(bool),
  );
  let url = "/school/students/" ++ (student |> Student.id |> string_of_int);
  Api.update(url, payload, responseCB, handleErrorCB);
};

let boolBtnClasses = selected => {
  let classes = "w-1/2 toggle-button__button hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none";
  classes ++ (selected ? " bg-grey" : " bg-white");
};

let handleEligibleTeamCoachList =
    (schoolCoaches, courseCoachIds, teamCoachIds, userProfiles) => {
  let selectedTeamCoachIds = teamCoachIds |> Array.of_list;
  let allowedTeamCoaches =
    schoolCoaches
    |> List.filter(coach =>
         !(
           courseCoachIds
           |> List.exists(courseCoachId => courseCoachId == Coach.id(coach))
         )
       );
  allowedTeamCoaches
  |> List.map(coach => {
       let coachId = coach |> Coach.id;
       let selected =
         selectedTeamCoachIds
         |> Js.Array.findIndex(selectedCoachId => coachId == selectedCoachId)
         > (-1);
       let coachUserProfile =
         userProfiles
         |> List.find(profile =>
              UserProfile.userId(profile) === Coach.userId(coach)
            );
       (coach |> Coach.id, coachUserProfile |> UserProfile.name, selected);
     });
};

let coachUserProfile = (userProfiles, coach) =>
  userProfiles
  |> List.find(profile =>
       UserProfile.userId(profile) === Coach.userId(coach)
     );

let studentUserProfile = (userProfiles, student) =>
  userProfiles
  |> List.find(profile =>
       UserProfile.userId(profile) === Student.userId(student)
     );

let studentTeam = (teams, student) =>
  teams |> List.find(team => Team.id(team) === Student.teamId(student));

let make =
    (
      ~student,
      ~teams,
      ~studentTags,
      ~teamCoachIds,
      ~courseCoachIds,
      ~userProfiles,
      ~schoolCoaches,
      ~closeFormCB,
      ~submitFormCB,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {
    name: student |> studentUserProfile(userProfiles) |> UserProfile.name,
    teamName: student |> studentTeam(teams) |> Team.name,
    hasNameError: false,
    hasTeamNameError: false,
    tagsToApply: student |> Student.tags,
    exited: student |> Student.exited,
    teamCoaches:
      handleEligibleTeamCoachList(
        schoolCoaches,
        courseCoachIds,
        teamCoachIds,
        userProfiles,
      ),
    coachEnrollmentsChanged: false,
    excludedFromLeaderboard: student |> Student.excludedFromLeaderboard,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name) => ReasonReact.Update({...state, name})
    | UpdateTeamName(teamName) => ReasonReact.Update({...state, teamName})
    | UpdateErrors(hasNameError, hasTeamNameError) =>
      ReasonReact.Update({...state, hasNameError, hasTeamNameError})
    | AddTag(tag) =>
      ReasonReact.Update({
        ...state,
        tagsToApply: [tag, ...state.tagsToApply],
      })
    | RemoveTag(tag) =>
      ReasonReact.Update({
        ...state,
        tagsToApply: state.tagsToApply |> List.filter(t => t !== tag),
      })
    | UpdateExited(exited) => ReasonReact.Update({...state, exited})
    | UpdateCoachesList(key, value, selected) =>
      let oldCoach =
        state.teamCoaches |> List.filter(((item, _, _)) => item !== key);
      ReasonReact.Update({
        ...state,
        teamCoaches: [(key, value, selected), ...oldCoach],
        coachEnrollmentsChanged: true,
      });
    | UpdateExcludedFromLeaderboard(excludedFromLeaderboard) =>
      ReasonReact.Update({...state, excludedFromLeaderboard})
    },
  render: ({state, send}) => {
    let multiSelectCoachEnrollmentsCB = (key, value, selected) =>
      send(UpdateCoachesList(key, value, selected));
    let studentUserProfile =
      userProfiles
      |> List.find(profile =>
           UserProfile.userId(profile) === Student.userId(student)
         );
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            onClick={_e => closeFormCB()}
            className="flex items-center justify-center bg-grey-200 text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> str} </i>
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div
                className="flex items-centre py-6 pl-16 mb-4 bg-grey-200">
                <img
                  className="w-12 h-12 rounded-full mr-4"
                  src={studentUserProfile |> UserProfile.avatarUrl}
                />
                <div className="text-sm flex flex-col justify-center">
                  <div className="text-black font-bold inline-block">
                    {studentUserProfile |> UserProfile.name |> str}
                  </div>
                  <div className="text-grey-600 inline-block">
                    {student |> Student.email |> str}
                  </div>
                </div>
              </div>
              <div className="max-w-md p-6 mx-auto">
                <div>
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="name">
                    {"Name" |> str}
                  </label>
                  <span> {"*" |> str} </span>
                  <input
                    value={state.name}
                    onChange={
                      event =>
                        updateName(
                          send,
                          state,
                          ReactEvent.Form.target(event)##value,
                        )
                    }
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-400 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="name"
                    type_="text"
                    placeholder="Student name here"
                  />
                  <School__InputGroupError
                    message="is not a valid name"
                    active={state.hasNameError}
                  />
                </div>
                <div className="mt-6">
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="team_name">
                    {"Team Name" |> str}
                  </label>
                  <span> {"*" |> str} </span>
                  <input
                    value={state.teamName}
                    onChange={
                      event =>
                        updateTeamName(
                          send,
                          state,
                          ReactEvent.Form.target(event)##value,
                        )
                    }
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-400 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="team_name"
                    type_="text"
                    placeholder="Team name here"
                  />
                  <School__InputGroupError
                    message="is not a valid team name"
                    active={state.hasTeamNameError}
                  />
                </div>
                <div className="mt-6">
                  <div className="border-b border-grey-400 pb-2 mb-2 ">
                    <span
                      className="inline-block mr-1 text-grey-darker text-xs font-semibold">
                      {"Course Coaches:" |> str}
                    </span>
                    <div className="mt-2">
                      {
                        courseCoachIds |> List.length > 0 ?
                          courseCoachIds
                          |> List.map(coachId =>
                               <div
                                 key={coachId |> string_of_int}
                                 className="select-list__item-selected flex items-center justify-between bg-grey-100 text-xs text-grey-600 border rounded p-3 mb-2">
                                 {
                                   schoolCoaches
                                   |> List.find(coach =>
                                        Coach.id(coach) == coachId
                                      )
                                   |> coachUserProfile(userProfiles)
                                   |> UserProfile.name
                                   |> str
                                 }
                               </div>
                             )
                          |> Array.of_list
                          |> ReasonReact.array :
                          <div
                            className="select-list__item-selected flex items-center justify-between bg-grey-100 text-xs text-grey-600 border rounded p-3 mb-2">
                            {"None Assigned" |> str}
                          </div>
                      }
                    </div>
                  </div>
                  <div className="border-b border-grey-400 pb-2 mb-2 ">
                    <span
                      className="inline-block mr-1 text-grey-darker text-xs font-semibold">
                      {"Exclusive Team Coaches:" |> str}
                    </span>
                    <div className="mt-2">
                      <SA_StudentsPanel_SelectBox
                        items={state.teamCoaches}
                        multiSelectCB=multiSelectCoachEnrollmentsCB
                      />
                    </div>
                  </div>
                </div>
                <div className="mt-6">
                  <div className="mb-2"> {"Tags applied:" |> str} </div>
                  <SA_StudentsPanel_SearchableTagList
                    unselectedTags={
                      studentTags
                      |> List.filter(tag =>
                           !(state.tagsToApply |> List.mem(tag))
                         )
                    }
                    selectedTags={state.tagsToApply}
                    addTagCB={tag => send(AddTag(tag))}
                    removeTagCB={tag => send(RemoveTag(tag))}
                    allowNewTags=true
                  />
                </div>
                <div className="mt-6">
                  <div className="flex items-center flex-no-shrink">
                    <label
                      className="block tracking-wide text-grey-darker text-xs font-semibold mr-3">
                      {
                        "Should this student be excluded from leaderboards?"
                        |> str
                      }
                    </label>
                    <div
                      className="flex flex-no-shrink rounded-lg overflow-hidden border">
                      <button
                        title="Exclude this student from the leaderboard"
                        onClick={
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(UpdateExcludedFromLeaderboard(true));
                          }
                        }
                        className={
                          boolBtnClasses(state.excludedFromLeaderboard)
                        }>
                        {"Yes" |> str}
                      </button>
                      <button
                        title="Include this student in the leaderboard"
                        onClick={
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(UpdateExcludedFromLeaderboard(false));
                          }
                        }
                        className={
                          boolBtnClasses(!state.excludedFromLeaderboard)
                        }>
                        {"No" |> str}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
              <div className="p-6 bg-grey-200">
                <div className="max-w-md px-6 mx-auto">
                  <div
                    className="flex max-w-md w-full justify-between items-center mx-auto">
                    <div className="flex items-center flex-no-shrink">
                      <label
                        className="block tracking-wide text-grey-darker text-xs font-semibold mr-3">
                        {"Has this student dropped out?" |> str}
                      </label>
                      <div
                        className="flex flex-no-shrink rounded-lg overflow-hidden border">
                        <button
                          title="Prevent this student from accessing the course"
                          onClick={
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              send(UpdateExited(true));
                            }
                          }
                          className={boolBtnClasses(state.exited)}>
                          {"Yes" |> str}
                        </button>
                        <button
                          title="Allow this student to access the course"
                          onClick={
                            _event => {
                              ReactEvent.Mouse.preventDefault(_event);
                              send(UpdateExited(false));
                            }
                          }
                          className={boolBtnClasses(!state.exited)}>
                          {"No" |> str}
                        </button>
                      </div>
                    </div>
                    <div className="w-auto">
                      <button
                        disabled={formInvalid(state)}
                        onClick={
                          _e =>
                            updateStudent(
                              student,
                              state,
                              authenticityToken,
                              handleResponseCB(submitFormCB, state),
                            )
                        }
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
                        {"Update Student" |> str}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>;
  },
};