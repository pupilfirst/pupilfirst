@module("./images/set-new-password-icon.svg")
external resetPasswordIcon: string = "default"

let str = React.string

let t = I18n.t(~scope="components.UserSessionResetPassword")

type state = {
  authenticityToken: string,
  token: string,
  name: string,
  email: string,
  schoolName: string,
  newPassword: string,
  confirmPassword: string,
  saving: bool,
  newPasswordAnalysis: option<Zxcvbn.t>,
}

type action =
  | UpdateNewPassword(string)
  | UpdateConfirmPassword(string)
  | UpdateSaving(bool)

let reducer = (state, action) =>
  switch action {
  | UpdateNewPassword(newPassword) => {
      let newPasswordAnalysis = if Js.String2.length(newPassword) > 0 {
        Zxcvbn.make(
          ~password=newPassword,
          ~userInputs=Js.Array2.concat(
            Js.String2.split(state.name, " "),
            Js.String2.split(state.email, "@"),
          )->Js.Array2.concat([state.name, state.email, state.schoolName]),
        )->Some
      } else {
        None
      }
      {...state, newPassword: newPassword, newPasswordAnalysis: newPasswordAnalysis}
    }
  | UpdateConfirmPassword(confirmPassword) => {...state, confirmPassword: confirmPassword}
  | UpdateSaving(saving) => {...state, saving: saving}
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
let renderUpdatePassword = (state, send) => {
  let inputClasses = "appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-300 rounded py-2 px-4 text-sm bg-gray-50 hover:bg-gray-50 focus:outline-none focus:bg-white focus:border-primary-400"
  let labelClasses = "inline-block tracking-wide text-gray-900 text-xs font-semibold"
  <div className="pt-4 pb-5 md:px-9 items-center max-w-sm mx-auto">
    <div>
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
    {switch state.newPasswordAnalysis {
    | None => <div className="h-5 pt-1" />
    | Some(zxcvbn) =>
      <div className="h-5 pt-1">
        <div className="flex justify-between items-center">
          <p className="text-xs text-gray-400 font-inter"> {t("password_strength")->str} </p>
          <div className="flex items-center gap-1">
            <span
              className={`rounded-md h-1 bg-${Zxcvbn.score(zxcvbn) >= 0
                  ? Zxcvbn.color(zxcvbn)
                  : "gray"}-500 w-5`}
            />
            <span
              className={`rounded-md h-1 bg-${Zxcvbn.score(zxcvbn) > 1
                  ? Zxcvbn.color(zxcvbn)
                  : "gray"}-500 w-5`}
            />
            <span
              className={`rounded-md h-1 bg-${Zxcvbn.score(zxcvbn) > 2
                  ? Zxcvbn.color(zxcvbn)
                  : "gray"}-500 w-5`}
            />
            <span
              className={`rounded-md h-1 bg-${Zxcvbn.score(zxcvbn) > 3
                  ? Zxcvbn.color(zxcvbn)
                  : "gray"}-500 w-5`}
            />
            <span className="text-xs text-gray-400 w-12 text-right">
              {zxcvbn->Zxcvbn.label->str}
            </span>
          </div>
        </div>
        <div>
          <ul className="text-yellow-900 text-[10px]">
            {Js.Array2.length(zxcvbn->Zxcvbn.suggestions) > 0
              ? <li>
                  <PfIcon className="if i-info-light if-fw" /> {Zxcvbn.suggestions(zxcvbn)[0]->str}
                </li>
              : React.null}
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
      className="btn btn-success btn-large text-center w-full mt-4">
      <FaIcon classes={state.saving ? "fas fa-spinner fa-spin" : "fas fa-lock"} />
      <span className="ms-2"> {submitButtonText(state)->str} </span>
    </button>
  </div>
}

@react.component
let make = (~token, ~authenticityToken, ~name, ~email, ~schoolName) => {
  let initialState = {
    authenticityToken: authenticityToken,
    token: token,
    name: name,
    email: email,
    schoolName: schoolName,
    newPassword: "",
    confirmPassword: "",
    saving: false,
    newPasswordAnalysis: None,
  }

  let (state, send) = React.useReducer(reducer, initialState)

  <div className="bg-gray-50 sm:py-10">
    <div className="container mx-auto max-w-lg px-4 py-6 sm:py-8 bg-white rounded-lg shadow">
      <img className="mx-auto h-20 sm:h-32" src=resetPasswordIcon />
      <div className="text-lg sm:text-2xl font-bold text-center mt-4">
        {t("set_new_password") |> str}
      </div>
      {renderUpdatePassword(state, send)}
    </div>
  </div>
}
