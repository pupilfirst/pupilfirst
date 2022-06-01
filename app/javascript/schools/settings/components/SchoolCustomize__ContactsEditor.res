open SchoolCustomize__Types

let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__ContactsEditor")
let ts = I18n.ts

type action =
  | UpdateAddress(string)
  | UpdateEmailAddress(string, bool)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating

type state = {
  address: string,
  emailAddress: string,
  emailAddressInvalid: bool,
  updating: bool,
  formDirty: bool,
}

let handleInputChange = (callback, event) => {
  let value = ReactEvent.Form.target(event)["value"]
  callback(value)
}

let updateContactDetailsButtonText = updating => updating ? { ts("updating") ++ "..."} : t("update_contact")

module UpdateContactDetailsQuery = %graphql(`
   mutation UpdateAddressAndEmailMutation($address: String!, $emailAddress: String!) {
     updateAddress: updateSchoolString(key: "address", value: $address) {
       errors
     }

     updateEmailAddress: updateSchoolString(key: "email_address", value: $emailAddress) {
       errors
     }
   }
  `)

module UpdateSchoolStringErrorHandler = GraphqlErrorHandler.Make(
  SchoolCustomize__UpdateSchoolStringError,
)

let handleUpdateContactDetails = (state, send, updateAddressCB, updateEmailAddressCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send(BeginUpdate)

  UpdateContactDetailsQuery.make({address: state.address, emailAddress: state.emailAddress})
  |> Js.Promise.then_(result =>
    switch (result["updateAddress"]["errors"], result["updateEmailAddress"]["errors"]) {
    | ([], []) =>
      Notification.success(ts("notifications.done_exclamation"), t("contact_updated_notification"))
      updateAddressCB(state.address)
      updateEmailAddressCB(state.emailAddress)
      send(DoneUpdating)
      Js.Promise.resolve()
    | ([], errors) =>
      Notification.notice(t("partial_success_notification"), t("update_address_notification"))
      Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors))
    | (errors, []) =>
      Notification.notice(t("partial_success_notification"), t("update_email_notification"))
      Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors))
    | (addressErrors, emailAddressErrors) =>
      let errors = addressErrors |> Array.append(emailAddressErrors)
      Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors))
    }
  )
  |> UpdateSchoolStringErrorHandler.catch(() => send(ErrorOccured))
  |> ignore
  ()
}

let updateButtonDisabled = state =>
  if state.updating {
    true
  } else {
    !state.formDirty || state.emailAddressInvalid
  }

let initialState = customizations => {
  address: customizations |> Customizations.address |> OptionUtils.default(""),
  emailAddress: customizations |> Customizations.emailAddress |> OptionUtils.default(""),
  emailAddressInvalid: false,
  updating: false,
  formDirty: false,
}

let reducer = (state, action) =>
  switch action {
  | UpdateAddress(address) => {...state, address: address, formDirty: true}
  | UpdateEmailAddress(emailAddress, invalid) => {
      ...state,
      emailAddress: emailAddress,
      emailAddressInvalid: invalid,
      formDirty: true,
    }
  | BeginUpdate => {...state, updating: true}
  | ErrorOccured => {...state, updating: false}
  | DoneUpdating => {...state, updating: false, formDirty: false}
  }

@react.component
let make = (~customizations, ~updateAddressCB, ~updateEmailAddressCB) => {
  let (state, send) = React.useReducer(reducer, initialState(customizations))

  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-gray-300 pb-2">
      {t("manage_contact") |> str}
    </h5>
    <DisablingCover disabled=state.updating>
      <div key="contacts-editor__address-input-group" className="mt-3">
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="contacts-editor__address">
          { t("contact_address") ++ " " |> str} <i className="fab fa-markdown text-base" />
        </label>
        <textarea
          autoFocus=true
          maxLength=1000
          className="appearance-none block w-full bg-white text-gray-800 border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          id="contacts-editor__address"
          placeholder=t("address_placeholder")
          onChange={handleInputChange(address => send(UpdateAddress(address)))}
          value=state.address
        />
      </div>
      <div key="contacts-editor__email-address-input-group" className="mt-3">
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="contacts-editor__email-address">
          {t("email_address") |> str}
        </label>
        <input
          type_="text"
          maxLength=250
          className="appearance-none block w-full bg-white text-gray-800 border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          id="contacts-editor__email-address"
          placeholder=t("email_address_placeholder")
          onChange={handleInputChange(emailAddress =>
            send(UpdateEmailAddress(emailAddress, emailAddress |> EmailUtils.isInvalid(true)))
          )}
          value=state.emailAddress
        />
        <School__InputGroupError
          message=t("email_address_error") active=state.emailAddressInvalid
        />
      </div>
      <button
        key="contacts-editor__update-button"
        disabled={updateButtonDisabled(state)}
        onClick={handleUpdateContactDetails(state, send, updateAddressCB, updateEmailAddressCB)}
        className="w-full btn btn-primary btn-large mt-6">
        {updateContactDetailsButtonText(state.updating) |> str}
      </button>
    </DisablingCover>
  </div>
}
