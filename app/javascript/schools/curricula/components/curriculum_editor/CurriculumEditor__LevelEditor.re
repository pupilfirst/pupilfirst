open CurriculumEditor__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;
type keyForStateUpdation =
  | Name
  | UnlockOn;

type state = {
  name: string,
  unlockOn: option(string),
  saveDisabled: bool,
};

type action =
  | UpdateState(keyForStateUpdation, string);

let component = ReasonReact.reducerComponent("CurriculumEditor__LevelEditor");

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
        saveDisabled: true,
      }
    | None => {name: "", unlockOn: None, saveDisabled: true}
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateState(keyForStateUpdation, string) =>
      switch (keyForStateUpdation) {
      | Name =>
        ReasonReact.Update({...state, name: string, saveDisabled: false})
      | UnlockOn =>
        ReasonReact.Update({
          ...state,
          unlockOn: Some(string),
          saveDisabled: false,
        })
      }
    },
  render: ({state, send}) => {
    let handleResponseCB = json => {
      let id = json |> Json.Decode.(field("id", int));
      let levelNumber = json |> Json.Decode.(field("levelNumber", int));
      let newLevel =
        Level.create(id, state.name, levelNumber, state.unlockOn);
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
      <div className="drawer-right">
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
                      send(
                        UpdateState(
                          Name,
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                />
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
                      send(
                        UpdateState(
                          UnlockOn,
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                />
                <div className="flex">
                  <button
                    onClick={_ => hideEditorActionCB()}
                    className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Close" |> str}
                  </button>
                </div>
                <div className="flex">
                  {
                    switch (level) {
                    | Some(level) =>
                      let id = level |> Level.id;
                      <button
                        disabled={state.saveDisabled}
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