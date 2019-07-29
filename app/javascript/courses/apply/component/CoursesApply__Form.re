[@bs.config {jsx: 3}];
let str = React.string;

module CreateApplicantQuery = [%graphql
  {|
   mutation($courseId: ID!, $email: String!) {
    createApplicant(courseId: $courseId, email: $email){
      success
     }
   }
 |}
];

let createApplicantQuery =
    (authenticityToken, courseId, email, setSaving, setViewEmailSent, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  CreateApplicantQuery.make(~courseId, ~email, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##createApplicant##success ?
         setViewEmailSent() : setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

let isInvalidEmail = email =>
  email |> EmailUtils.isInvalid(~allowBlank=false);
let saveDisabled = (email, saving) => isInvalidEmail(email) || saving;

let buttonText = (email, saving) =>
  switch (saving, email == "", isInvalidEmail(email)) {
  | (true, false | true, false | true) => "Saving"
  | (false, true, false | true) => "Enter your Email"
  | (false, false, true) => "Enter a valid Email"
  | (false, false, false) => "Apply"
  };

[@react.component]
let make = (~authenticityToken, ~courseName, ~courseId, ~setViewEmailSent) => {
  let (email, setEmail) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);
  <div className="flex flex-col">
    <h4 className="font-bold">
      {"Enroll to " ++ courseName ++ " course" |> str}
    </h4>
    <div className="w-full mt-4">
      <label
        className="inline-block tracking-wide text-gray-800 text-xs font-semibold">
        {"Email" |> str}
      </label>
      <input
        className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
        type_="text"
        value=email
        disabled=saving
        onChange={event => setEmail(ReactEvent.Form.target(event)##value)}
        placeholder="johnDoe@example.com"
      />
    </div>
    <button
      disabled={saveDisabled(email, saving)}
      onClick={
        createApplicantQuery(
          authenticityToken,
          courseId,
          email,
          setSaving,
          setViewEmailSent,
        )
      }
      className="btn btn-primary justify-center shadow-lg mt-6">
      {
        saving ?
          <FaIcon classes="fal fa-spinner-third fa-spin mr-2" /> :
          ReasonReact.null
      }
      <span> {buttonText(email, saving) |> str} </span>
    </button>
  </div>;
};
