open CurriculumEditor__Types;
open SchoolAdmin__Utils;

let str = ReasonReact.string;
type state = {
  name: string,
  description: string,
  milestone: bool,
  hasNameError: bool,
  saveDisabled: bool,
};

type action =
  | UpdateName(string, bool)
  | UpdateDescription(string)
  | UpdateMilestone(bool);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetGroupEditor");

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let saveDisabled = state => state.hasNameError || state.saveDisabled;

let setPayload = (authenticityToken, state) => {
  let payload = Js.Dict.empty();
  let milestone = state.milestone == true ? "true" : "false";
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(payload, "name", state.name |> Js.Json.string);
  Js.Dict.set(payload, "description", state.description |> Js.Json.string);
  Js.Dict.set(payload, "milestone", milestone |> Js.Json.string);
  payload;
};

let milestoneButtonClasses = value =>
  value ?
    "w-1/2 bg-grey hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none" :
    "w-1/2 bg-white border-l hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none";

let make =
    (
      ~targetGroup,
      ~currentLevelId,
      ~authenticityToken,
      ~updateTargetGroupsCB,
      ~hideEditorActionCB,
      _children,
    ) => {
  ...component,
  initialState: () =>
    switch (targetGroup) {
    | Some(targetGroup) => {
        name: targetGroup |> TargetGroup.name,
        description:
          switch (targetGroup |> TargetGroup.description) {
          | Some(description) => description
          | None => ""
          },
        milestone: targetGroup |> TargetGroup.milestone,
        hasNameError: false,
        saveDisabled: true,
      }
    | None => {
        name: "",
        description: "",
        milestone: true,
        hasNameError: false,
        saveDisabled: true,
      }
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name, hasNameError) =>
      ReasonReact.Update({...state, name, hasNameError, saveDisabled: false})
    | UpdateDescription(description) =>
      ReasonReact.Update({...state, description, saveDisabled: false})
    | UpdateMilestone(milestone) =>
      ReasonReact.Update({...state, milestone, saveDisabled: false})
    },
  render: ({state, send}) => {
    let handleResponseCB = json => {
      let id = json |> Json.Decode.(field("id", int));
      let sortIndex = json |> Json.Decode.(field("sortIndex", int));
      let newTargetGroup =
        TargetGroup.create(
          id,
          state.name,
          Some(state.description),
          state.milestone,
          currentLevelId,
          sortIndex,
        );
      switch (targetGroup) {
      | Some(_) =>
        Notification.success("Success", "Target Group updated succesffully")
      | None =>
        Notification.success("Success", "Target Group created succesffully")
      };
      updateTargetGroupsCB(newTargetGroup);
    };

    let createTargetGroup = () => {
      let level_id = currentLevelId |> string_of_int;
      let payload = setPayload(authenticityToken, state);
      let url = "/school/levels/" ++ level_id ++ "/target_groups";
      Api.create(url, payload, handleResponseCB);
    };

    let updateTargetGroup = targetGroupId => {
      let payload = setPayload(authenticityToken, state);
      let url = "/school/target_groups/" ++ targetGroupId;
      Api.update(url, payload, handleResponseCB);
    };

    <div className="blanket">
      <div className="drawer-right">
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Target Group Details" |> str}
                </h5>
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="name">
                  {"Title*  " |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="name"
                  type_="text"
                  placeholder="Type target group name here"
                  value={state.name}
                  onChange={
                    event =>
                      updateName(send, ReactEvent.Form.target(event)##value)
                  }
                />
                {
                  state.hasNameError ?
                    <div className="drawer-right-form__error-msg">
                      {"not a valid Title" |> str}
                    </div> :
                    ReasonReact.null
                }
                <label
                  className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="description">
                  {" Description" |> str}
                </label>
                <textarea
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="description"
                  placeholder="Type target group description"
                  value={state.description}
                  onChange={
                    event =>
                      send(
                        UpdateDescription(
                          ReactEvent.Form.target(event)##value,
                        ),
                      )
                  }
                  rows=5
                  cols=33
                />
                <div className="flex items-center mb-6">
                  <label
                    className="block tracking-wide text-grey-darker text-xs font-semibold mr-6">
                    {"Is this a milestone target?" |> str}
                  </label>
                  <div
                    className="inline-flex w-64 rounded-lg overflow-hidden border">
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(UpdateMilestone(true));
                        }
                      }
                      className={
                        milestoneButtonClasses(state.milestone == true)
                      }>
                      {"Yes" |> str}
                    </button>
                    <button
                      onClick={
                        _event => {
                          ReactEvent.Mouse.preventDefault(_event);
                          send(UpdateMilestone(false));
                        }
                      }
                      className={
                        milestoneButtonClasses(state.milestone == false)
                      }>
                      {"No" |> str}
                    </button>
                  </div>
                </div>
                <div className="flex">
                  <button
                    onClick={_ => hideEditorActionCB()}
                    className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Close" |> str}
                  </button>
                </div>
                <div className="flex">
                  {
                    switch (targetGroup) {
                    | Some(targetGroup) =>
                      let id = targetGroup |> TargetGroup.id;
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(_e => updateTargetGroup(id |> string_of_int))
                        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Update Target Group" |> str}
                      </button>;

                    | None =>
                      <button
                        disabled={saveDisabled(state)}
                        onClick=(_e => createTargetGroup())
                        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                        {"Create Target Group" |> str}
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