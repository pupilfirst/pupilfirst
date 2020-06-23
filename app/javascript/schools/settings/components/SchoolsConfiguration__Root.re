let str = React.string;

[@react.component]
let make = (~fromAddress) =>
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
           " that will be displayed in emails sent to users in your school. You will need to confirm this emaila address before it is accepted.",
         )}
      </HelpIcon>
      <input
        value=""
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
        id="title"
        type_="text"
        placeholder="noreply@pupilfirst.com"
      />
      <School__InputGroupError
        message="This doesn't look like a valid email address."
        active=true
      />
    </div>
    <div className="my-5 w-auto">
      <button disabled=false className="w-full btn btn-large btn-primary">
        {"Save Configuration" |> str}
      </button>
    </div>
  </div>;
