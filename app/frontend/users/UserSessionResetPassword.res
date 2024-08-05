let str = React.string

let t = I18n.t(~scope="components.UserSessionResetPassword")
let ts = I18n.t(~scope="shared")

type state = {
  authenticityToken: string,
  token: string,
  name: string,
  email: string,
  newPassword: string,
  confirmPassword: string,
  saving: bool,
}

type action =
  | UpdateNewPassword(string)
  | UpdateConfirmPassword(string)
  | UpdateSaving(bool)

let reducer = (state, action) =>
  switch action {
  | UpdateNewPassword(newPassword) => {...state, newPassword}
  | UpdateConfirmPassword(confirmPassword) => {...state, confirmPassword}
  | UpdateSaving(saving) => {...state, saving}
  }

let handleUpdatePasswordCB = response => {
  let path =
    response
    |> {
      open Json.Decode
      field("path", nullable(string))
    }
    |> Js.Null.toOption
  switch path {
  | Some(path) => DomUtils.redirect(path)
  | None => ()
  }
}

let validPassword = password => {
  let length = password |> String.length
  length >= 8 && length < 128
}
let updatePassword = (state, send) => {
  let payload = Js.Dict.empty()
  Js.Dict.set(payload, "authenticity_token", state.authenticityToken |> Js.Json.string)
  Js.Dict.set(payload, "token", state.token |> Js.Json.string)
  Js.Dict.set(payload, "new_password", state.newPassword |> Js.Json.string)
  Js.Dict.set(payload, "confirm_password", state.confirmPassword |> Js.Json.string)

  let url = "/users/update_password"
  send(UpdateSaving(true))
  Api.create(url, payload, handleUpdatePasswordCB, _ => {
    send(UpdateSaving(false))
  })
}
let isDisabled = (saving, newPassword, confirmPassword) =>
  !validPassword(newPassword) || (newPassword != confirmPassword || saving)

let submitButtonText = state =>
  switch (
    state.saving,
    state.newPassword == "",
    !validPassword(state.newPassword),
    state.confirmPassword == "",
    state.newPassword != state.confirmPassword,
  ) {
  | (true, _, _, _, _) => t("updating_password")
  | (_, true, _, _, _) => t("enter_new_password")
  | (_, _, true, _, _) => t("password_short")
  | (_, _, _, true, _) => t("confirm_your_password")
  | (_, _, _, _, true) => t("passwords_not_match")
  | _ => t("update_password")
  }

@react.component
let make = (~token, ~authenticityToken, ~name, ~email, ~schoolName) => {
  let initialState = {
    authenticityToken,
    token,
    name,
    email,
    newPassword: "",
    confirmPassword: "",
    saving: false,
  }

  let (state, send) = React.useReducer(reducer, initialState)

  let inputClasses = "block w-full h-10 px-4 py-2 mt-1 text-sm text-gray-800 border border-gray-300 rounded appearance-none focus:outline-none focus:bg-white focus:border-primary-400"
  let labelClasses = "inline-block text-sm font-semibold tracking-wide text-gray-900"

  <div className="h-full py-10 bg-gray-50 md:py-24">
    <div className="container max-w-md p-6 mx-auto bg-white rounded-lg shadow sm:py-8">
      <div className="text-lg font-semibold sm:text-xl"> {t("set_new_password") |> str} </div>
      <div className="mt-6">
        <label className=labelClasses htmlFor="new-password"> {t("new_password") |> str} </label>
        <input
          className=inputClasses
          id="new-password"
          value=state.newPassword
          type_="password"
          maxLength=128
          placeholder={t("new_password_placeholder")}
          onChange={event => send(UpdateNewPassword(ReactEvent.Form.target(event)["value"]))}
        />
      </div>
      {switch Zxcvbn.make(
        ~password=state.newPassword,
        ~userInputs=[state.name, state.email, schoolName],
      ) {
      | None => <div className="h-5 pt-1" />
      | Some(zxcvbn) =>
        <div className="h-5 pt-1">
          <div className="flex items-center justify-between">
            <p className="text-xs text-gray-400 font-inter"> {ts("password_strength")->str} </p>
            <div className="flex items-center gap-1 mt-1">
              <span key="0" className="text-xs text-right text-gray-400 pe-2 rtl:text-left">
                {zxcvbn->Zxcvbn.label->str}
              </span>
              {[1, 2, 3, 4]
              ->Js.Array2.map(score =>
                <span
                  key={score->string_of_int}
                  className={`rounded-md h-1 ${zxcvbn->Zxcvbn.colorClass(score)} w-5`}
                />
              )
              ->React.array}
            </div>
          </div>
          <div>
            <ul className="text-yellow-900 text-[10px]">
              {switch zxcvbn->Zxcvbn.suggestions->ArrayUtils.getOpt(0) {
              | Some(suggestion) =>
                <li>
                  <PfIcon className="if i-info-light if-fw" />
                  {suggestion->str}
                </li>
              | None => React.null
              }}
            </ul>
          </div>
        </div>
      }}
      <div className="mt-4">
        <label className={labelClasses ++ " mt-2"} htmlFor="confirm password">
          {t("confirm_password") |> str}
        </label>
        <input
          className=inputClasses
          id="confirm password"
          value=state.confirmPassword
          type_="password"
          maxLength=128
          placeholder={t("confirm_password_placeholder")}
          onChange={event => send(UpdateConfirmPassword(ReactEvent.Form.target(event)["value"]))}
        />
      </div>
      <button
        disabled={isDisabled(state.saving, state.newPassword, state.confirmPassword)}
        onClick={_ => updatePassword(state, send)}
        className="w-full mt-4 text-center btn btn-success btn-large">
        <FaIcon classes={state.saving ? "fas fa-spinner fa-spin" : "fas fa-lock"} />
        <span className="ms-2"> {submitButtonText(state)->str} </span>
      </button>
    </div>
  </div>
}
