open StudentsPanel__Types;
open SchoolAdmin__Utils;

type state = {
  studentsToAdd: list(StudentInfo.t),
  tagsToApply: list(string),
};

type action =
  | AddStudentInfo(StudentInfo.t)
  | RemoveStudentInfo(StudentInfo.t)
  | AddTag(string)
  | RemoveTag(string);

let component = ReasonReact.reducerComponent("SA_StudentsPanel_CreateForm");

let str = ReasonReact.string;

let formInvalid = state => state.studentsToAdd |> List.length < 1;
let handleErrorCB = () => ();
let handleResponseCB = (submitCB, state, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  submitCB(teams, state.tagsToApply);
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
  Js.Dict.set(
    payload,
    "tags",
    state.tagsToApply |> Json.Encode.(list(string)),
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
  initialState: () => {studentsToAdd: [], tagsToApply: []},
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
                />
                {
                  state.studentsToAdd |> List.length > 0 ?
                    <div>
                      <div className="mt-6">
                        <div className="border-b border-grey-light pb-2 mb-4">
                          {
                            "These new students will be added to the course:"
                            |> str
                          }
                        </div>
                        {
                          switch (state.studentsToAdd) {
                          | [] => ReasonReact.null
                          | studentInfos =>
                            studentInfos
                            |> List.map(studentInfo =>
                                 <div
                                   key={studentInfo |> StudentInfo.email}
                                   className="select-list__item-selected flex items-center justify-between bg-grey-lightest border rounded p-3 mb-2">
                                   <div className="flex items-center">
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
                                   </div>
                                   <button
                                     onClick=(
                                       _event =>
                                         send(RemoveStudentInfo(studentInfo))
                                     )>
                                     <Icon
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
                    </div> :
                    ReasonReact.null
                }
                <div className="mt-6">
                  <span>
                    {"Apply some tags to these new students:" |> str}
                  </span>
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
                <div className="flex mt-4">
                  <button
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