[@bs.config {jsx: 3}];

open StudentsPanel__Types;

type teamCoachlist = (string, string, bool);

type state = {
  name: string,
  teamName: string,
  tagsToApply: list(string),
  teamCoaches: list(teamCoachlist),
  excludedFromLeaderboard: bool,
  title: string,
  affiliation: string,
  saving: bool,
  accessEndsAt: option(Js.Date.t),
};

type action =
  | UpdateName(string)
  | UpdateTeamName(string)
  | AddTag(string)
  | RemoveTag(string)
  | UpdateCoachesList(string, string, bool)
  | UpdateExcludedFromLeaderboard(bool)
  | UpdateTitle(string)
  | UpdateAffiliation(string)
  | UpdateSaving(bool)
  | UpdateAccessEndsAt(option(Js.Date.t));

let str = ReasonReact.string;

let stringInputInvalid = s => s |> String.length < 2;

let updateName = (send, name) => {
  send(UpdateName(name));
};

let updateTeamName = (send, teamName) => {
  send(UpdateTeamName(teamName));
};

let updateTitle = (send, title) => {
  send(UpdateTitle(title));
};

let formInvalid = state =>
  state.name
  |> stringInputInvalid
  || state.teamName
  |> stringInputInvalid
  || state.title
  |> stringInputInvalid;

let handleErrorCB = (send, ()) => send(UpdateSaving(false));

let successMessage = (accessEndsAt, isSingleFounder) => {
  switch (accessEndsAt) {
  | Some(date) =>
    switch (date |> DateFns.isBefore(Js.Date.make()), isSingleFounder) {
    | (true, true) => "Student has been updated, and moved to list of inactive students"
    | (true, false) => "Team has been updated, and moved to list of inactive students"
    | (false, true)
    | (false, false) => "Student updated successfully"
    }
  | None => "Student updated successfully"
  };
};

let handleResponseCB = (submitCB, state, isSingleFounder, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  let students =
    json |> Json.Decode.(field("students", list(Student.decode)));

  submitCB(teams, students, state.tagsToApply);
  Notification.success(
    "Success",
    successMessage(state.accessEndsAt, isSingleFounder),
  );
};

let updateStudent = (student, state, send, authenticityToken, responseCB) => {
  send(UpdateSaving(true));
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
    Student.updateInfo(
      ~excludedFromLeaderboard=state.excludedFromLeaderboard,
      ~title=state.title,
      ~affiliation=Some(state.affiliation),
      ~student,
    );
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
    enrolledCoachIds |> Json.Encode.(list(string)),
  );

  Js.Dict.set(
    payload,
    "access_ends_at",
    state.accessEndsAt
    |> OptionUtils.map(Js.Date.toString)
    |> OptionUtils.default("")
    |> Json.Encode.(string),
  );

  let url = "/school/students/" ++ (student |> Student.id);
  Api.update(url, payload, responseCB, handleErrorCB(send));
};

let boolBtnClasses = selected => {
  let classes = "toggle-button__button";
  classes ++ (selected ? " toggle-button__button--active" : "");
};

let handleEligibleTeamCoachList =
    (schoolCoaches, courseCoachIds, teamCoachIds) => {
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

       (coach |> Coach.id, coach |> Coach.name, selected);
     });
};

let studentTeam = (teams, student) =>
  teams
  |> ListUtils.unsafeFind(
       team => Team.id(team) === Student.teamId(student),
       "Could not find team for student (#"
       ++ (student |> Student.id)
       ++ ") editor",
     );

let initialState =
    (student, teams, schoolCoaches, courseCoachIds, teamCoachIds) => {
  let team = student |> studentTeam(teams);
  {
    name: student |> Student.name,
    teamName: team |> Team.name,
    tagsToApply: student |> Student.tags,
    teamCoaches:
      handleEligibleTeamCoachList(
        schoolCoaches,
        courseCoachIds,
        teamCoachIds,
      ),
    excludedFromLeaderboard: student |> Student.excludedFromLeaderboard,
    title: student |> Student.title,
    affiliation: student |> Student.affiliation |> OptionUtils.toString,
    saving: false,
    accessEndsAt: team |> Team.accessEndsAt,
  };
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateName(name) => {...state, name}
  | UpdateTeamName(teamName) => {...state, teamName}
  | AddTag(tag) => {...state, tagsToApply: [tag, ...state.tagsToApply]}
  | RemoveTag(tag) => {
      ...state,
      tagsToApply: state.tagsToApply |> List.filter(t => t !== tag),
    }
  | UpdateCoachesList(key, value, selected) =>
    let oldCoach =
      state.teamCoaches |> List.filter(((item, _, _)) => item != key);
    {...state, teamCoaches: [(key, value, selected), ...oldCoach]};
  | UpdateExcludedFromLeaderboard(excludedFromLeaderboard) => {
      ...state,
      excludedFromLeaderboard,
    }
  | UpdateTitle(title) => {...state, title}
  | UpdateAffiliation(affiliation) => {...state, affiliation}
  | UpdateSaving(bool) => {...state, saving: bool}
  | UpdateAccessEndsAt(accessEndsAt) => {...state, accessEndsAt}
  };

[@react.component]
let make =
    (
      ~student,
      ~isSingleFounder,
      ~teams,
      ~studentTags,
      ~teamCoachIds,
      ~courseCoachIds,
      ~schoolCoaches,
      ~submitFormCB,
      ~authenticityToken,
    ) => {
  let (state, send) =
    React.useReducer(
      reducer,
      initialState(
        student,
        teams,
        schoolCoaches,
        courseCoachIds,
        teamCoachIds,
      ),
    );

  let multiSelectCoachEnrollmentsCB = (key, value, selected) =>
    send(UpdateCoachesList(key, value, selected));
  <DisablingCover disabled={state.saving}>
    <div>
      <div className="pt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
          htmlFor="name">
          {"Name" |> str}
        </label>
        <input
          value={state.name}
          onChange={event =>
            updateName(send, ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
          id="name"
          type_="text"
          placeholder="Student name here"
        />
        <School__InputGroupError
          message="Name must have at least two characters"
          active={state.name |> stringInputInvalid}
        />
      </div>
      {isSingleFounder
         ? ReasonReact.null
         : <div className="mt-5">
             <label
               className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
               htmlFor="team_name">
               {"Team Name" |> str}
             </label>
             <input
               value={state.teamName}
               onChange={event =>
                 updateTeamName(send, ReactEvent.Form.target(event)##value)
               }
               className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
               id="team_name"
               type_="text"
               placeholder="Team name here"
             />
             <School__InputGroupError
               message="Team Name must have at least two characters"
               active={state.teamName |> stringInputInvalid}
             />
           </div>}
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
          htmlFor="title">
          {"Title" |> str}
        </label>
        <input
          value={state.title}
          onChange={event =>
            updateTitle(send, ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
          id="title"
          type_="text"
          placeholder="Student, Coach, CEO, etc."
        />
        <School__InputGroupError
          message="Title must have at least two characters"
          active={state.title |> stringInputInvalid}
        />
      </div>
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
          htmlFor="affiliation">
          {"Affiliation" |> str}
        </label>
        <span className="text-xs ml-1"> {"(optional)" |> str} </span>
        <input
          value={state.affiliation}
          onChange={event =>
            send(UpdateAffiliation(ReactEvent.Form.target(event)##value))
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
          id="affiliation"
          type_="text"
          placeholder="Acme Inc., Acme University, etc."
        />
      </div>
      <div className="mt-5">
        <div className="border-b pb-4 mb-2 mt-5 ">
          <span className="inline-block mr-1 text-xs font-semibold">
            {(isSingleFounder ? "Personal Coaches" : "Team Coaches") |> str}
          </span>
          <div className="mt-2">
            <School__SelectBox
              items={state.teamCoaches}
              selectCB=multiSelectCoachEnrollmentsCB
            />
          </div>
        </div>
      </div>
      <div className="mt-5">
        <div className="mb-2 text-xs font-semibold">
          {"Tags applied:" |> str}
        </div>
        <SA_StudentsPanel_SearchableTagList
          unselectedTags={
            studentTags
            |> List.filter(tag => !(state.tagsToApply |> List.mem(tag)))
          }
          selectedTags={state.tagsToApply}
          addTagCB={tag => send(AddTag(tag))}
          removeTagCB={tag => send(RemoveTag(tag))}
          allowNewTags=true
        />
      </div>
      <div className="mt-5">
        <div className="flex items-center flex-shrink-0">
          <label className="block tracking-wide text-xs font-semibold mr-3">
            {"Should this student be excluded from leaderboards?" |> str}
          </label>
          <div
            className="flex flex-shrink-0 rounded-lg overflow-hidden border border-gray-400">
            <button
              title="Exclude this student from the leaderboard"
              onClick={event => {
                ReactEvent.Mouse.preventDefault(event);
                send(UpdateExcludedFromLeaderboard(true));
              }}
              className={boolBtnClasses(state.excludedFromLeaderboard)}>
              {"Yes" |> str}
            </button>
            <button
              title="Include this student in the leaderboard"
              onClick={_event => {
                ReactEvent.Mouse.preventDefault(_event);
                send(UpdateExcludedFromLeaderboard(false));
              }}
              className={boolBtnClasses(!state.excludedFromLeaderboard)}>
              {"No" |> str}
            </button>
          </div>
        </div>
      </div>
      <div className="mt-5">
        <label
          className="tracking-wide text-xs font-semibold"
          htmlFor="access-ends-at-input">
          {(isSingleFounder ? "Student's" : "Team's")
           ++ " Access Ends On"
           |> str}
        </label>
        <span className="ml-1 text-xs"> {"(optional)" |> str} </span>
        <HelpIcon
          className="ml-2"
          link="https://docs.pupilfirst.com/#/students?id=editing-student-details">
          {"If set, students will not be able to complete targets after this date."
           |> str}
        </HelpIcon>
        <DatePicker
          onChange={date => send(UpdateAccessEndsAt(date))}
          selected=?{state.accessEndsAt}
          id="access-ends-at-input"
        />
      </div>
    </div>
    <div className="my-5 w-auto">
      <button
        disabled={formInvalid(state)}
        onClick={_e =>
          updateStudent(
            student,
            state,
            send,
            authenticityToken,
            handleResponseCB(submitFormCB, state, isSingleFounder),
          )
        }
        className="w-full btn btn-large btn-primary">
        {"Update Student" |> str}
      </button>
    </div>
  </DisablingCover>;
};
