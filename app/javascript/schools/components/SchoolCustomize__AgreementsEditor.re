open SchoolCustomize__Types;

[%bs.raw {|require("./SchoolCustomize__AgreementsEditor.css")|}];

let str = ReasonReact.string;

type kind =
  | PrivacyPolicy
  | TermsOfUse;

type action =
  | UpdateAgreement(string)
  | BeginUpdate
  | ErrorOccured
  | DoneUpdating;

type state = {
  agreement: string,
  updating: bool,
  formDirty: bool,
};

let component =
  ReasonReact.reducerComponent("SchoolCustomize__AgreementsEditor");

let kindToString = kind =>
  switch (kind) {
  | PrivacyPolicy => "Privacy Policy"
  | TermsOfUse => "Terms of Use"
  };

let kindToKey = kind =>
  switch (kind) {
  | PrivacyPolicy => "privacy_policy"
  | TermsOfUse => "terms_of_use"
  };

let handleAgreementChange = (send, event) => {
  let agreement = ReactEvent.Form.target(event)##value;
  send(UpdateAgreement(agreement));
};

let updateAgreementText = (updating, kind) =>
  updating ? "Updating..." : "Update " ++ kindToString(kind);

module UpdateSchoolStringQuery = [%graphql
  {|
   mutation($key: String!, $value: String!) {
     updateSchoolString(key: $key, value: $value) {
       errors
     }
   }
  |}
];

module UpdateSchoolStringErrorHandler =
  GraphqlErrorHandler.Make(SchoolCustomize__UpdateSchoolStringError);

let handleUpdateAgreement =
    (
      state,
      send,
      kind,
      authenticityToken,
      updatePrivacyPolicyCB,
      updateTermsOfUseCB,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(BeginUpdate);

  UpdateSchoolStringQuery.make(
    ~key=kind |> kindToKey,
    ~value=state.agreement,
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(result =>
       switch (result##updateSchoolString##errors) {
       | [||] =>
         Notification.success(
           "Done!",
           kindToString(kind) ++ " has been updated.",
         );
         switch (kind) {
         | PrivacyPolicy => updatePrivacyPolicyCB(state.agreement)
         | TermsOfUse => updateTermsOfUseCB(state.agreement)
         };
         send(DoneUpdating);
         Js.Promise.resolve();
       | errors =>
         Js.Promise.reject(UpdateSchoolStringErrorHandler.Errors(errors))
       }
     )
  |> UpdateSchoolStringErrorHandler.catch(() => send(ErrorOccured))
  |> ignore;
  ();
};

let updateAgreementDisabled = state => !state.formDirty;

let make =
    (
      ~kind,
      ~customizations,
      ~authenticityToken,
      ~updatePrivacyPolicyCB,
      ~updateTermsOfUseCB,
      _children,
    ) => {
  ...component,
  initialState: () => {
    let agreement =
      switch (kind) {
      | PrivacyPolicy => customizations |> Customizations.privacyPolicy
      | TermsOfUse => customizations |> Customizations.termsOfUse
      };

    {
      agreement:
        switch (agreement) {
        | Some(agreement) => agreement
        | None => ""
        },
      updating: false,
      formDirty: false,
    };
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateAgreement(agreement) =>
      ReasonReact.Update({...state, agreement, formDirty: true})
    | BeginUpdate => ReasonReact.Update({...state, updating: true})
    | ErrorOccured => ReasonReact.Update({...state, updating: false})
    | DoneUpdating =>
      ReasonReact.Update({...state, updating: false, formDirty: false})
    },
  render: ({state, send}) =>
    <div className="mx-8 pt-8 flex flex-col agreements-editor__container">
      <h5 className="uppercase text-center border-b border-grey-light pb-2">
        {"Manage " ++ (kind |> kindToString) |> str}
      </h5>
      <SchoolAdmin__DisablingCover
        disabled={state.updating} containerClasses="flex flex-col flex-1">
        <div
          key="agreements-editor__input-group"
          className="mt-3 flex flex-col flex-1">
          <label
            className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
            htmlFor="agreements-editor__value">
            {"Body of Agreement (Markdown)" |> str}
          </label>
          <textarea
            maxLength=10000
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey flex-1"
            id="agreements-editor__value"
            placeholder="Leave the agreement body empty to hide the footer link."
            onChange={handleAgreementChange(send)}
            value={state.agreement}
          />
        </div>
        <button
          key="agreements-editor__update-button"
          disabled={updateAgreementDisabled(state)}
          onClick={
            handleUpdateAgreement(
              state,
              send,
              kind,
              authenticityToken,
              updatePrivacyPolicyCB,
              updateTermsOfUseCB,
            )
          }
          className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
          {updateAgreementText(state.updating, kind) |> str}
        </button>
      </SchoolAdmin__DisablingCover>
    </div>,
};