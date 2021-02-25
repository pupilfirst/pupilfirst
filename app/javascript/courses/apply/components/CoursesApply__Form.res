let str = React.string

module CreateApplicantQuery = %graphql(
  `
   mutation CreateApplicantMutation($courseId: ID!, $email: String!, $name: String!) {
    createApplicant(courseId: $courseId, email: $email, name: $name){
      success
     }
   }
 `
)

let createApplicant = (courseId, email, name, setSaving, setViewEmailSent, event) => {
  event |> ReactEvent.Mouse.preventDefault
  setSaving(_ => true)

  CreateApplicantQuery.make(~courseId, ~email, ~name, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["createApplicant"]["success"] ? setViewEmailSent() : setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> ignore
}

let isInvalidEmail = email => EmailUtils.isInvalid(false, email)
let saveDisabled = (email, name, termsAccepted, saving) =>
  isInvalidEmail(email) || (saving || name == "") || !termsAccepted

let buttonText = (email, name, saving) =>
  switch (saving, email == "", isInvalidEmail(email), name == "") {
  | (true, _, _, _) => "Saving"
  | (false, true, _, _) => "Enter your Email"
  | (false, false, true, _) => "Enter a valid Email"
  | (false, false, false, true) => "Enter your full name"
  | (false, false, false, false) => "Apply"
  }
let checkboxOnChange = (setTermsAccepted, event) =>
  ReactEvent.Form.target(event)["checked"]
    ? setTermsAccepted(_ => true)
    : setTermsAccepted(_ => false)

let checkboxLabel = (termsAndConditions, privacyPolicy) => {
  <div className="text-xs">
    {str("I agree to the ")}
    {termsAndConditions
      ? <a
          href="/agreements/terms-and-conditions" className="cursor-pointer hover:text-primary-500">
          {"Terms of Use" |> str}
        </a>
      : React.null}
    {ReactUtils.nullUnless(
      <span className="px-1"> {str("&")} </span>,
      termsAndConditions && privacyPolicy,
    )}
    {privacyPolicy
      ? <a href="/agreements/privacy-policy" className="cursor-pointer hover:text-primary-500">
          {"Privacy Policy" |> str}
        </a>
      : React.null}
  </div>
}

@react.component
let make = (~courseId, ~setViewEmailSent, ~email, ~name, ~termsAndConditions, ~privacyPolicy) => {
  let (email, setEmail) = React.useState(() => OptionUtils.default("", email))
  let (name, setName) = React.useState(() => OptionUtils.default("", name))
  let (termsAccepted, setTermsAccepted) = React.useState(() =>
    !(termsAndConditions || privacyPolicy)
  )
  let (saving, setSaving) = React.useState(() => false)
  <div className="flex flex-col">
    <div className="w-full">
      <div className="mt-4">
        <label htmlFor="email" className="inline-block tracking-wide text-xs font-semibold">
          {"Email"->str}
        </label>
        <input
          className="appearance-none h-10 mt-1 block w-full border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
          type_="text"
          id="email"
          maxLength=128
          value=email
          disabled=saving
          onChange={event => setEmail(ReactEvent.Form.target(event)["value"])}
          placeholder="johnDoe@example.com"
        />
      </div>
      <div className="mt-4">
        <label htmlFor="name" className="inline-block tracking-wide text-xs font-semibold">
          {"Name"->str}
        </label>
        <input
          className="appearance-none h-10 mt-1 block w-full border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
          type_="text"
          id="name"
          value=name
          maxLength=128
          disabled=saving
          onChange={event => setName(ReactEvent.Form.target(event)["value"])}
          placeholder="John Doe"
        />
      </div>
      <div className="mt-4">
        <Checkbox
          id={"terms-accepted"}
          label={checkboxLabel(termsAndConditions, privacyPolicy)}
          onChange={checkboxOnChange(setTermsAccepted)}
          checked=termsAccepted
        />
      </div>
    </div>
    <button
      disabled={saveDisabled(email, name, termsAccepted, saving)}
      onClick={createApplicant(courseId, email, name, setSaving, setViewEmailSent)}
      className="btn btn-success btn-large text-center w-full mt-6">
      {saving ? <FaIcon classes="fas fa-spinner fa-spin mr-2" /> : ReasonReact.null}
      <span> {buttonText(email, name, saving) |> str} </span>
    </button>
  </div>
}
