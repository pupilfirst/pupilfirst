@module("./images/set-new-password-icon.svg")
external resetPasswordIcon: string = "default"

let str = React.string

let t = I18n.t(~scope="components.UserSessionResetPassword")

let handleErrorCB = (setSaving, ()) => setSaving(_ => false)

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
let updatePassword = (authenticityToken, token, newPassword, confirmPassword, setSaving) => {
  let payload = Js.Dict.empty()
  Js.Dict.set(payload, "authenticity_token", authenticityToken |> Js.Json.string)
  Js.Dict.set(payload, "token", token |> Js.Json.string)
  Js.Dict.set(payload, "new_password", newPassword |> Js.Json.string)
  Js.Dict.set(payload, "confirm_password", confirmPassword |> Js.Json.string)

  let url = "/users/update_password"
  setSaving(_ => true)
  Api.create(url, payload, handleUpdatePasswordCB, handleErrorCB(setSaving))
}
let isDisabled = (saving, newPassword, confirmPassword) =>
  !validPassword(newPassword) || (newPassword != confirmPassword || saving)

let submitButtonText = (saving, newPassword, confirmPassword) =>
  switch (
    saving,
    newPassword == "",
    !validPassword(newPassword),
    confirmPassword == "",
    newPassword != confirmPassword,
  ) {
  | (true, _, _, _, _) => t("updating_password")
  | (_, true, _, _, _) => t("enter_new_password")
  | (_, _, true, _, _) => t("password_short")
  | (_, _, _, true, _) => t("confirm_your_password")
  | (_, _, _, _, true) => t("passwords_not_match")
  | _ => t("update_password")
  }
let renderUpdatePassword = (
  authenticityToken,
  token,
  newPassword,
  setNewPassword,
  confirmPassword,
  setConfirmPassword,
  saving,
  setSaving,
) => {
  let inputClasses = "appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-300 rounded py-2 px-4 text-sm bg-gray-50 hover:bg-gray-50 focus:outline-none focus:bg-white focus:border-primary-400"
  let labelClasses = "inline-block tracking-wide text-gray-900 text-xs font-semibold"
  <div className="pt-4 pb-5 md:px-9 items-center max-w-sm mx-auto">
    <div>
      <label className=labelClasses htmlFor="new-password"> {t("new_password") |> str} </label>
      <input
        className=inputClasses
        id="new-password"
        value=newPassword
        type_="password"
        maxLength=128
        placeholder={t("new_password_placeholder")}
        onChange={event => setNewPassword(ReactEvent.Form.target(event)["value"])}
      />
    </div>
    <div className="mt-4">
      <label className={labelClasses ++ " mt-2"} htmlFor="confirm password">
        {t("confirm_password") |> str}
      </label>
      <input
        className=inputClasses
        id="confirm password"
        value=confirmPassword
        type_="password"
        maxLength=128
        placeholder={t("confirm_password_placeholder")}
        onChange={event => setConfirmPassword(ReactEvent.Form.target(event)["value"])}
      />
    </div>
    <button
      disabled={isDisabled(saving, newPassword, confirmPassword)}
      onClick={_ =>
        updatePassword(authenticityToken, token, newPassword, confirmPassword, setSaving)}
      className="btn btn-success btn-large text-center w-full mt-4">
      <FaIcon classes={saving ? "fas fa-spinner fa-spin" : "fas fa-lock"} />
      <span className="ml-2">
        {submitButtonText(saving, newPassword, confirmPassword) |> str}
      </span>
    </button>
  </div>
}

@react.component
let make = (~token, ~authenticityToken) => {
  let (newPassword, setNewPassword) = React.useState(() => "")
  let (confirmPassword, setConfirmPassword) = React.useState(() => "")
  let (saving, setSaving) = React.useState(() => false)
  <div className="bg-gray-50 sm:py-10">
    <div className="container mx-auto max-w-lg px-4 py-6 sm:py-8 bg-white rounded-lg shadow">
      <img className="mx-auto h-20 sm:h-32" src=resetPasswordIcon />
      <div className="text-lg sm:text-2xl font-bold text-center mt-4">
        {t("set_new_password") |> str}
      </div>
      {renderUpdatePassword(
        authenticityToken,
        token,
        newPassword,
        setNewPassword,
        confirmPassword,
        setConfirmPassword,
        saving,
        setSaving,
      )}
    </div>
  </div>
}
