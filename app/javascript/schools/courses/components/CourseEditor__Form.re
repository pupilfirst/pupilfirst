open CourseEditor__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;

type state = {
  name: string,
  maxGrade: int,
  passGrade: int,
  gradesAndLabels: list(GradesAndLabels.t),
  endsAt: option(string),
  hasNameError: bool,
  hasDateError: bool,
  dirty: bool,
  saving: bool,
};

type action =
  | UpdateName(string, bool)
  | UpdateEndsAt(string, bool)
  | UpdateSaving;

let component = ReasonReact.reducerComponent("CourseEditor__Form");

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let updateEndsAt = (send, date) => {
  let regex = [%re
    {|/^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/|}
  ];

  let lengthOfInput = date |> String.length;
  let hasError = lengthOfInput == 0 ? false : !Js.Re.test(date, regex);
  send(UpdateEndsAt(date, hasError));
};

let saveDisabled = state =>
  state.hasDateError || state.hasNameError || !state.dirty || state.saving;

let setPayload = (authenticityToken, state) => {
  let payload = Js.Dict.empty();

  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(payload, "name", state.name |> Js.Json.string);

  switch (state.endsAt) {
  | Some(date) => Js.Dict.set(payload, "unlock_on", date |> Js.Json.string)
  | None => Js.Dict.set(payload, "unlock_on", "" |> Js.Json.string)
  };
  payload;
};
let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full";

let make =
    (
      ~course,
      ~authenticityToken,
      ~hideEditorActionCB,
      ~updateCoursesCB,
      _children,
    ) => {
  ...component,
  initialState: () =>
    switch (course) {
    | Some(course) => {
        name: course |> Course.name,
        endsAt: course |> Course.endsAt,
        maxGrade: course |> Course.maxGrade,
        passGrade: course |> Course.passGrade,
        gradesAndLabels: course |> Course.gradesAndLabels,
        hasNameError: false,
        hasDateError: false,
        dirty: false,
        saving: false,
      }
    | None => {
        name: "",
        endsAt: None,
        maxGrade: 2,
        passGrade: 1,
        gradesAndLabels: [
          GradesAndLabels.empty(1),
          GradesAndLabels.empty(2),
        ],
        hasNameError: false,
        hasDateError: false,
        dirty: false,
        saving: false,
      }
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name, hasNameError) =>
      ReasonReact.Update({...state, name, hasNameError, dirty: true})
    | UpdateEndsAt(date, hasDateError) =>
      ReasonReact.Update({
        ...state,
        endsAt: Some(date),
        hasDateError,
        dirty: true,
      })
    | UpdateSaving => ReasonReact.Update({...state, saving: !state.saving})
    },
  render: ({state, send}) => {
    let handleErrorCB = () => send(UpdateSaving);
    let handleResponseCB = json => {
      let id = json |> Json.Decode.(field("id", int));
      let number = json |> Json.Decode.(field("number", int));
      let newCourse = Course.create(id, state.name, state.endsAt);
      switch (course) {
      | Some(_) =>
        Notification.success("Success", "Course updated successfully")
      | None => Notification.success("Success", "Course created successfully")
      };
      updateCoursesCB(newCourse);
    };

    let endsAt =
      switch (state.endsAt) {
      | Some(date) => date
      | None => ""
      };
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            onClick={_ => hideEditorActionCB()}
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> str} </i>
          </button>
        </div>
        <div className={formClasses(state.saving)}>
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Course Details" |> str}
                </h5>
                <label
                  className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="name">
                  {"Course Name" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="name"
                  type_="text"
                  placeholder="Type course name here"
                  value={state.name}
                  onChange={
                    event =>
                      updateName(send, ReactEvent.Form.target(event)##value)
                  }
                />
                {
                  state.hasNameError ?
                    <div className="drawer-right-form__error-msg">
                      {"not a valid name" |> str}
                    </div> :
                    ReasonReact.null
                }
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="date">
                  {"Course ends on" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="date"
                  type_="text"
                  placeholder="DD/MM/YYYY"
                  value=endsAt
                  onChange={
                    event =>
                      updateEndsAt(
                        send,
                        ReactEvent.Form.target(event)##value,
                      )
                  }
                />
                {
                  state.hasDateError ?
                    <div className="drawer-right-form__error-msg">
                      {"not a valid date" |> str}
                    </div> :
                    ReasonReact.null
                }
                <label
                  className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="grades">
                  {"Grades" |> str}
                </label>
                {
                  state.gradesAndLabels
                  |> List.map(gradesAndLabel =>
                       <div>
                         <span>
                           {
                             gradesAndLabel
                             |> GradesAndLabels.grade
                             |> string_of_int
                             |> str
                           }
                         </span>
                         <input
                           className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                           id={
                             gradesAndLabel
                             |> GradesAndLabels.grade
                             |> string_of_int
                           }
                           type_="text"
                           placeholder="Type Grade label"
                           value={gradesAndLabel |> GradesAndLabels.label}
                         />
                       </div>
                     )
                  |> Array.of_list
                  |> ReasonReact.array
                }
                <div className="flex">
                  {
                    switch (course) {
                    | Some(course) =>
                      let id = course |> Course.id;
                      <button
                        disabled={saveDisabled(state)}
                        /* onClick=(
                             _event =>
                               updateCourse(
                                 authenticityToken,
                                 id |> string_of_int,
                                 state,
                               )
                           ) */
                        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Update Course" |> str}
                      </button>;

                    | None =>
                      <button
                        disabled={saveDisabled(state)}
                        /* onClick=(
                             _event =>
                               createCourse(authenticityToken, course, state)
                           ) */
                        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Create Course" |> str}
                      </button>
                    }
                  }
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>;
  },
};