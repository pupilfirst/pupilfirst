open SchoolsConfiguration__Types;

let str = React.string;

type emailAddress =
  | UnconfiguredFromAddress(string)
  | ConfiguredFromAddress(FromAddress.t);

type state = {emailAddress};

type action =
  | UpdateEmailAddress(string);

let reducer = (state, action) =>
  switch (action) {
  | UpdateEmailAddress(address) => {
      ...state,
      emailAddress: UnconfiguredFromAddress(address),
    }
  };

let computeInitialState = fromAddress => {
  let emailAddress =
    fromAddress->Belt.Option.mapWithDefault(UnconfiguredFromAddress(""), fa =>
      ConfiguredFromAddress(fa)
    );

  {emailAddress: emailAddress};
};

let emailAddressValue = emailAddress => {
  switch (emailAddress) {
  | UnconfiguredFromAddress(fromAddress) => fromAddress
  | ConfiguredFromAddress(fromAddress) => FromAddress.email(fromAddress)
  };
};

[@react.component]
let make = (~fromAddress) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, fromAddress, computeInitialState);

  let emailAddress = emailAddressValue(state.emailAddress);

  let emailAddressInvalid = EmailUtils.isInvalid(false, emailAddress);

  <div className="px-6 mt-6 max-w-3xl mx-auto">
    <div className="mt-5">
      <label
        className="inline-block tracking-wide text-sm font-semibold mb-2 leading-tight"
        htmlFor="title">
        {str("\"From\" Email Address")}
      </label>
      <HelpIcon className="ml-2">
        {str("This is the value of ")}
        <em> {str("from")} </em>
        {str(
           " that will be displayed in emails sent to users in your school. You will need to confirm this email address before it becomes active.",
         )}
      </HelpIcon>
      <input
        value=emailAddress
        onChange={event =>
          send(UpdateEmailAddress(ReactEvent.Form.target(event)##value))
        }
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
        id="title"
        type_="text"
        placeholder="noreply@pupilfirst.com"
      />
      <School__InputGroupError
        message="This doesn't look like a valid email address."
        active={emailAddressInvalid && StringUtils.present(emailAddress)}
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
