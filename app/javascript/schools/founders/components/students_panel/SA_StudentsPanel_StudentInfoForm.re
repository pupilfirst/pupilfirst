open StudentsPanel__Types;

type state = {
  name: string,
  email: string,
  hasNameError: bool,
  hasEmailError: bool,
  tagsToApply: list(string),
};

type action =
  | UpdateName(string, bool)
  | UpdateEmail(string, bool)
  | ResetForm
  | AddTag(string)
  | RemoveTag(string);

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
    addToListCB(
      StudentInfo.create(state.name, state.email, state.tagsToApply),
    );
    send(ResetForm);
  };

let make = (~addToListCB, ~studentTags, _children) => {
  ...component,
  initialState: () => {
    name: "",
    email: "",
    hasNameError: false,
    hasEmailError: false,
    tagsToApply: [],
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
        tagsToApply: state.tagsToApply,
      })
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
    <div className="bg-grey-100 p-4">
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
      <div className="mt-6">
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
          htmlFor="tags">
          {"Tags" |> str}
        </label>
        <SA_StudentsPanel_SearchableTagList
          unselectedTags={
            studentTags
            |> List.filter(tag => !(state.tagsToApply |> List.mem(tag)))
          }
          selectedTags={state.tagsToApply}
          addTagCB={tag => send(AddTag(tag))}
          removeTagCB={tag => send(RemoveTag(tag))}
          allowNewTags=true
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