open SchoolCustomize__Types;

let str = ReasonReact.string;

type action =
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating;

type state = {
  updating: bool,
  formDirty: bool,
};

let component = ReasonReact.reducerComponent("SchoolCustomize__ImagesEditor");

let updateButtonText = updating => updating ? "Updating..." : "Update Images";

let handleUpdateImages =
    (state, send, authenticityToken, updateImagesCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(BeginUpdate);
};

let updateButtonDisabled = state =>
  if (state.updating) {
    true;
  } else {
    !state.formDirty;
  };

let make = (~customizations, ~updateImagesCB, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {updating: false, formDirty: false},
  reducer: (action, state) =>
    switch (action) {
    | BeginUpdate => ReasonReact.Update({...state, updating: true})
    | ErrorOccured => ReasonReact.Update({...state, updating: false})
    | DoneUpdating =>
      ReasonReact.Update({...state, updating: false, formDirty: false})
    },
  render: ({state, send}) =>
    <div className="mx-8 pt-8">
      <h5 className="uppercase text-center border-b border-grey-light pb-2">
        {"Manage Contact Details" |> str}
      </h5>
      <SchoolAdmin__DisablingCover disabled={state.updating}>
        <div key="contacts-editor__address-input-group" className="mt-3">
          <label
            className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
            htmlFor="contacts-editor__address">
            {"Contact Address " |> str}
            <i className="fab fa-markdown text-base" />
          </label>
          <textarea
            maxLength=1000
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="contacts-editor__address"
            placeholder="Leave the address empty to hide the footer section."
          />
        </div>
        <div key="contacts-editor__email-address-input-group" className="mt-3">
          <label
            className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
            htmlFor="contacts-editor__email-address">
            {"Email Address" |> str}
          </label>
          <input
            type_="text"
            maxLength=250
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="contacts-editor__email-address"
            placeholder="Leave the email address empty to hide the footer link."
          />
        </div>
        <button
          key="contacts-editor__update-button"
          disabled={updateButtonDisabled(state)}
          onClick={
            handleUpdateImages(state, send, authenticityToken, updateImagesCB)
          }
          className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
          {updateButtonText(state.updating) |> str}
        </button>
      </SchoolAdmin__DisablingCover>
    </div>,
};