open SchoolCustomize__Types

%%raw(`import "./SchoolCustomize__AgreementsEditor.css"`)

let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__AgreementsEditor")
let ts = I18n.ts

type kind =
  | PrivacyPolicy
  | TermsAndConditions
  | CodeOfConduct

type action =
  | UpdateAgreement(string)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating

type state = {
  agreement: string,
  updating: bool,
  formDirty: bool,
}

let kindToString = kind =>
  switch kind {
  | PrivacyPolicy => t("privacy_policy")
  | TermsAndConditions => t("terms_and_conditions")
  | CodeOfConduct => ts("code_of_conduct")
  }

let kindToKey = kind =>
  switch kind {
  | PrivacyPolicy => "privacy_policy"
  | TermsAndConditions => "terms_and_conditions"
  | CodeOfConduct => "code_of_conduct"
  }

let handleAgreementChange = (send, event) => {
  let agreement = ReactEvent.Form.target(event)["value"]
  send(UpdateAgreement(agreement))
}

let updateAgreementText = (updating, kind) =>
  updating ? t("updating") : t("update") ++ " " ++ kindToString(kind)

module UpdateSchoolStringQuery = %graphql(`
   mutation UpdateSchoolStringMutation($key: String!, $value: String!) {
     updateSchoolString(key: $key, value: $value) {
       errors
     }
   }
  `)

module UpdateSchoolStringErrorHandler = GraphqlErrorHandler.Make(
  SchoolCustomize__UpdateSchoolStringError,
)

let handleUpdateAgreement = (
  state,
  send,
  kind,
  updatePrivacyPolicyCB,
  updateTermsAndConditionsCB,
  updateCodeOfConductCB,
  event,
) => {
  event |> ReactEvent.Mouse.preventDefault
  send(BeginUpdate)

  UpdateSchoolStringQuery.make({key: kindToKey(kind), value: state.agreement})
  |> Js.Promise.then_(result =>
    switch result["updateSchoolString"]["errors"] {
    | [] =>
      Notification.success(
        ts("notifications.done_exclamation"),
        kindToString(kind) ++ " " ++ t("updated_notification"),
      )
      switch kind {
      | PrivacyPolicy => updatePrivacyPolicyCB(state.agreement)
      | TermsAndConditions => updateTermsAndConditionsCB(state.agreement)
      | CodeOfConduct => updateCodeOfConductCB(state.agreement)
      }
      send(DoneUpdating)
      Js.Promise.resolve()
    | errors => Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors))
    }
  )
  |> UpdateSchoolStringErrorHandler.catch(() => send(ErrorOccured))
  |> ignore
  ()
}

let updateAgreementDisabled = state => !state.formDirty

let initialState = (kind, customizations) => {
  let agreement = switch kind {
  | PrivacyPolicy => customizations->Customizations.privacyPolicy
  | TermsAndConditions => customizations->Customizations.termsAndConditions
  | CodeOfConduct => customizations->Customizations.codeOfConduct
  }

  {
    agreement: switch agreement {
    | Some(agreement) => agreement
    | None => ""
    },
    updating: false,
    formDirty: false,
  }
}

let reducer = (state, action) =>
  switch action {
  | UpdateAgreement(agreement) => {...state, agreement, formDirty: true}
  | BeginUpdate => {...state, updating: true}
  | ErrorOccured => {...state, updating: false}
  | DoneUpdating => {...state, updating: false, formDirty: false}
  }

@react.component
let make = (
  ~kind,
  ~customizations,
  ~updatePrivacyPolicyCB,
  ~updateTermsAndConditionsCB,
  ~updateCodeOfConductCB,
) => {
  let (state, send) = React.useReducer(reducer, initialState(kind, customizations))
  <div className="mx-8 pt-8 flex flex-col agreements-editor__container">
    <h5 className="uppercase text-center border-b border-gray-300 pb-2">
      {t("manage") ++ " " ++ (kind |> kindToString) |> str}
    </h5>
    <DisablingCover disabled=state.updating containerClasses="flex flex-col flex-1">
      <div key="agreements-editor__input-group" className="mt-3 flex flex-col flex-1">
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="agreements-editor__value">
          {t("agreement_body") ++ " " |> str}
          <i className="fab fa-markdown text-base" />
        </label>
        <textarea
          autoFocus=true
          maxLength=20000
          className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500 flex-1"
          id="agreements-editor__value"
          placeholder={t("agreement_placeholder")}
          onChange={handleAgreementChange(send)}
          value=state.agreement
        />
      </div>
      <button
        key="agreements-editor__update-button"
        disabled={updateAgreementDisabled(state)}
        onClick={handleUpdateAgreement(
          state,
          send,
          kind,
          updatePrivacyPolicyCB,
          updateTermsAndConditionsCB,
          updateCodeOfConductCB,
        )}
        className="w-full btn btn-large btn-primary mt-4">
        {updateAgreementText(state.updating, kind) |> str}
      </button>
    </DisablingCover>
  </div>
}
