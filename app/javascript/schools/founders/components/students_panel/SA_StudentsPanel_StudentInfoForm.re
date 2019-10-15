open StudentsPanel__Types;

type state = {
  name: string,
  email: string,
  title: string,
  affiliation: string,
  hasNameError: bool,
  hasEmailError: bool,
  tagsToApply: list(string),
};

type action =
  | UpdateName(string, bool)
  | UpdateEmail(string, bool)
  | UpdateTitle(string)
  | UpdateAffiliation(string)
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
  let hasError = !Js.Re.test_(regex, email);
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
      StudentInfo.make(
        state.name,
        state.email,
        state.title,
        state.affiliation,
        state.tagsToApply,
      ),
    );
    send(ResetForm);
  };

let make = (~addToListCB, ~studentTags, _children) => {
  ...component,
  initialState: () => {
    name: "",
    email: "",
    title: "",
    affiliation: "",
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
    | UpdateTitle(title) => ReasonReact.Update({...state, title})
    | UpdateAffiliation(affiliation) =>
      ReasonReact.Update({...state, affiliation})
    | ResetForm =>
      ReasonReact.Update({
        name: "",
        email: "",
        title: state.title,
        affiliation: state.affiliation,
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
    <div className="bg-gray-100 p-4">
      <div>
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="name">
          {"Name" |> str}
        </label>
        <input
          value={state.name}
          onChange={event =>
            updateName(send, ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
          id="name"
          type_="text"
          placeholder="Student name here"
        />
        <School__InputGroupError.Jsx2
          message="is not valid"
          active={state.hasNameError}
        />
      </div>
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="email">
          {"Email" |> str}
        </label>
        <input
          value={state.email}
          onChange={event =>
            updateEmail(send, ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
          id="email"
          type_="email"
          placeholder="Student email here"
        />
        <School__InputGroupError.Jsx2
          message="is too short"
          active={state.hasEmailError}
        />
      </div>
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
          htmlFor="title">
          {"Title" |> str}
        </label>
        <span className="text-xs ml-1"> {"(optional)" |> str} </span>
        <input
          value={state.title}
          onChange={event =>
            send(UpdateTitle(ReactEvent.Form.target(event)##value))
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
          id="title"
          type_="text"
          placeholder="Student, Coach, CEO, etc."
        />
      </div>
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
          htmlFor="affiliation">
          {"Affiliation" |> str}
        </label>
        <span className="text-xs ml-1"> {"(optional)" |> str} </span>
        <input
          value={state.affiliation}
          onChange={event =>
            send(UpdateAffiliation(ReactEvent.Form.target(event)##value))
          }
          className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
          id="affiliation"
          type_="text"
          placeholder="Acme Inc., Acme University, etc."
        />
      </div>
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="tags">
          {"Tags" |> str}
        </label>
        <span className="text-xs ml-1"> {"(optional)" |> str} </span>
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
          "btn btn-primary mt-5" ++ (formInvalid(state) ? " disabled" : "")
        }>
        {"Add to List" |> str}
      </button>
    </div>,
};
