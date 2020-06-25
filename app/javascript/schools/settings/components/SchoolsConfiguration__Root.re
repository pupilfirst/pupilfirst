open SchoolsConfiguration__Types;

let str = React.string;

type emailSender =
  | UnconfiguredEmailSenderSignature(string, string)
  | ConfiguredEmailSenderSignature(EmailSenderSignature.t);

type state = {emailSender};

type action =
  | UpdateSenderAddress(string)
  | UpdateSenderName(string);

let reducer = (state, action) =>
  switch (action) {
  | UpdateSenderAddress(address) => {
      ...state,
      emailSender:
        switch (state.emailSender) {
        | UnconfiguredEmailSenderSignature(name, _) =>
          UnconfiguredEmailSenderSignature(name, address)
        | ConfiguredEmailSenderSignature(emailSenderSignature) =>
          ConfiguredEmailSenderSignature(emailSenderSignature)
        },
    }
  | UpdateSenderName(name) => {
      ...state,
      emailSender:
        switch (state.emailSender) {
        | UnconfiguredEmailSenderSignature(_, address) =>
          UnconfiguredEmailSenderSignature(name, address)
        | ConfiguredEmailSenderSignature(emailSenderSignature) =>
          ConfiguredEmailSenderSignature(emailSenderSignature)
        },
    }
  };

let computeInitialState = emailSenderSignature => {
  let emailSender =
    emailSenderSignature->Belt.Option.mapWithDefault(
      UnconfiguredEmailSenderSignature("", ""), fa =>
      ConfiguredEmailSenderSignature(fa)
    );

  {emailSender: emailSender};
};

let senderAddressValue = emailSender => {
  switch (emailSender) {
  | UnconfiguredEmailSenderSignature(_, address) => address
  | ConfiguredEmailSenderSignature(emailSenderSignature) =>
    EmailSenderSignature.email(emailSenderSignature)
  };
};

let senderNameValue = emailSender => {
  switch (emailSender) {
  | UnconfiguredEmailSenderSignature(name, _) => name
  | ConfiguredEmailSenderSignature(emailSenderSignature) =>
    EmailSenderSignature.name(emailSenderSignature)
  };
};

let emailSenderDisabled = emailSender => {
  switch (emailSender) {
  | UnconfiguredEmailSenderSignature(_) => false
  | ConfiguredEmailSenderSignature(_) => true
  };
};

[@react.component]
let make = (~schoolName, ~emailSenderSignature) => {
  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      emailSenderSignature,
      computeInitialState,
    );

  let senderAddress = senderAddressValue(state.emailSender);
  let senderName = senderNameValue(state.emailSender);

  let senderAddressInvalid = EmailUtils.isInvalid(false, senderAddress);

  <div className="px-6 mt-6 max-w-3xl mx-auto">
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
        className="inline-block tracking-wide text-sm font-semibold mt-1 mb-2 leading-tight"
        htmlFor="title">
        {str("Name")}
      </label>
      <input
        disabled={emailSenderDisabled(state.emailSender)}
        value=senderName
        onChange={event =>
          send(UpdateSenderName(ReactEvent.Form.target(event)##value))
        }
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
        id="title"
        type_="text"
        placeholder=schoolName
      />
      <label
        className="inline-block tracking-wide text-sm font-semibold mt-1 mb-2 leading-tight"
        htmlFor="title">
        {str("Email Address")}
      </label>
      <input
        disabled={emailSenderDisabled(state.emailSender)}
        value=senderAddress
        onChange={event =>
          send(UpdateSenderAddress(ReactEvent.Form.target(event)##value))
        }
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
        id="title"
        type_="text"
        placeholder="noreply@pupilfirst.com"
      />
      <School__InputGroupError
        message="This doesn't look like a valid email address."
        active={senderAddressInvalid && StringUtils.present(senderAddress)}
      />
    </div>
    <div className="mt-3 w-auto">
      <button disabled=false className="w-full btn btn-large btn-primary">
        {"Send Confirmation Email" |> str}
      </button>
    </div>
    <hr className="mt-4" />
  </div>;
};
