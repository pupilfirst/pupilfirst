open StudentsPanel__Types;

type state = {
  name: string,
  teamName: string,
  hasNameError: bool,
  hasTeamNameError: bool,
};

type action =
  | UpdateName(string)
  | UpdateTeamName(string)
  | UpdateErrors(bool, bool);

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

let formInvalid = state => {
  state.hasNameError || state.hasTeamNameError;
};

let make = (~student, ~closeFormCB, _children) => {
  ...component,
  initialState: () => {
    name: student |> Student.name,
    teamName: student |> Student.teamName,
    hasNameError: false,
    hasTeamNameError: false,
  },
  reducer: (action, state) => {
    switch (action) {
    | UpdateName(name) => ReasonReact.Update({...state, name})
    | UpdateTeamName(teamName) => ReasonReact.Update({...state, teamName})
    | UpdateErrors(hasNameError, hasTeamNameError) => ReasonReact.Update({...state, hasNameError, hasTeamNameError})
    };
  },
  render: ({state, send}) =>
    <div className="blanket">
      <div className="drawer-right">
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="flex items-centre py-6 pl-16 mb-4 bg-grey-lighter">
                <img className="w-12 h-12 rounded-full mr-4" src={student |> Student.avatarUrl} />
                <div className="text-sm flex flex-col justify-center">
                  <div className="text-black font-bold inline-block"> {student |> Student.name |> str} </div>
                  <div className="text-grey-dark inline-block"> {student |> Student.email |> str} </div>
                </div>
              </div>
              <div className="max-w-md p-6 mx-auto">
                <label className="block tracking-wide text-grey-darker text-xs font-semibold mb-2" htmlFor="name">
                  {"Name*  " |> str}
                </label>
                <input
                  value={state.name}
                  onChange={event => updateName(send, state, ReactEvent.Form.target(event)##value)}
                  className="drawer-right-form__input appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="name"
                  type_="text"
                  placeholder="Student name here"
                />
                {state.hasNameError ?
                   <div className="drawer-right-form__error-msg"> {"not a valid name" |> str} </div> : ReasonReact.null}
                <label className="block tracking-wide text-grey-darker text-xs font-semibold mb-2">
                  {"Team Name*  " |> str}
                </label>
                <input
                  value={state.teamName}
                  onChange={event => updateTeamName(send, state, ReactEvent.Form.target(event)##value)}
                  className="drawer-right-form__input appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="team_name"
                  type_="text"
                  placeholder="Team name here"
                />
                {state.hasTeamNameError ?
                   <div className="drawer-right-form__error-msg"> {"not a valid team name" |> str} </div> :
                   ReasonReact.null}
                <div className="flex">
                  <button
                    onClick={_e => closeFormCB()}
                    className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                    {"Close" |> str}
                  </button>
                </div>
                <div className="flex">
                  <button
                    className={
                      "w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3"
                      ++ (formInvalid(state) ? " opacity-50 cursor-not-allowed" : "")
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
