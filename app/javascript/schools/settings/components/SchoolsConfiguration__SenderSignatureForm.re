open SchoolsConfiguration__Types;

let str = React.string;

type sender =
  | Unconfigured(string, string)
  | Configured(EmailSenderSignature.t);

type state = {
  sender,
  saving: bool,
};

type action =
  | UpdateEmailAddress(string)
  | UpdateName(string)
  | BeginSaving
  | FailSaving
  | FinishSaving(EmailSenderSignature.t);

let reducer = (state, action) =>
  switch (action) {
  | UpdateEmailAddress(address) => {
      ...state,
      sender:
        switch (state.sender) {
        | Unconfigured(name, _) => Unconfigured(name, address)
        | Configured(emailSenderSignature) =>
          Configured(emailSenderSignature)
        },
    }
  | UpdateName(name) => {
      ...state,
      sender:
        switch (state.sender) {
        | Unconfigured(_, address) => Unconfigured(name, address)
        | Configured(emailSenderSignature) =>
          Configured(emailSenderSignature)
        },
    }
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | FinishSaving(emailSenderSignature) => {
      sender: Configured(emailSenderSignature),
      saving: false,
    }
  };

let computeInitialState = emailSenderSignature => {
  let sender =
    emailSenderSignature->Belt.Option.mapWithDefault(Unconfigured("", ""), fa =>
      Configured(fa)
    );

  {sender, saving: false};
};

let senderEmailAddress = sender => {
  switch (sender) {
  | Unconfigured(_, address) => address
  | Configured(emailSenderSignature) =>
    EmailSenderSignature.email(emailSenderSignature)
  };
};

let senderName = sender =>
  switch (sender) {
  | Unconfigured(name, _) => name
  | Configured(emailSenderSignature) =>
    EmailSenderSignature.name(emailSenderSignature)
  };

module AddEmailSenderSignatureMutation = [%graphql
  {|
  mutation AddEmailSenderSignatureMutation($name: String!, $emailAddress: String!) {
    addEmailSenderSignature(name: $name, emailAddress: $emailAddress) {
      emailSenderSignature {
        name
        email
        confirmedAt
        lastCheckedAt
      }
    }
  }
  |}
];

let addEmailSenderSignature = ({sender}, send, _event) => {
  send(BeginSaving);

  AddEmailSenderSignatureMutation.make(
    ~name=senderName(sender),
    ~emailAddress=senderEmailAddress(sender),
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       switch (response##addEmailSenderSignature##emailSenderSignature) {
       | Some(signature) =>
         let emailSenderSignature =
           EmailSenderSignature.fromJsObject(signature);
         send(FinishSaving(emailSenderSignature));
       | None => send(FailSaving)
       };
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(error => {
       Js.log(error);
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~schoolName, ~emailSenderSignature) => {
  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      emailSenderSignature,
      computeInitialState,
    );

  let senderAddress = senderEmailAddress(state.sender);
  let senderName = senderName(state.sender);
  let senderAddressInvalid = EmailUtils.isInvalid(false, senderAddress);

  let inputsDisabled =
    switch (state.sender) {
    | Unconfigured(_) => false
    | Configured(_) => true
    };

  <div>
    <div className="mt-5">
      <div>
        <h4 className="inline-block"> {str("Email Sender Signature")} </h4>
        <HelpIcon className="ml-2">
          {str("This is the value of ")}
          <em> {str("from")} </em>
          {str(
             " that will be displayed in emails sent to users in your school. You will need to confirm this email address before it becomes active.",
           )}
        </HelpIcon>
      </div>
      <label
        className="inline-block tracking-wide text-sm font-semibold mt-2 leading-tight"
        htmlFor="title">
        {str("Name")}
      </label>
      <input
        disabled=inputsDisabled
        value=senderName
        onChange={event =>
          send(UpdateName(ReactEvent.Form.target(event)##value))
        }
        className="mt-1 appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
        id="title"
        type_="text"
        maxLength=100
        placeholder=schoolName
      />
      <label
        className="inline-block tracking-wide text-sm font-semibold mt-2 leading-tight"
        htmlFor="title">
        {str("Email Address")}
      </label>
      <input
        disabled=inputsDisabled
        value=senderAddress
        onChange={event =>
          send(UpdateEmailAddress(ReactEvent.Form.target(event)##value))
        }
        className="mt-1 appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
        id="title"
        type_="email"
        placeholder="noreply@pupilfirst.com"
      />
      <School__InputGroupError
        message="This doesn't look like a valid email address."
        active={senderAddressInvalid && StringUtils.present(senderAddress)}
      />
    </div>
    <div className="mt-3 w-auto">
      <button
        onClick={addEmailSenderSignature(state, send)}
        disabled=false
        className="w-full btn btn-large btn-primary">
        {"Send Confirmation Email" |> str}
      </button>
    </div>
  </div>;
};
