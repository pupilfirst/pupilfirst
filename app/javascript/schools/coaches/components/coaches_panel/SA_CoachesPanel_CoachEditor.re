open CoachesPanel__Types;

open SchoolAdmin__Utils;

type state = {coachesToAdd: list(CoachInfo.t)};

type action =
  | AddCoachInfo(CoachInfo.t)
  | RemoveCoachInfo(CoachInfo.t);

let component = ReasonReact.reducerComponent("SA_CoachesPanel_CreateForm");

let str = ReasonReact.string;

let formInvalid = state => state.coachesToAdd |> List.length < 1;

let handleResponseCB = (submitCB, json) => {
  let coaches = json |> Json.Decode.(field("coaches", list(Coach.decode)));
  submitCB(coaches);
  Notification.success("Success", "Coach(s) created succesffully");
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
    state.coachesToAdd |> Json.Encode.(list(CoachInfo.encode)),
  );
  let url = "/school/courses/" ++ (courseId |> string_of_int) ++ "/students";
  Api.create(url, payload, responseCB);
};

let make =
    (~schoolId, ~closeFormCB, ~submitFormCB, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {coachesToAdd: []},
  reducer: (action, state) =>
    switch (action) {
    | AddCoachInfo(coachInfo) =>
      ReasonReact.Update({
        ...state,
        coachesToAdd: [coachInfo, ...state.coachesToAdd],
      })
    | RemoveCoachInfo(coachInfo) =>
      ReasonReact.Update({
        ...state,
        coachesToAdd:
          state.coachesToAdd
          |> List.filter(s =>
               CoachInfo.email(s) !== CoachInfo.email(coachInfo)
             ),
      })
    },
  render: ({state, send}) =>
    <div className="blanket">
      <div className="drawer-right relative">
        <div className="drawer-right__close absolute">
          <button
            onClick=(_e => closeFormCB())
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> ("close" |> str) </i>
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  ("Student Details" |> str)
                </h5>
                <SA_CoachesPanel_CoachInfoForm
                  addToListCB=(coachInfo => send(AddCoachInfo(coachInfo)))
                />
                (
                  state.coachesToAdd |> List.length > 0 ?
                    <div>
                      <div className="mt-6">
                        <div className="border-b border-grey-light pb-2 mb-4">
                          ("Students List:" |> str)
                        </div>
                        (
                          switch (state.coachesToAdd) {
                          | [] => ReasonReact.null
                          | studentInfos =>
                            studentInfos
                            |> List.map(studentInfo =>
                                 <div
                                   key=(studentInfo |> CoachInfo.email)
                                   className="select-list__item-selected flex items-center justify-between bg-grey-lightest border rounded p-3 mb-2">
                                   <div className="flex items-center">
                                     <div className="mr-1">
                                       (studentInfo |> CoachInfo.name |> str)
                                     </div>
                                     <div className="text-xs text-grey-dark">
                                       (
                                         " ("
                                         ++ (studentInfo |> CoachInfo.email)
                                         ++ ")"
                                         |> str
                                       )
                                     </div>
                                   </div>
                                   <button
                                     onClick=(
                                       _event =>
                                         send(RemoveCoachInfo(studentInfo))
                                     )>
                                     <svg
                                       className="w-3"
                                       id="fa3b28d3-128c-4841-a4e9-49257a824d7b"
                                       xmlns="http://www.w3.org/2000/svg"
                                       viewBox="0 0 14 15.99">
                                       <path
                                         d="M13,1H9A1,1,0,0,0,8,0H6A1,1,0,0,0,5,1H1A1,1,0,0,0,0,2V3H14V2A1,1,0,0,0,13,1ZM11,13a1,1,0,1,1-2,0V7a1,1,0,0,1,2,0ZM8,13a1,1,0,1,1-2,0V7A1,1,0,0,1,8,7ZM5,13a1,1,0,1,1-2,0V7A1,1,0,0,1,5,7Zm8.5-9H.5a.5.5,0,0,0,0,1H1V15a1,1,0,0,0,1,1H12a1,1,0,0,0,1-1V5h.5a.5.5,0,0,0,0-1Z"
                                         fill="#525252"
                                       />
                                     </svg>
                                   </button>
                                 </div>
                               )
                            |> Array.of_list
                            |> ReasonReact.array
                          }
                        )
                      </div>
                      <div className="mt-6">
                        <div className="border-b border-grey-light pb-2 mb-2">
                          <span className="mr-1">
                            ("Tags applied:" |> str)
                          </span>
                        </div>
                      </div>
                      <div className="flex mt-4">
                        <button
                          onClick=(
                            _e =>
                              saveStudents(
                                state,
                                schoolId,
                                authenticityToken,
                                handleResponseCB(submitFormCB),
                              )
                          )
                          className=(
                            "w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3"
                            ++ (
                              formInvalid(state) ?
                                " opacity-50 cursor-not-allowed" : ""
                            )
                          )>
                          ("Save List" |> str)
                        </button>
                      </div>
                    </div> :
                    ReasonReact.null
                )
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};