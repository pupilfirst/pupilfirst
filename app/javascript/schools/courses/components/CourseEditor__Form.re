[%bs.raw {|require("./CourseEditor__Form.css")|}];

open CourseEditor__Types;

let str = ReasonReact.string;

type state = {
  name: string,
  description: string,
  maxGrade: int,
  passGrade: int,
  selectedGrade: int,
  gradesAndLabels: list(GradesAndLabels.t),
  endsAt: option(string),
  hasNameError: bool,
  hasDescriptionError: bool,
  hasDateError: bool,
  enableLeaderboard: bool,
  about: string,
  enablePublicSignup: bool,
  dirty: bool,
  saving: bool,
};

type action =
  | UpdateName(string, bool)
  | UpdateDescription(string, bool)
  | UpdateMaxGrade(int)
  | UpdatePassGrade(int)
  | UpdateGradesAndLabels(GradesAndLabels.t)
  | UpdateEndsAt(string, bool)
  | UpdateSaving
  | UpdateSelectedGrade(int)
  | UpdateEnableLeaderboard(bool)
  | UpdateAbout(string)
  | UpdateEnablePublicSignup(bool);

module CreateCourseQuery = [%graphql
  {|
   mutation($name: String!, $description: String!, $maxGrade: Int!, $passGrade: Int!, $endsAt: String!, $enableLeaderboard: Boolean!, $about: String!,$enablePublicSignup: Boolean!, $gradesAndLabels: [GradeAndLabelInput!]!) {
     createCourse(name: $name, description: $description, maxGrade: $maxGrade, passGrade: $passGrade, endsAt: $endsAt, enableLeaderboard: $enableLeaderboard,about: $about,enablePublicSignup: $enablePublicSignup, gradesAndLabels: $gradesAndLabels ) {
       course {
         id
       }
     }
   }
   |}
];

module UpdateCourseQuery = [%graphql
  {|
   mutation($id: ID!, $description: String!, $name: String!, $endsAt: String!, $enableLeaderboard: Boolean!,$about: String!,$enablePublicSignup: Boolean!, $gradesAndLabels: [GradeAndLabelInput!]!) {
    updateCourse(id: $id, name: $name, description: $description, endsAt: $endsAt, enableLeaderboard: $enableLeaderboard,about: $about,enablePublicSignup: $enablePublicSignup, gradesAndLabels: $gradesAndLabels){
       course {
         id
       }
      }
   }
   |}
];

let component = ReasonReact.reducerComponent("CourseEditor__Form");

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let updateDescription = (send, description) => {
  let lengthOfDescription = description |> String.length;
  let hasError = lengthOfDescription < 2 || lengthOfDescription >= 151;
  send(UpdateDescription(description, hasError));
};

let updateEndsAt = (send, date) => {
  let regex = [%re
    {|/^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/|}
  ];
  let lengthOfInput = date |> String.length;
  let hasError = lengthOfInput == 0 ? false : !Js.Re.test_(regex, date);
  send(UpdateEndsAt(date, hasError));
};

let saveDisabled = state => {
  let hasInvalidGrades =
    state.gradesAndLabels
    |> List.filter(gl => gl |> GradesAndLabels.grade <= state.maxGrade)
    |> List.map(gl => gl |> GradesAndLabels.valid)
    |> List.filter(value => !value)
    |> ListUtils.isNotEmpty;

  state.hasDateError
  || state.hasDescriptionError
  || state.description == ""
  || state.hasNameError
  || state.name == ""
  || !state.dirty
  || state.saving
  || hasInvalidGrades;
};

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

let possibleGradeValues: list(int) = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

let gradeBarBulletClasses = (selected, passed, empty) => {
  let classes = selected ? " grade-bar__pointer--selected" : " ";
  if (empty) {
    classes ++ " grade-bar__pointer--pulse";
  } else {
    passed ?
      classes ++ " grade-bar__pointer--passed" :
      classes ++ " grade-bar__pointer--failed";
  };
};

let updateMaxGrade = (value, state, send) =>
  if (value <= state.passGrade) {
    send(UpdatePassGrade(1));
    send(UpdateSelectedGrade(value));
    send(UpdateMaxGrade(value));
  } else {
    send(UpdateSelectedGrade(value));
    send(UpdateMaxGrade(value));
  };

let handleResponseCB = (id, state, updateCoursesCB, newCourse) => {
  let course =
    Course.create(
      id |> int_of_string,
      state.name,
      state.description,
      state.endsAt,
      state.maxGrade,
      state.passGrade,
      state.gradesAndLabels,
      state.enableLeaderboard,
      Some(state.about),
      state.enablePublicSignup,
    );
  newCourse ?
    Notification.success("Success", "Course created successfully") :
    Notification.success("Success", "Course updated successfully");

  updateCoursesCB(course);
};

let endsAt = state =>
  switch (state.endsAt) {
  | Some(date) => date
  | None => ""
  };

let createCourse = (authenticityToken, state, send, updateCoursesCB) => {
  send(UpdateSaving);
  let jsGradeAndLabelArray =
    state.gradesAndLabels
    |> List.filter(gradesAndLabel =>
         gradesAndLabel |> GradesAndLabels.grade <= state.maxGrade
       )
    |> List.map(gl => gl |> GradesAndLabels.asJsType)
    |> Array.of_list;

  let createCourseQuery =
    CreateCourseQuery.make(
      ~name=state.name,
      ~description=state.description,
      ~maxGrade=state.maxGrade,
      ~passGrade=state.passGrade,
      ~endsAt=endsAt(state),
      ~enableLeaderboard=state.enableLeaderboard,
      ~about=state.about,
      ~enablePublicSignup=state.enablePublicSignup,
      ~gradesAndLabels=jsGradeAndLabelArray,
      (),
    );
  let response =
    createCourseQuery |> GraphqlQuery.sendQuery(authenticityToken);

  response
  |> Js.Promise.then_(result => {
       handleResponseCB(
         result##createCourse##course##id,
         state,
         updateCoursesCB,
         true,
       );
       Js.Promise.resolve();
     })
  |> ignore;
};

let updateCourse = (authenticityToken, state, send, updateCoursesCB, course) => {
  send(UpdateSaving);
  let jsGradeAndLabelArray =
    state.gradesAndLabels
    |> List.filter(gradesAndLabel =>
         gradesAndLabel |> GradesAndLabels.grade <= state.maxGrade
       )
    |> List.map(gl => gl |> GradesAndLabels.asJsType)
    |> Array.of_list;

  let updateCourseQuery =
    UpdateCourseQuery.make(
      ~id=course |> Course.id |> string_of_int,
      ~name=state.name,
      ~description=state.description,
      ~endsAt=endsAt(state),
      ~enableLeaderboard=state.enableLeaderboard,
      ~about=state.about,
      ~enablePublicSignup=state.enablePublicSignup,
      ~gradesAndLabels=jsGradeAndLabelArray,
      (),
    );
  let response =
    updateCourseQuery |> GraphqlQuery.sendQuery(authenticityToken);

  response
  |> Js.Promise.then_(result => {
       handleResponseCB(
         result##updateCourse##course##id,
         state,
         updateCoursesCB,
         false,
       );
       Js.Promise.resolve();
     })
  |> ignore;
};

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button";
  classes ++ (bool ? " toggle-button__button--active" : "");
};

let enablePublicSignupButton = (enablePublicSignup, send) =>
  <div className="flex items-center mb-6">
    <label
      className="block tracking-wide text-gray-800 text-xs font-semibold mr-6"
      htmlFor="public-signup">
      {"Enable public signup for this course?" |> str}
    </label>
    <div
      id="public-signup"
      className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden">
      <button
        className={booleanButtonClasses(enablePublicSignup)}
        onClick={_ => send(UpdateEnablePublicSignup(true))}>
        {"Yes" |> str}
      </button>
      <button
        className={booleanButtonClasses(!enablePublicSignup)}
        onClick={_ => send(UpdateEnablePublicSignup(false))}>
        {"No" |> str}
      </button>
    </div>
  </div>;

let enableLeaderboardButton = (enableLeaderboard, send) =>
  <div className="flex items-center mb-6">
    <label
      className="block tracking-wide text-gray-800 text-xs font-semibold mr-6"
      htmlFor="leaderboard">
      {"Enable Leaderboard for this course?" |> str}
    </label>
    <div
      id="leaderboard"
      className="flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden">
      <button
        className={booleanButtonClasses(enableLeaderboard)}
        onClick={_ => send(UpdateEnableLeaderboard(true))}>
        {"Yes" |> str}
      </button>
      <button
        className={booleanButtonClasses(!enableLeaderboard)}
        onClick={_ => send(UpdateEnableLeaderboard(false))}>
        {"No" |> str}
      </button>
    </div>
  </div>;

let about = course =>
  switch (course |> Course.about) {
  | Some(about) => about
  | None => ""
  };

let updateAboutCB = (send, about) => send(UpdateAbout(about));

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
        description: course |> Course.description,
        endsAt: course |> Course.endsAt,
        maxGrade: course |> Course.maxGrade,
        passGrade: course |> Course.passGrade,
        gradesAndLabels: course |> Course.gradesAndLabels,
        hasNameError: false,
        hasDateError: false,
        hasDescriptionError: false,
        dirty: false,
        saving: false,
        selectedGrade: course |> Course.maxGrade,
        enableLeaderboard: course |> Course.enableLeaderboard,
        about: about(course),
        enablePublicSignup: course |> Course.enablePublicSignup,
      }
    | None => {
        name: "",
        description: "",
        endsAt: None,
        maxGrade: 5,
        passGrade: 2,
        gradesAndLabels:
          possibleGradeValues |> List.map(i => GradesAndLabels.empty(i)),
        hasNameError: false,
        hasDateError: false,
        hasDescriptionError: false,
        dirty: false,
        saving: false,
        selectedGrade: 1,
        enableLeaderboard: false,
        about: "",
        enablePublicSignup: false,
      }
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateSaving => ReasonReact.Update({...state, saving: !state.saving})
    | UpdateName(name, hasNameError) =>
      ReasonReact.Update({...state, name, hasNameError, dirty: true})
    | UpdateDescription(description, hasDescriptionError) =>
      ReasonReact.Update({
        ...state,
        description,
        hasDescriptionError,
        dirty: true,
      })
    | UpdateEndsAt(date, hasDateError) =>
      ReasonReact.Update({
        ...state,
        endsAt: Some(date),
        hasDateError,
        dirty: true,
      })
    | UpdateMaxGrade(maxGrade) =>
      ReasonReact.Update({...state, maxGrade, dirty: true})
    | UpdatePassGrade(passGrade) =>
      ReasonReact.Update({...state, passGrade, dirty: true})
    | UpdateEnableLeaderboard(enableLeaderboard) =>
      ReasonReact.Update({...state, enableLeaderboard, dirty: true})
    | UpdateEnablePublicSignup(enablePublicSignup) =>
      ReasonReact.Update({...state, enablePublicSignup, dirty: true})
    | UpdateAbout(about) =>
      ReasonReact.Update({...state, about, dirty: true})
    | UpdateGradesAndLabels(gradesAndLabel) =>
      let gradesAndLabels =
        state.gradesAndLabels
        |> List.map(gl =>
             gl
             |> GradesAndLabels.grade
             == (gradesAndLabel |> GradesAndLabels.grade) ?
               gradesAndLabel : gl
           );
      ReasonReact.Update({...state, gradesAndLabels, dirty: true});
    | UpdateSelectedGrade(selectedGrade) =>
      ReasonReact.Update({...state, selectedGrade, dirty: true})
    },
  render: ({state, send}) => {
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
            title="close"
            onClick={_ => hideEditorActionCB()}
            className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
            <i className="fal fa-times text-xl" />
          </button>
        </div>
        <div className={formClasses(state.saving)}>
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-2xl p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                  {"Course Details" |> str}
                </h5>
                <label
                  className="inline-block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                  htmlFor="name">
                  {"Course Name" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
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
                  className="inline-block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                  htmlFor="description">
                  {"Course Description" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  id="description"
                  type_="text"
                  placeholder="Type course description here"
                  value={state.description}
                  onChange={
                    event =>
                      updateDescription(
                        send,
                        ReactEvent.Form.target(event)##value,
                      )
                  }
                />
                {
                  state.hasDescriptionError ?
                    <div className="drawer-right-form__error-msg">
                      {
                        "Supplied description must be between 1 and 150 characters in length"
                        |> str
                      }
                    </div> :
                    ReasonReact.null
                }
                <label
                  className="block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                  htmlFor="date">
                  {"Course ends at" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
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
                <div id="About" className="mb-4">
                  <MarkdownEditor.Jsx2
                    updateDescriptionCB={updateAboutCB(send)}
                    value={state.about}
                    placeholder="Add more details about the course."
                    label="About"
                    profile=Markdown.Permissive
                    maxLength=10000
                    defaultView=MarkdownEditor.Edit
                  />
                </div>
                {enableLeaderboardButton(state.enableLeaderboard, send)}
                {enablePublicSignupButton(state.enablePublicSignup, send)}
              </div>
            </div>
            <div className="mx-auto">
              <div className="max-w-2xl p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                  {"Grades" |> str}
                </h5>
                <div className="mb-4">
                  <span
                    className="inline-block tracking-wide text-gray-800 text-sm font-semibold mr-2"
                    htmlFor="max_grades">
                    {"Maximum grade is" |> str}
                  </span>
                  {
                    switch (course) {
                    | Some(_) =>
                      <span
                        className="cursor-not-allowed inline-block bg-white border-b-2 text-2xl font-semibold text-center border-blue px-3 py-2 leading-tight rounded-none focus:outline-none">
                        {state.maxGrade |> string_of_int |> str}
                      </span>
                    | None =>
                      <select
                        onChange=(
                          event =>
                            updateMaxGrade(
                              ReactEvent.Form.target(event)##value
                              |> int_of_string,
                              state,
                              send,
                            )
                        )
                        value={state.maxGrade |> string_of_int}
                        className="cursor-pointer inline-block appearance-none bg-white border-b-2 text-2xl font-semibold text-center border-blue hover:border-gray-500 px-3 py-2 leading-tight rounded-none focus:outline-none">
                        {
                          possibleGradeValues
                          |> List.filter(g => g != 1)
                          |> List.map(possibleGradeValue =>
                               <option
                                 key={possibleGradeValue |> string_of_int}
                                 value={possibleGradeValue |> string_of_int}>
                                 {possibleGradeValue |> string_of_int |> str}
                               </option>
                             )
                          |> Array.of_list
                          |> ReasonReact.array
                        }
                      </select>
                    }
                  }
                  <span
                    className="inline-block tracking-wide text-gray-800 text-sm font-semibold mx-2"
                    htmlFor="pass_grades">
                    {"and the passing grade is" |> str}
                  </span>
                  {
                    switch (course) {
                    | Some(_) =>
                      <span
                        className="cursor-not-allowed inline-block appearance-none bg-white border-b-2 text-2xl font-semibold text-center border-blue px-3 py-2 leading-tight rounded-none">
                        {state.passGrade |> string_of_int |> str}
                      </span>
                    | None =>
                      <select
                        onChange=(
                          event =>
                            send(
                              UpdatePassGrade(
                                ReactEvent.Form.target(event)##value
                                |> int_of_string,
                              ),
                            )
                        )
                        value={state.passGrade |> string_of_int}
                        className="cursor-pointer inline-block appearance-none bg-white border-b-2 text-2xl font-semibold text-center border-blue hover:border-gray-500 px-3 py-2 rounded-none leading-tight focus:outline-none">
                        {
                          possibleGradeValues
                          |> List.filter(g => g < state.maxGrade)
                          |> List.map(possibleGradeValue =>
                               <option
                                 key={possibleGradeValue |> string_of_int}
                                 value={possibleGradeValue |> string_of_int}>
                                 {possibleGradeValue |> string_of_int |> str}
                               </option>
                             )
                          |> Array.of_list
                          |> ReasonReact.array
                        }
                      </select>
                    }
                  }
                </div>
                <label
                  className="block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                  htmlFor="grades">
                  {"Grades" |> str}
                </label>
                <div className="flex">
                  <div
                    className="flex flex-col bg-white p-6 shadow items-center justify-center rounded w-full">
                    <h2
                      className="grades__score-circle rounded-full h-24 w-24 flex items-center justify-center border-2 border-green-400 p-4 mb-4">
                      {
                        (state.selectedGrade |> string_of_int)
                        ++ "/"
                        ++ (state.maxGrade |> string_of_int)
                        |> str
                      }
                    </h2>
                    <div>
                      {
                        state.gradesAndLabels
                        |> List.filter(gradesAndLabel =>
                             gradesAndLabel
                             |> GradesAndLabels.grade == state.selectedGrade
                           )
                        |> List.map(gradesAndLabel =>
                             <div
                               key={
                                 gradesAndLabel
                                 |> GradesAndLabels.grade
                                 |> string_of_int
                               }>
                               <input
                                 className="text-center grades__label-input appearance-none inline-block bg-white text-gray-800 border border-gray-400 rounded py-2 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                                 id={
                                   "label"
                                   ++ (
                                     gradesAndLabel
                                     |> GradesAndLabels.grade
                                     |> string_of_int
                                   )
                                 }
                                 type_="text"
                                 placeholder="Type grade label"
                                 value={
                                   gradesAndLabel |> GradesAndLabels.label
                                 }
                                 onChange={
                                   event =>
                                     send(
                                       UpdateGradesAndLabels(
                                         GradesAndLabels.update(
                                           ReactEvent.Form.target(event)##value,
                                           gradesAndLabel,
                                         ),
                                       ),
                                     )
                                 }
                               />
                             </div>
                           )
                        |> Array.of_list
                        |> ReasonReact.array
                      }
                    </div>
                    <div className="grade-bar__container w-full mb-6">
                      <ul className="grade-bar__track flex justify-between">
                        {
                          state.gradesAndLabels
                          |> List.filter(gradesAndLabel =>
                               gradesAndLabel
                               |> GradesAndLabels.grade <= state.maxGrade
                             )
                          |> List.map(gradesAndLabel =>
                               <li
                                 key={
                                   gradesAndLabel
                                   |> GradesAndLabels.grade
                                   |> string_of_int
                                 }
                                 className="flex flex-1 grade-bar__track-segment justify-center items-center relative"
                                 onClick={
                                   _ =>
                                     send(
                                       UpdateSelectedGrade(
                                         gradesAndLabel
                                         |> GradesAndLabels.grade,
                                       ),
                                     )
                                 }>
                                 <span
                                   className="grade-bar__track-segment-title whitespace-no-wrap text-xs z-20">
                                   {
                                     (
                                       gradesAndLabel |> GradesAndLabels.valid ?
                                         gradesAndLabel
                                         |> GradesAndLabels.label :
                                         "Add grade label"
                                     )
                                     |> str
                                   }
                                 </span>
                                 <label
                                   htmlFor={
                                     "label"
                                     ++ (
                                       gradesAndLabel
                                       |> GradesAndLabels.grade
                                       |> string_of_int
                                     )
                                   }
                                   className={
                                     "flex items-center justify-center z-10 grade-bar__pointer"
                                     ++ gradeBarBulletClasses(
                                          gradesAndLabel
                                          |> GradesAndLabels.grade
                                          == state.selectedGrade,
                                          gradesAndLabel
                                          |> GradesAndLabels.grade
                                          >= state.passGrade,
                                          !(
                                            gradesAndLabel
                                            |> GradesAndLabels.valid
                                          ),
                                        )
                                   }>
                                   {
                                     gradesAndLabel
                                     |> GradesAndLabels.grade
                                     |> string_of_int
                                     |> str
                                   }
                                 </label>
                               </li>
                             )
                          |> Array.of_list
                          |> ReasonReact.array
                        }
                      </ul>
                    </div>
                    <div
                      className="flex justify-between items-center pt-6 pb-5">
                      <div className="flex justify-center items-center mx-4">
                        <span
                          className="grade-bar__pointer-legend grade-bar__pointer-legend-failed"
                        />
                        <span className="ml-2 text-xs"> {"Fail" |> str} </span>
                      </div>
                      <div className="flex justify-center items-center mx-4">
                        <span
                          className="grade-bar__pointer-legend grade-bar__pointer-legend-passed"
                        />
                        <span className="ml-2 text-xs">
                          {"Passed" |> str}
                        </span>
                      </div>
                      <div className="flex justify-center items-center mx-4">
                        <span
                          className="grade-bar__pointer-legend grade-bar__pointer--pulse"
                        />
                        <span className="ml-2 text-xs">
                          {"Add grade label" |> str}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="mt-3 mb-3 text-xs">
                  <span className="leading-normal">
                    <strong> {"Important:" |> str} </strong>
                    {
                      " The values for maximum and passing grades cannot be modified once a course is created. Labels given to each grade can be edited later on."
                      |> str
                    }
                  </span>
                </div>
                <div className="flex">
                  {
                    switch (course) {
                    | Some(course) =>
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(
                          _ =>
                            updateCourse(
                              authenticityToken,
                              state,
                              send,
                              updateCoursesCB,
                              course,
                            )
                        )
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Update Course" |> str}
                      </button>

                    | None =>
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(
                          _ =>
                            createCourse(
                              authenticityToken,
                              state,
                              send,
                              updateCoursesCB,
                            )
                        )
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
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
