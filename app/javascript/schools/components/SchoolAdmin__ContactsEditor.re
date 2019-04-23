open SchoolCustomize__Types;

let str = ReasonReact.string;

type action =
  | UpdateAddress(string)
  | UpdateEmailAddress(string)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating;

type state = {
  address: string,
  emailAddress: string,
  updating: bool,
  formDirty: bool,
};

let component =
  ReasonReact.reducerComponent("SchoolCustomize__ContactsEditor");

let handleInputChange = (callback, event) => {
  let value = ReactEvent.Form.target(event)##value;
  callback(value);
};

let updateContactDetailsButtonText = updating =>
  updating ? "Updating..." : "Update Contact Details";

module UpdateContactDetailsQuery = [%graphql
  {|
   mutation($address: String!, $emailAddress: String!) {
     updateAddress: updateSchoolString(key: "address", value: $address) {
       errors
     }

     updateEmailAddress: updateSchoolString(key: "email_address", value: $emailAddress) {
       errors
     }
   }
  |}
];

module UpdateSchoolStringErrorHandler =
  GraphqlErrorHandler.Make(SchoolCustomize__UpdateSchoolStringError);

let handleUpdateContactDetails =
    (
      state,
      send,
      authenticityToken,
      updateAddressCB,
      updateEmailAddressCB,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(BeginUpdate);

  UpdateContactDetailsQuery.make(
    ~address=state.address,
    ~emailAddress=state.emailAddress,
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(result =>
       switch (
         result##updateAddress##errors,
         result##updateEmailAddress##errors,
       ) {
       | ([||], [||]) =>
         Notification.success("Done!", "Contact details has been updated.");
         updateAddressCB(state.address);
         updateEmailAddressCB(state.emailAddress);
         send(DoneUpdating);
         Js.Promise.resolve();
       | ([||], errors) =>
         Notification.notice(
           "Partial success!",
           "We were only able to update the address.",
         );
         Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors));
       | (errors, [||]) =>
         Notification.notice(
           "Partial success!",
           "We were only able to update the email address.",
         );
         Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors));
       | (addressErrors, emailAddressErrors) =>
         let errors = addressErrors |> Array.append(emailAddressErrors);
         Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors));
       }
     )
  |> UpdateSchoolStringErrorHandler.catch(() => send(ErrorOccured))
  |> ignore;
  ();
};

let updateContactDetailsDisabled = state => !state.formDirty;

let optionToString = o =>
  switch (o) {
  | Some(v) => v
  | None => ""
  };

let make =
    (
      ~customizations,
      ~authenticityToken,
      ~updateAddressCB,
      ~updateEmailAddressCB,
      _children,
    ) => {
  ...component,
  initialState: () => {
    address: customizations |> Customizations.address |> optionToString,
    emailAddress:
      customizations |> Customizations.emailAddress |> optionToString,
    updating: false,
    formDirty: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateAddress(address) =>
      ReasonReact.Update({...state, address, formDirty: true})
    | UpdateEmailAddress(emailAddress) =>
      ReasonReact.Update({...state, emailAddress, formDirty: true})
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
            {"Contact Address" |> str}
          </label>
          <textarea
            maxLength=1000
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="contacts-editor__address"
            placeholder="Leave the address empty to hide the footer section."
            onChange={
              handleInputChange(address => send(UpdateAddress(address)))
            }
            value={state.address}
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
            onChange={
              handleInputChange(emailAddress =>
                send(UpdateEmailAddress(emailAddress))
              )
            }
            value={state.emailAddress}
          />
        </div>
        <button
          key="contacts-editor__update-button"
          disabled={updateContactDetailsDisabled(state)}
          onClick={
            handleUpdateContactDetails(
              state,
              send,
              authenticityToken,
              updateAddressCB,
              updateEmailAddressCB,
            )
          }
          className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
          {updateContactDetailsButtonText(state.updating) |> str}
        </button>
      </SchoolAdmin__DisablingCover>
    </div>,
};