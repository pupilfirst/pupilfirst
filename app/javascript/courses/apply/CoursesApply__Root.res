@bs.module external emailSentIcon: string = "./images/email-sent-icon.svg"

let t = I18n.t(~scope="components.CoursesApply__Root")

let str = React.string

type views =
  | Apply
  | EmailSent

let setViewEmailSent = (setView, ()) => setView(_ => EmailSent)

let emailSentMessage = () =>
  <div>
    <img className="mx-auto w-44 sm:w-48" src=emailSentIcon />
    <div className="text-xl font-bold text-center mt-4"> {t("email_sent_message.title")->str} </div>
    <p className="mt-4 text-center"> {t("email_sent_message.description")->str} </p>
  </div>

@react.component
let make = (~courseName, ~courseId, ~email, ~name, ~privacyPolicy, ~termsAndConditions) => {
  let (view, setView) = React.useState(() => Apply)

  <div className="flex md:min-h-screen bg-gray-100 md:items-center md:justify-center">
    <div className="py-8 w-full">
      <div className="container mx-auto px-4 max-w-md">
        <div className="flex justify-center">
          <h4 className="font-bold text-center">
            {"Enroll to " ++ (courseName ++ " course") |> str}
          </h4>
        </div>
        <div className="mt-4 relative flex flex-col shadow-md rounded-lg overflow-hidden bg-white">
          <div className="">
            <div className="p-4 md:p-6">
              {switch view {
              | Apply =>
                <CoursesApply__Form
                  courseId
                  setViewEmailSent={setViewEmailSent(setView)}
                  email
                  name
                  termsAndConditions
                  privacyPolicy
                />
              | EmailSent => emailSentMessage()
              }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}
