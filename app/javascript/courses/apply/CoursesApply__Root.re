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
    (~authenticityToken, ~courseName, ~courseId, ~thumbnailUrl, ~email, ~name) => {
  let (view, setView) = React.useState(() => Apply);

  <div className="bg-gray-100 py-8 w-full">
    <div className="container mx-auto px-3 max-w-lg">
      <div
        className="relative flex flex-col shadow-xl rounded-lg overflow-hidden bg-white border">
        <div className="flex flex-col text-gray-900 bg-gray-200 text-white">
          <div className="relative pb-1/2 bg-primary-900">
            {switch (thumbnailUrl) {
             | Some(src) =>
               <img className="absolute h-full w-full object-cover" src />
             | None =>
               <div
                 className="course-apply__cover-default absolute h-full w-full svg-bg-pattern-1"
               />
             }}
          </div>
        </div>
        <div className="">
          <div className="p-4 pt-5 md:px-16 md:py-12 md:pt-10">
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
      <div className="text-center mt-4 text-gray-700">
        <a
          href="#"
          className="text-xs cursor-pointer pr-4 border-r border-gray-400 hover:text-primary-500">
          {"terms-of-use" |> str}
        </a>
        <a
          href="#"
          className="text-xs cursor-pointer pl-4 hover:text-primary-500">
          {"privacy-policy" |> str}
        </a>
      </div>
    </div>
  </div>;
};
