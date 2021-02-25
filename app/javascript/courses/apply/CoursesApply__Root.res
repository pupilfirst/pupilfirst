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

  <div className="flex min-h-screen bg-gray-100 items-center justify-center">
    <div className="py-8 w-full">
      <div className="container mx-auto px-3 max-w-lg">
        <div className="flex justify-center">
          <h4 className="font-bold"> {"Enroll to " ++ (courseName ++ " course") |> str} </h4>
        </div>
        <div
          className="mt-4 relative flex flex-col shadow-xl rounded-lg overflow-hidden bg-white border">
          <div className="">
            <div className="p-4 pt-5 md:px-12 md:py-12 md:pt-10">
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
