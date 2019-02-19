type state = {
  name: string,
  email: string,
  hasNameError: bool,
  hasEmailError: bool,
};

type action =
  | UpdateName(string)
  | UpdateEmail(string)
  | UpdateErrors(bool, bool);

let component = ReasonReact.reducerComponent("SA_StudentsPanel_StudentForm");

let str = ReasonReact.string;

let updateName = (send, state, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name));
  send(UpdateErrors(hasError, state.hasEmailError));
};

let updateEmail = (send, state, email) => {
  let regex = [%re {|/.+@.+\..+/i|}];
  let hasError = !Js.Re.test(email, regex);
  send(UpdateEmail(email));
  send(UpdateErrors(state.hasNameError, hasError));
};

let formInvalid = state => {
  state.name == "" || state.email == "" || state.hasNameError || state.hasEmailError;
};

let make = (~closeFormCB, _children) => {
  ...component,
  initialState: () => {name: "", email: "", hasNameError: false, hasEmailError: false},
  reducer: (action, state) => {
    switch (action) {
    | UpdateName(name) => ReasonReact.Update({...state, name})
    | UpdateEmail(email) => ReasonReact.Update({...state, email})
    | UpdateErrors(hasNameError, hasEmailError) => ReasonReact.Update({...state, hasNameError, hasEmailError})
    };
  },
  render: ({state, send}) =>
    <div className="blanket">
      <div className="drawer-right">
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5 className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  {"Student Details" |> str}
                </h5>
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
                  {"Email*  " |> str}
                </label>
                <input
                  value={state.email}
                  onChange={event => updateEmail(send, state, ReactEvent.Form.target(event)##value)}
                  className="drawer-right-form__input appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="level number"
                  type_="email"
                  placeholder="Student email here"
                />
                {state.hasEmailError ?
                   <div className="drawer-right-form__error-msg"> {"not a valid email" |> str} </div> :
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
                    {"Add Student" |> str}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};
