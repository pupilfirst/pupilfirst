[@bs.config {jsx: 3}];
[%bs.raw {|require("../shared/background_patterns.css")|}];
[%bs.raw {|require("./CoursesApply__Root.css")|}];
let emailSentIcon: string = [%raw "require('./images/email-sent-icon.svg')"];
let str = React.string;

type views =
  | Apply
  | EmailSent;

let setViewEmailSent = (setView, ()) => setView(_ => EmailSent);

let emailSentMessage = () =>
  <div className="max-w-sm mx-auto">
    <img className="mx-auto w-44 sm:w-48" src=emailSentIcon />
    <div className="text-lg sm:text-2xl font-bold text-center mt-4">
      {"We've sent you a magic link!" |> str}
    </div>
    <p className="mt-4 text-center">
      {"It should reach you in less than a minute. Click the link in the email to sign up"
       |> str}
    </p>
  </div>;

[@react.component]
let make =
    (
      ~authenticityToken,
      ~courseName,
      ~courseDescription,
      ~courseId,
      ~thumbnailUrl,
      ~email,
      ~name,
    ) => {
  let (view, setView) = React.useState(() => Apply);

  <div className="bg-gray-100 py-8">
    <div className="container mx-auto px-3 max-w-6xl">
      <div
        className="course-apply flex flex-col md:flex-row shadow-xl rounded-lg overflow-hidden bg-white border">
        <div
          className="md:w-1/2 flex flex-col bg-primary-900 relative text-white">
          <div className="hidden md:block relative h-1/2 bg-primary-900">
            {switch (thumbnailUrl) {
             | Some(src) =>
               <img className="absolute h-full w-full object-cover" src />
             | None =>
               <div
                 className="student-course__cover-default absolute h-full w-full svg-bg-pattern-1"
               />
             }}
          </div>
          <div className="h-auto md:h-1/2 md:border-t border-primary-500">
            <div
              className="flex flex-col justify-center h-full px-4 py-6 md:px-14 xl:px-24">
              <h1 className="text-xl md:text-3xl font-bold leading-tight">
                {courseName |> str}
              </h1>
              <p className="text-sm md:text-base mt-2">
                {courseDescription |> str}
              </p>
            </div>
          </div>
        </div>
        <div className="md:w-1/2">
          <div className="p-4 pt-5 md:px-14 md:py-20 lg:px-28 lg:py-32">
            {switch (view) {
             | Apply =>
               <CoursesApply__Form
                 authenticityToken
                 courseName
                 courseId
                 setViewEmailSent={setViewEmailSent(setView)}
                 email
                 name
               />
             | EmailSent => emailSentMessage()
             }}
          </div>
        </div>
      </div>
    </div>
  </div>;
};
