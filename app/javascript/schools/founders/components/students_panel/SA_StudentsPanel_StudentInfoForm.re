open StudentsPanel__Types;

type state = {
  name: string,
  email: string,
  hasNameError: bool,
  hasEmailError: bool,
};

type action =
  | UpdateName(string, bool)
  | UpdateEmail(string, bool)
  | ResetForm;

let component =
  ReasonReact.reducerComponent("SA_StudentsPanel_StudentInfoForm");

let str = ReasonReact.string;

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let updateEmail = (send, email) => {
  let regex = [%re {|/.+@.+\..+/i|}];
  let hasError = !Js.Re.test(email, regex);
  send(UpdateEmail(email, hasError));
};

let formInvalid = state =>
  state.name == ""
  || state.email == ""
  || state.hasNameError
  || state.hasEmailError;

let handleAdd = (state, send, addToListCB) =>
  if (!formInvalid(state)) {
    addToListCB(StudentInfo.create(state.name, state.email));
    send(ResetForm);
  };

let make = (~addToListCB, _children) => {
  ...component,
  initialState: () => {
    name: "",
    email: "",
    hasNameError: false,
    hasEmailError: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name, hasNameError) =>
      ReasonReact.Update({...state, name, hasNameError})
    | UpdateEmail(email, hasEmailError) =>
      ReasonReact.Update({...state, email, hasEmailError})
    | ResetForm =>
      ReasonReact.Update({
        name: "",
        email: "",
        hasNameError: false,
        hasEmailError: false,
      })
    },
  render: ({state, send}) =>
    <div className="bg-grey-lightest p-4">
      <div>
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
          htmlFor="name">
          {"Name" |> str}
        </label>
        <span> {"*" |> str} </span>
        <input
          value={state.name}
          onChange={
            event => updateName(send, ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
          id="name"
          type_="text"
          placeholder="Student name here"
        />
        <School__InputGroupError
          message="is not valid"
          active={state.hasNameError}
        />
      </div>
      <div className="mt-6">
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
          htmlFor="email">
          {"Email" |> str}
        </label>
        <span> {"*" |> str} </span>
        <input
          value={state.email}
          onChange={
            event => updateEmail(send, ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
          id="email"
          type_="email"
          placeholder="Student email here"
        />
        <School__InputGroupError
          message="is too short"
          active={state.hasEmailError}
        />
      </div>
      <button
        onClick={_e => handleAdd(state, send, addToListCB)}
        className={
          "bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-6"
          ++ (formInvalid(state) ? " opacity-50 cursor-not-allowed" : "")
        }>
        {"Add to List" |> str}
      </button>
    </div>,
};