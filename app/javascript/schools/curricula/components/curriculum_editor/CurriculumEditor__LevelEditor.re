open CurriculumEditor__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;
type state = {
  name: string,
  unlockOn: option(string),
  hasNameError: bool,
  hasDateError: bool,
  saveDisabled: bool,
};

type action =
  | UpdateName(string, bool)
  | UpdateUnlockOn(string, bool);

let component = ReasonReact.reducerComponent("CurriculumEditor__LevelEditor");

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let updateUnlockOn = (send, date) => {
  let regex = [%re
    {|/^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/|}
  ];
  let hasError = !Js.Re.test(date, regex);
  send(UpdateUnlockOn(date, hasError));
};

let saveDisabled = state =>
  state.hasDateError || state.hasNameError || state.saveDisabled;

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
  | None => ()
  };
  payload;
};

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
        saveDisabled: true,
      }
    | None => {
        name: "",
        unlockOn: None,
        hasNameError: false,
        hasDateError: false,
        saveDisabled: true,
      }
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name, hasNameError) =>
      ReasonReact.Update({...state, name, hasNameError, saveDisabled: false})
    | UpdateUnlockOn(date, hasDateError) =>
      ReasonReact.Update({
        ...state,
        unlockOn: Some(date),
        hasDateError,
        saveDisabled: false,
      })
    },
  render: ({state, send}) => {
    let handleResponseCB = json => {
      let id = json |> Json.Decode.(field("id", int));
      let number = json |> Json.Decode.(field("number", int));
      let newLevel = Level.create(id, state.name, number, state.unlockOn);
      switch (level) {
      | Some(_) =>
        Notification.success("Success", "Level updated succesffully")
      | None => Notification.success("Success", "Level created succesffully")
      };
      updateLevelsCB(newLevel);
    };

    let createLevel = (authenticityToken, course, state) => {
      let course_id = course |> Course.id |> string_of_int;
      let url = "/school/courses/" ++ course_id ++ "/levels";
      Api.create(
        url,
        setPayload(authenticityToken, state),
        handleResponseCB,
      );
    };

    let updateLevel = (authenticityToken, levelId, state) => {
      let url = "/school/levels/" ++ levelId;
      Api.update(
        url,
        setPayload(authenticityToken, state),
        handleResponseCB,
      );
    };

    let unlockOn =
      switch (state.unlockOn) {
      | Some(date) => date
      | None => ""
      };
    <div className="blanket">
      <div className="drawer-right relative">
        <div className="drawer-right__close absolute">
          <button
            onClick={_ => hideEditorActionCB()}
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons">{"close" |> str }</i>
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Level Details" |> str}
                </h5>
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="name">
                  {"Level Name*  " |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
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
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2">
                  {"Lock level*  " |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="level unlock date"
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
                        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Update Level" |> str}
                      </button>;

                    | None =>
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(
                          _event =>
                            createLevel(authenticityToken, course, state)
                        )
                        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Create Level" |> str}
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