open CurriculumEditor__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;
type state = {
  name: string,
  unlockOn: option(string),
  hasNameError: bool,
  hasDateError: bool,
  dirty: bool,
  saving: bool,
};

type action =
  | UpdateName(string, bool)
  | UpdateUnlockOn(string, bool)
  | UpdateSaving;

let component = ReasonReact.reducerComponent("CurriculumEditor__LevelEditor");

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let updateUnlockOn = (send, date) => {
  let regex = [%re
    {|/^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/|}
  ];

  let lengthOfInput = date |> String.length;
  let hasError = lengthOfInput == 0 ? false : !Js.Re.test(date, regex);
  send(UpdateUnlockOn(date, hasError));
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

  switch (state.unlockOn) {
  | Some(date) => Js.Dict.set(payload, "unlock_on", date |> Js.Json.string)
  | None => Js.Dict.set(payload, "unlock_on", "" |> Js.Json.string)
  };
  payload;
};
let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full";

let make =
    (
      ~level,
      ~course,
      ~authenticityToken,
      ~hideEditorActionCB,
      ~updateLevelsCB,
      _children,
    ) => {
  ...component,
  initialState: () =>
    switch (level) {
    | Some(level) => {
        name: level |> Level.name,
        unlockOn: level |> Level.unlockOn,
        hasNameError: false,
        hasDateError: false,
        dirty: false,
        saving: false,
      }
    | None => {
        name: "",
        unlockOn: None,
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
    | UpdateUnlockOn(date, hasDateError) =>
      ReasonReact.Update({
        ...state,
        unlockOn: Some(date),
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
      let newLevel = Level.create(id, state.name, number, state.unlockOn);
      switch (level) {
      | Some(_) =>
        Notification.success("Success", "Level updated successfully")
      | None => Notification.success("Success", "Level created successfully")
      };
      updateLevelsCB(newLevel);
    };

    let createLevel = (authenticityToken, course, state) => {
      send(UpdateSaving);
      let course_id = course |> Course.id |> string_of_int;
      let url = "/school/courses/" ++ course_id ++ "/levels";
      Api.create(
        url,
        setPayload(authenticityToken, state),
        handleResponseCB,
        handleErrorCB,
      );
    };

    let updateLevel = (authenticityToken, levelId, state) => {
      send(UpdateSaving);
      let url = "/school/levels/" ++ levelId;
      Api.update(
        url,
        setPayload(authenticityToken, state),
        handleResponseCB,
        handleErrorCB,
      );
    };

    let unlockOn =
      switch (state.unlockOn) {
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
                  {"Level Details" |> str}
                </h5>
                <label
                  className="inline-block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                  htmlFor="name">
                  {"Level Name" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                  id="name"
                  type_="text"
                  placeholder="Type level name here"
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
                  className="block tracking-wide text-gray-800 text-xs font-semibold mb-2"
                  htmlFor="date">
                  {"Unlock level on" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                  id="date"
                  type_="text"
                  placeholder="DD/MM/YYYY"
                  value=unlockOn
                  onChange={
                    event =>
                      updateUnlockOn(
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
                <div className="flex">
                  {
                    switch (level) {
                    | Some(level) =>
                      let id = level |> Level.id;
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(
                          _event =>
                            updateLevel(
                              authenticityToken,
                              id |> string_of_int,
                              state,
                            )
                        )
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Update Level" |> str}
                      </button>;

                    | None =>
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(
                          _event =>
                            createLevel(authenticityToken, course, state)
                        )
                        className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Create New Level" |> str}
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