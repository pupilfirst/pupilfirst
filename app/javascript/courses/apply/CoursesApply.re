[@bs.config {jsx: 3}];
[%bs.raw {|require("./apply.css")|}];
let emailSentIcon: string = [%raw "require('./images/email-sent-icon.svg')"];
let str = React.string;

module Applicant = CoursesApply__Applicant;

type views =
  | Apply
  | EmailSent
  | Enroll(Applicant.t);
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

let tabClasses = bool =>
  "w-1/3 text-center border border-t-0 py-2 " ++ (bool ? "bg-gray-300" : "");

let renderTabs = view =>
  <div className="flex justify-between">
    <div
      className={
        tabClasses(view == Apply || view != Apply && view != EmailSent)
      }>
      {"1: Add your Email" |> str}
    </div>
    <div className={tabClasses(view != Apply && view != EmailSent)}>
      {"2: Verify your Email" |> str}
    </div>
    <div className={tabClasses(false)}> {"3: Start Learning" |> str} </div>
  </div>;

let computeView = applicant =>
  switch (applicant) {
  | Some(applicant) => Enroll(applicant)
  | None => Apply
  };

[@react.component]
let make =
    (
      ~authenticityToken,
      ~courseName,
      ~courseDescription,
      ~courseId,
      ~applicant,
    ) => {
  let (view, setView) =
    React.useState(() =>
      switch (applicant) {
      | Some(applicant) => Enroll(applicant)
      | None => Apply
      }
    );

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
          {renderTabs(view)}
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
              | Enroll(applicant) =>
                <CoursesApply__Enroll authenticityToken courseName applicant />
              }
            }
          </div>
        </div>
      </div>
    </div>
  </div>;
};
