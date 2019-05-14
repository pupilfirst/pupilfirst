open StudentsPanel__Types;
open SchoolAdmin__Utils;

type state = {studentsToAdd: list(StudentInfo.t)};

type action =
  | AddStudentInfo(StudentInfo.t)
  | RemoveStudentInfo(StudentInfo.t);

let component = ReasonReact.reducerComponent("SA_StudentsPanel_CreateForm");

let str = ReasonReact.string;

let formInvalid = state => state.studentsToAdd |> ListUtils.isEmpty;
let handleErrorCB = () => ();

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
  let tags = state.studentsToAdd |> appliedTags;

  submitCB(teams, tags);
  Notification.success("Success", "Student(s) created successfully");
};

let saveStudents = (state, courseId, authenticityToken, responseCB) => {
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

  let url = "/school/courses/" ++ (courseId |> string_of_int) ++ "/students";
  Api.create(url, payload, responseCB, handleErrorCB);
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
  initialState: () => {studentsToAdd: []},
  reducer: (action, state) =>
    switch (action) {
    | AddStudentInfo(studentInfo) =>
      ReasonReact.Update({
        studentsToAdd: [studentInfo, ...state.studentsToAdd],
      })
    | RemoveStudentInfo(studentInfo) =>
      ReasonReact.Update({
        studentsToAdd:
          state.studentsToAdd
          |> List.filter(s =>
               StudentInfo.email(s) !== StudentInfo.email(studentInfo)
             ),
      })
    },
  render: ({state, send}) =>
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            onClick={_e => closeFormCB()}
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> str} </i>
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Student Details" |> str}
                </h5>
                <SA_StudentsPanel_StudentInfoForm
                  addToListCB={
                    studentInfo => send(AddStudentInfo(studentInfo))
                  }
                  studentTags={
                    allKnownTags(
                      studentTags,
                      state.studentsToAdd |> appliedTags,
                    )
                  }
                />
                <div>
                  <div className="mt-6">
                    <div
                      className="inline-block tracking-wide text-grey-darker text-xs font-semibold">
                      {
                        "These new students will be added to the course:" |> str
                      }
                    </div>
                    {
                      switch (state.studentsToAdd) {
                      | [] =>
                        <div
                          className="flex items-center justify-between bg-grey-lightest border rounded p-3 italic mt-2">
                          {
                            "This list is empty! Add some students using the form above."
                            |> str
                          }
                        </div>
                      | studentInfos =>
                        studentInfos
                        |> List.map(studentInfo =>
                             <div
                               key={studentInfo |> StudentInfo.email}
                               className="select-list__item-selected flex items-center justify-between bg-grey-lightest border rounded p-3 mt-2">
                               <div
                                 className="flex flex flex-wrap pr-3 items-center">
                                 <div className="mr-1">
                                   {studentInfo |> StudentInfo.name |> str}
                                 </div>
                                 <div className="text-xs text-grey-dark">
                                   {
                                     " ("
                                     ++ (studentInfo |> StudentInfo.email)
                                     ++ ")"
                                     |> str
                                   }
                                 </div>
                                 {
                                   studentInfo
                                   |> StudentInfo.tags
                                   |> List.map(tag =>
                                        <div
                                          key=tag
                                          className="flex items-center px-2 py-1 border rounded-lg ml-1 text-sm font-semibold focus:outline-none bg-grey-light">
                                          {tag |> str}
                                        </div>
                                      )
                                   |> Array.of_list
                                   |> ReasonReact.array
                                 }
                               </div>
                               <button
                                 onClick=(
                                   _event =>
                                     send(RemoveStudentInfo(studentInfo))
                                 )>
                                 <Icon.Jsx2
                                   kind=Icon.Delete
                                   size="4"
                                   opacity=75
                                 />
                               </button>
                             </div>
                           )
                        |> Array.of_list
                        |> ReasonReact.array
                      }
                    }
                  </div>
                </div>
                <div className="flex mt-4">
                  <button
                    disabled={state.studentsToAdd |> ListUtils.isEmpty}
                    onClick={
                      _e =>
                        saveStudents(
                          state,
                          courseId,
                          authenticityToken,
                          handleResponseCB(submitFormCB, state),
                        )
                    }
                    className={
                      "w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3"
                      ++ (
                        formInvalid(state) ?
                          " opacity-50 cursor-not-allowed" : ""
                      )
                    }>
                    {"Save List" |> str}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};