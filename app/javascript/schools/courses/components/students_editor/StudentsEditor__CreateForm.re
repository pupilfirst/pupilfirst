open StudentsEditor__Types;

type state = {
  teamsToAdd: array(TeamInfo.t),
  notifyStudents: bool,
  saving: bool,
};

type action =
  | AddStudentInfo(StudentInfo.t, option(string), array(string))
  | RemoveStudentInfo(StudentInfo.t)
  | ToggleNotifyStudents
  | SetSaving(bool);

let str = React.string;

let formInvalid = state => state.teamsToAdd |> ArrayUtils.isEmpty;
let handleErrorCB = (send, ()) => send(SetSaving(false));

/* Get the tags applied to a list of students. */
let appliedTags = teams =>
  teams
  |> Array.map(team => team |> TeamInfo.tags |> Array.to_list)
  |> Array.to_list
  |> List.flatten
  |> ListUtils.distinct
  |> Array.of_list;

/*
 * This is a union of tags reported by the parent component, and tags currently applied to students listed in the form. This allows the
 * form to suggest tags that haven't yet been persisted, but have been applied to at least one of the students in the list.
 */
let allKnownTags = (incomingTags, appliedTags) =>
  incomingTags |> Js.Array.concat(appliedTags) |> ArrayUtils.distinct;

let handleResponseCB = (submitCB, state, json) => {
  let (studentsAdded, studentsRequested) =
    json |> Json.Decode.(field("studentCount", pair(int, int)));

  let tags = state.teamsToAdd |> appliedTags;

  submitCB(tags);

  if (studentsAdded == studentsRequested) {
    Notification.success(
      "Success",
      "All students were created successfully.",
    );
  } else {
    let message =
      (studentsAdded |> string_of_int)
      ++ " of "
      ++ (studentsRequested |> string_of_int)
      ++ " students were added. Remaining students are already a part of the course.";
    Notification.notice("Partially successful", message);
  };
};

let saveStudents = (state, send, courseId, responseCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(SetSaving(true));
  let payload = Js.Dict.empty();

  Js.Dict.set(
    payload,
    "authenticity_token",
    AuthenticityToken.fromHead() |> Js.Json.string,
  );

  Js.Dict.set(
    payload,
    "notify",
    (state.notifyStudents ? "true" : "false") |> Js.Json.string,
  );

  Js.Dict.set(payload, "students", state.teamsToAdd |> TeamInfo.encodeArray);

  let url = "/school/courses/" ++ courseId ++ "/students";
  Api.create(url, payload, responseCB, handleErrorCB(send));
};

let teamHeader = (teamName, studentsCount) => {
  <div className="flex justify-between mb-1">
    <span className="text-tiny font-semibold">
      <span> {"TEAM: " ++ teamName |> str} </span>
    </span>
    {studentsCount < 2
       ? <span className="text-tiny">
           <i className="fas fa-exclamation-triangle text-orange-600 mr-1" />
           {"Add more team members!" |> str}
         </span>
       : React.null}
  </div>;
};

let renderTitleAndAffiliation = (title, affiliation) => {
  let text =
    switch (title == "", affiliation == "") {
    | (true, true) => None
    | (true, false) => Some(affiliation)
    | (false, true) => Some(title)
    | (false, false) => Some(title ++ ", " ++ affiliation)
    };

  switch (text) {
  | Some(text) =>
    <div className="flex items-center">
      <div className="mr-1 text-xs text-gray-600"> {text |> str} </div>
    </div>
  | None => React.null
  };
};

let initialState = () => {
  teamsToAdd: [||],
  notifyStudents: true,
  saving: false,
};

let reducer = (state, action) =>
  switch (action) {
  | AddStudentInfo(studentInfo, teamName, tags) => {
      ...state,
      teamsToAdd:
        state.teamsToAdd
        ->TeamInfo.addStudentToArray(studentInfo, teamName, tags),
    }
  | RemoveStudentInfo(studentInfo) => {
      ...state,
      teamsToAdd:
        state.teamsToAdd->TeamInfo.removeStudentFromArray(studentInfo),
    }
  | SetSaving(saving) => {...state, saving}
  | ToggleNotifyStudents => {...state, notifyStudents: !state.notifyStudents}
  };

let tagBoxes = tags => {
  <div className="flex flex-wrap">
    {tags
     |> Array.map(tag =>
          <div
            key=tag
            className="flex items-center bg-gray-200 border border-gray-500 rounded-lg px-2 py-px mt-1 mr-1 text-xs text-gray-900 overflow-hidden">
            {tag |> str}
          </div>
        )
     |> React.array}
  </div>;
};

let studentCard = (studentInfo, send, team, tags) => {
  let defaultClasses = "flex justify-between";

  let containerClasses =
    team
      ? defaultClasses ++ " border-t"
      : defaultClasses ++ " bg-white-100 border shadow rounded-lg mt-2 px-2";

  <div key={studentInfo |> StudentInfo.email} className=containerClasses>
    <div className="flex flex-col flex-1 flex-wrap p-3">
      <div className="flex items-center">
        <div className="mr-1 font-semibold">
          {studentInfo |> StudentInfo.name |> str}
        </div>
        <div className="text-xs text-gray-600">
          {" (" ++ (studentInfo |> StudentInfo.email) ++ ")" |> str}
        </div>
      </div>
      {renderTitleAndAffiliation(
         studentInfo |> StudentInfo.title,
         studentInfo |> StudentInfo.affiliation,
       )}
      {tagBoxes(tags)}
    </div>
    <button
      className="p-3 text-gray-700 hover:text-gray-900 hover:bg-gray-100"
      onClick={_event => send(RemoveStudentInfo(studentInfo))}>
      <i className="fas fa-trash-alt" />
    </button>
  </div>;
};

[@react.component]
let make = (~courseId, ~submitFormCB, ~teamTags) => {
  let (state, send) = React.useReducer(reducer, initialState());

  <div className="mx-auto bg-white">
    <div className="max-w-2xl p-6 mx-auto">
      <h5 className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
        {"Student Details" |> str}
      </h5>
      <StudentsEditor__StudentInfoForm
        addToListCB={(studentInfo, teamName, tags) =>
          send(AddStudentInfo(studentInfo, teamName, tags))
        }
        teamTags={allKnownTags(
          teamTags,
          TeamInfo.tagsFromArray(state.teamsToAdd),
        )}
        emailsToAdd={state.teamsToAdd |> TeamInfo.studentEmailsFromArray}
      />
      <div>
        <div className="mt-5">
          <div className="inline-block tracking-wide text-xs font-semibold">
            {"These new students will be added to the course:" |> str}
          </div>
          {switch (state.teamsToAdd) {
           | [||] =>
             <div
               className="flex items-center justify-between bg-gray-100 border rounded p-3 italic mt-2">
               {"This list is empty! Add some students using the form above."
                |> str}
             </div>
           | teams =>
             teams
             |> Js.Array.map(team =>
                  switch (TeamInfo.nature(team)) {
                  | TeamInfo.MultiMember(teamName, studentsInTeam) =>
                    <div className="mt-3" key=teamName>
                      {teamHeader(teamName, studentsInTeam |> Array.length)}
                      {TeamInfo.tags(team)->tagBoxes}
                      <div
                        className="bg-white-100 border shadow rounded-lg mt-2 px-2">
                        {studentsInTeam
                         |> Array.map(studentInfo =>
                              studentCard(studentInfo, send, true, [||])
                            )
                         |> React.array}
                      </div>
                    </div>
                  | SingleMember(studentInfo) =>
                    studentCard(
                      studentInfo,
                      send,
                      false,
                      TeamInfo.tags(team),
                    )
                  }
                )
             |> React.array
           }}
        </div>
      </div>
      <div className="mt-4">
        <input
          onChange={_event => send(ToggleNotifyStudents)}
          checked={state.notifyStudents}
          className="hidden checkbox-input"
          id="notify-new-students"
          type_="checkbox"
        />
        <label className="checkbox-label" htmlFor="notify-new-students">
          <span>
            <svg width="12px" height="10px" viewBox="0 0 12 10">
              <polyline points="1.5 6 4.5 9 10.5 1" />
            </svg>
          </span>
          <span className="text-sm">
            {str(
               "Notify students, and send them a link to sign into this school.",
             )}
          </span>
        </label>
      </div>
      <div className="flex mt-4">
        <button
          disabled={state.saving || state.teamsToAdd |> ArrayUtils.isEmpty}
          onClick={saveStudents(
            state,
            send,
            courseId,
            handleResponseCB(submitFormCB, state),
          )}
          className={
            "w-full btn btn-primary btn-large mt-3"
            ++ (formInvalid(state) ? " disabled" : "")
          }>
          {(state.saving ? "Saving..." : "Save List") |> str}
        </button>
      </div>
    </div>
  </div>;
};
