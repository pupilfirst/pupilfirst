[@bs.config {jsx: 3}];
[%bs.raw {|require("./apply.css")|}];
let str = React.string;

type views =
  | Apply
  | EmailSent
  | Enroll;

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
    (authenticityToken, courseId, email, setSaving, setView, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  CreateApplicantQuery.make(~courseId, ~email, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##createApplicant##success ?
         setView(_ => EmailSent) : setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

let renderApply =
    (
      courseId,
      courseName,
      email,
      setEmail,
      saving,
      setSaving,
      setView,
      authenticityToken,
    ) =>
  <div className="flex flex-col">
    <h4 className="font-bold">
      {"Enroll to" ++ courseName ++ " course" |> str}
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
      disabled=saving
      onClick={
        createApplicantQuery(
          authenticityToken,
          courseId,
          email,
          setSaving,
          setView,
        )
      }
      className="btn btn-primary justify-center shadow-lg mt-6">
      {
        saving ?
          <FaIcon classes="fal fa-spinner-third fa-spin mr-2" /> :
          ReasonReact.null
      }
      <span> {(saving ? "Applying" : "Apply") |> str} </span>
    </button>
  </div>;

let renderEmailSent = () =>
  <div className="max-w-sm mx-auto">
    <p className="mt-4 text-center">
      {
        "It should reach you in less than a minute. Click the link in the email, and you'll be signed in."
        |> str
      }
    </p>
  </div>;

[@react.component]
let make = (~authenticityToken, ~courseName, ~courseDescription, ~courseId) => {
  let (view, setView) = React.useState(() => Apply);
  let (email, setEmail) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);

  <div className="bg-gray-100 py-8">
    <div className="container mx-auto px-3 max-w-6xl">
      <div
        className="flex flex-col md:flex-row shadow-xl rounded-lg overflow-hidden bg-white border">
        <div
          className="md:w-1/2 enroll-left__container svg-bg-pattern-4 relative p-4 pt-5 md:px-14 md:py-20 lg:px-28 lg:py-32 text-white">
          <div className="">
            <h1 className="font-bold"> {courseName |> str} </h1>
            <p> {courseDescription |> str} </p>
          </div>
        </div>
        <div className="md:w-1/2 p-4 pt-5 md:px-14 md:py-20 lg:px-28 lg:py-32">
          {
            switch (view) {
            | Apply =>
              renderApply(
                courseId,
                courseName,
                email,
                setEmail,
                saving,
                setSaving,
                setView,
                authenticityToken,
              )
            | EmailSent => renderEmailSent()
            | Enroll => React.null
            }
          }
        </div>
      </div>
    </div>
  </div>;
};
