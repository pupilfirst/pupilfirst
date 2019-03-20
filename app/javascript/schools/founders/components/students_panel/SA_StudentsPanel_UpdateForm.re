open StudentsPanel__Types;
open SchoolAdmin__Utils;

type state = {
  name: string,
  teamName: string,
  hasNameError: bool,
  hasTeamNameError: bool,
  tagsToApply: list(string),
};

type action =
  | UpdateName(string)
  | UpdateTeamName(string)
  | UpdateErrors(bool, bool)
  | AddTag(string)
  | RemoveTag(string);

let component = ReasonReact.reducerComponent("SA_StudentsPanel_UpdateForm");

let str = ReasonReact.string;

let updateName = (send, state, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name));
  send(UpdateErrors(hasError, state.hasTeamNameError));
};

let updateTeamName = (send, state, teamName) => {
  let hasError = teamName |> String.length < 3;
  send(UpdateTeamName(teamName));
  send(UpdateErrors(state.hasNameError, hasError));
};

let formInvalid = state => state.hasNameError || state.hasTeamNameError;
let handleErrorCB = () => ();
let handleResponseCB = (submitCB, state, json) => {
  let teams = json |> Json.Decode.(field("teams", list(Team.decode)));
  submitCB(teams, state.tagsToApply);
  Notification.success("Success", "Student updated successfully");
};

let updateStudent = (student, state, authenticityToken, responseCB) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  let updatedStudent =
    student |> Student.updateInfo(state.name, state.teamName);

  Js.Dict.set(payload, "founder", updatedStudent |> Student.encode);
  Js.Dict.set(
    payload,
    "tags",
    state.tagsToApply |> Json.Encode.(list(string)),
  );

  let url = "/school/students/" ++ (student |> Student.id |> string_of_int);
  Api.update(url, payload, responseCB, handleErrorCB);
};

let make =
    (
      ~student,
      ~studentTags,
      ~closeFormCB,
      ~submitFormCB,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {
    name: student |> Student.name,
    teamName: student |> Student.teamName,
    hasNameError: false,
    hasTeamNameError: false,
    tagsToApply: student |> Student.tags,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name) => ReasonReact.Update({...state, name})
    | UpdateTeamName(teamName) => ReasonReact.Update({...state, teamName})
    | UpdateErrors(hasNameError, hasTeamNameError) =>
      ReasonReact.Update({...state, hasNameError, hasTeamNameError})
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
            className="flex items-center justify-center bg-grey-lighter text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> str} </i>
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div
                className="flex items-centre py-6 pl-16 mb-4 bg-grey-lighter">
                <img
                  className="w-12 h-12 rounded-full mr-4"
                  src={student |> Student.avatarUrl}
                />
                <div className="text-sm flex flex-col justify-center">
                  <div className="text-black font-bold inline-block">
                    {student |> Student.name |> str}
                  </div>
                  <div className="text-grey-dark inline-block">
                    {student |> Student.email |> str}
                  </div>
                </div>
              </div>
              <div className="max-w-md p-6 mx-auto">
                <label
                  className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="name">
                  {"Name" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  value={state.name}
                  onChange={
                    event =>
                      updateName(
                        send,
                        state,
                        ReactEvent.Form.target(event)##value,
                      )
                  }
                  className="drawer-right-form__input appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="name"
                  type_="text"
                  placeholder="Student name here"
                />
                {
                  state.hasNameError ?
                    <div className="drawer-right-form__error-msg">
                      {"not a valid name" |> str}
                    </div> :
                    ReasonReact.null
                }
                <label
                  className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                  htmlFor="team_name">
                  {"Team Name" |> str}
                </label>
                <span> {"*" |> str} </span>
                <input
                  value={state.teamName}
                  onChange={
                    event =>
                      updateTeamName(
                        send,
                        state,
                        ReactEvent.Form.target(event)##value,
                      )
                  }
                  className="drawer-right-form__input appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="team_name"
                  type_="text"
                  placeholder="Team name here"
                />
                {
                  state.hasTeamNameError ?
                    <div className="drawer-right-form__error-msg">
                      {"not a valid team name" |> str}
                    </div> :
                    ReasonReact.null
                }
                <div className="mt-6">
                  <div className="border-b border-grey-light pb-2 mb-2">
                    <span className="mr-1"> {"Tags applied:" |> str} </span>
                  </div>
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
                <div className="flex flex-wrap">
                  <button
                    onClick={
                      _e =>
                        updateStudent(
                          student,
                          state,
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
                    {"Update Student" |> str}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};