open StudentsPanel__Types;

type state = {
  studentsToAdd: list(StudentInfo.t),
  saving: bool,
};

type action =
  | AddStudentInfo(StudentInfo.t)
  | RemoveStudentInfo(StudentInfo.t)
  | SetSaving(bool);

let component = ReasonReact.reducerComponent("SA_StudentsPanel_CreateForm");

let str = ReasonReact.string;

let formInvalid = state => state.studentsToAdd |> ListUtils.isEmpty;
let handleErrorCB = (send, ()) => send(SetSaving(false));

/* Get the tags applied to a list of students. */
let appliedTags = students =>
  students
  |> List.map(student => student |> StudentInfo.tags)
  |> List.flatten
  |> ListUtils.distinct;

/*
 * This is a union of tags reported by the parent component, and tags currently applied to students listed in the form. This allows the
 * form to suggest tags that haven't yet been persisted, but have been applied to at least one of the students in the list.
 */
let allKnownTags = (incomingTags, appliedTags) =>
  incomingTags |> List.append(appliedTags) |> ListUtils.distinct;

let handleResponseCB = (submitCB, state, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  let students =
    json |> Json.Decode.(field("students", list(Student.decode)));

  let (studentsAdded, studentsRequested) =
    json |> Json.Decode.(field("studentCount", pair(int, int)));
  let tags = state.studentsToAdd |> appliedTags;

  submitCB(teams, students, tags);

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

let saveStudents =
    (state, send, courseId, authenticityToken, responseCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(SetSaving(true));
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "students",
    state.studentsToAdd |> Json.Encode.(list(StudentInfo.encode)),
  );

  let url = "/school/courses/" ++ courseId ++ "/students";
  Api.create(url, payload, responseCB, handleErrorCB(send));
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

let make =
    (
      ~courseId,
      ~closeFormCB,
      ~submitFormCB,
      ~studentTags,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {studentsToAdd: [], saving: false},
  reducer: (action, state) =>
    switch (action) {
    | AddStudentInfo(studentInfo) =>
      ReasonReact.Update({
        ...state,
        studentsToAdd: [studentInfo, ...state.studentsToAdd],
      })
    | RemoveStudentInfo(studentInfo) =>
      ReasonReact.Update({
        ...state,
        studentsToAdd:
          state.studentsToAdd
          |> List.filter(s =>
               StudentInfo.email(s) !== StudentInfo.email(studentInfo)
             ),
      })
    | SetSaving(saving) => ReasonReact.Update({...state, saving})
    },
  render: ({state, send}) =>
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            title="close"
            onClick={_e => closeFormCB()}
            className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
            <i className="fas fa-times text-xl" />
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-2xl p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                  {"Student Details" |> str}
                </h5>
                <SA_StudentsPanel_StudentInfoForm
                  addToListCB={studentInfo =>
                    send(AddStudentInfo(studentInfo))
                  }
                  studentTags={allKnownTags(
                    studentTags,
                    state.studentsToAdd |> appliedTags,
                  )}
                  emailsToAdd={
                    state.studentsToAdd
                    |> List.map(student => student |> StudentInfo.email)
                  }
                />
                <div>
                  <div className="mt-5">
                    <div
                      className="inline-block tracking-wide text-xs font-semibold">
                      {"These new students will be added to the course:" |> str}
                    </div>
                    {switch (state.studentsToAdd) {
                     | [] =>
                       <div
                         className="flex items-center justify-between bg-gray-100 border rounded p-3 italic mt-2">
                         {"This list is empty! Add some students using the form above."
                          |> str}
                       </div>
                     | studentInfos =>
                       studentInfos
                       |> List.map(studentInfo =>
                            <div
                              key={studentInfo |> StudentInfo.email}
                              className="flex justify-between bg-white-100 border shadow rounded-lg mt-2">
                              <div
                                className="flex flex-col flex-1 flex-wrap p-3">
                                <div className="flex items-center">
                                  <div className="mr-1 font-semibold">
                                    {studentInfo |> StudentInfo.name |> str}
                                  </div>
                                  <div className="text-xs text-gray-600">
                                    {" ("
                                     ++ (studentInfo |> StudentInfo.email)
                                     ++ ")"
                                     |> str}
                                  </div>
                                </div>
                                {renderTitleAndAffiliation(
                                   studentInfo |> StudentInfo.title,
                                   studentInfo |> StudentInfo.affiliation,
                                 )}
                                <div className="flex flex-wrap">
                                  {studentInfo
                                   |> StudentInfo.tags
                                   |> List.map(tag =>
                                        <div
                                          key=tag
                                          className="flex items-center bg-gray-200 border border-gray-500 rounded-lg px-2 py-px mt-1 mr-1 text-xs text-gray-900 overflow-hidden">
                                          {tag |> str}
                                        </div>
                                      )
                                   |> Array.of_list
                                   |> ReasonReact.array}
                                </div>
                              </div>
                              <button
                                className="p-3 text-gray-700 hover:text-gray-900 hover:bg-gray-100"
                                onClick={_event =>
                                  send(RemoveStudentInfo(studentInfo))
                                }>
                                <i className="fas fa-trash-alt" />
                              </button>
                            </div>
                          )
                       |> Array.of_list
                       |> ReasonReact.array
                     }}
                  </div>
                </div>
                <div className="flex mt-4">
                  <button
                    disabled={
                      state.saving || state.studentsToAdd |> ListUtils.isEmpty
                    }
                    onClick={saveStudents(
                      state,
                      send,
                      courseId,
                      authenticityToken,
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
            </div>
          </div>
        </div>
      </div>
    </div>,
};
