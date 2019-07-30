[@bs.config {jsx: 3}];
[%bs.raw {|require("./apply.css")|}];
let emailSentIcon: string = [%raw "require('./images/email-sent-icon.svg')"];
let str = React.string;

type views =
  | Apply
  | EmailSent;

let setViewEmailSent = (setView, ()) => setView(_ => EmailSent);

let renderEmailSent = () =>
  <div className="max-w-sm mx-auto">
    <img src=emailSentIcon />
    <div className="text-lg sm:text-2xl font-bold text-center mt-4">
      {"We've sent you a magic link!" |> str}
    </div>
    <p className="mt-4 text-center">
      {
        "It should reach you in less than a minute. Click the link in the email to sign up"
        |> str
      }
    </p>
  </div>;

[@react.component]
let make = (~authenticityToken, ~courseName, ~courseDescription, ~courseId) => {
  let (view, setView) = React.useState(() => Apply);

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
        <div className="md:w-1/2">
          <div className="p-4 pt-5 md:px-14 md:py-20 lg:px-28 lg:py-32">
            {
              switch (view) {
              | Apply =>
                <CoursesApply__Form
                  authenticityToken
                  courseName
                  courseId
                  setViewEmailSent={setViewEmailSent(setView)}
                />
              | EmailSent => renderEmailSent()
              }
            }
          </div>
        </div>
      </div>
    </div>
  </div>;
};
