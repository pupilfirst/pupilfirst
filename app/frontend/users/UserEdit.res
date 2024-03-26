let str = React.string
open ThemeSwitch

@val @scope(("window", "pupilfirst"))
external maxUploadFileSize: int = "maxUploadFileSize"

let t = I18n.t(~scope="components.UserEdit")
let ts = I18n.t(~scope="shared")

type state = {
  name: string,
  preferredName: string,
  about: string,
  locale: string,
  email: string,
  disableEmailInput: bool,
  avatarUrl: option<string>,
  currentPassword: string,
  newPassword: string,
  confirmPassword: string,
  passwordForEmailChange: string,
  showEmailChangePasswordConfirm: bool,
  dailyDigest: bool,
  themePreference: string,
  emailForAccountDeletion: string,
  showDeleteAccountForm: bool,
  hasCurrentPassword: bool,
  deletingAccount: bool,
  avatarUploadError: option<string>,
  initiatePasswordReset: bool,
  saving: bool,
  dirty: bool,
}

type action =
  | UpdateName(string)
  | UpdatePreferredName(string)
  | UpdateAbout(string)
  | UpdateEmail(string)
  | SetDisableUpdateEmail(bool)
  | UpdateLocale(string)
  | UpdateCurrentPassword(string)
  | UpdateNewPassword(string)
  | UpdateNewPassWordConfirm(string)
  | UpdateEmailForDeletion(string)
  | UpdateDailyDigest(bool)
  | UpdateThemePreference(string)
  | UpdateAvatarUrl(option<string>)
  | ChangeDeleteAccountFormVisibility(bool)
  | SetAvatarUploadError(option<string>)
  | StartSaving
  | ResetSaving
  | FinishSaving(bool)
  | StartDeletingAccount
  | FinishAccountDeletion
  | UpdateEmailAndDisableInput(string)
  | ShowEmailChangePasswordConfirm
  | UpdatePasswordForEmailChange(string)
  | InitiatePasswordReset
  | FinishPasswordReset

let reducer = (state, action) =>
  switch action {
  | UpdateName(name) => {...state, name, dirty: true}
  | UpdatePreferredName(preferredName) => {...state, preferredName, dirty: true}
  | UpdateAbout(about) => {...state, about, dirty: true}
  | UpdateEmail(email) => {...state, email, dirty: true}
  | SetDisableUpdateEmail(disableEmailInput) => {
      ...state,
      disableEmailInput,
    }
  | UpdateLocale(locale) => {...state, locale, dirty: true}
  | UpdateCurrentPassword(currentPassword) => {
      ...state,
      currentPassword,
      dirty: true,
    }
  | UpdateNewPassword(newPassword) => {
      ...state,
      newPassword,
      dirty: true,
    }
  | UpdateNewPassWordConfirm(confirmPassword) => {
      ...state,
      confirmPassword,
      dirty: true,
    }
  | UpdateEmailForDeletion(emailForAccountDeletion) => {
      ...state,
      emailForAccountDeletion,
    }
  | UpdateDailyDigest(dailyDigest) => {...state, dailyDigest, dirty: true}
  | UpdateThemePreference(themePreference) => {
      Dom.Storage2.setItem(Dom.Storage2.localStorage, "themePreference", themePreference)
      setThemeBasedOnPreference()
      {...state, themePreference}
    }
  | StartSaving => {...state, saving: true}
  | ChangeDeleteAccountFormVisibility(showDeleteAccountForm) => {
      ...state,
      showDeleteAccountForm,
      emailForAccountDeletion: "",
    }
  | SetAvatarUploadError(avatarUploadError) => {...state, avatarUploadError}
  | UpdateAvatarUrl(avatarUrl) => {
      ...state,
      avatarUrl,
      avatarUploadError: None,
    }
  | FinishSaving(hasCurrentPassword) => {
      ...state,
      saving: false,
      dirty: false,
      currentPassword: "",
      newPassword: "",
      confirmPassword: "",
      hasCurrentPassword,
    }
  | ResetSaving => {...state, saving: false}
  | StartDeletingAccount => {...state, deletingAccount: true}
  | FinishAccountDeletion => {
      ...state,
      showDeleteAccountForm: false,
      deletingAccount: false,
      emailForAccountDeletion: "",
    }
  | UpdateEmailAndDisableInput(email) => {
      ...state,
      email,
      dirty: true,
      disableEmailInput: true,
      showEmailChangePasswordConfirm: false,
      passwordForEmailChange: "",
    }
  | UpdatePasswordForEmailChange(input) => {
      ...state,
      passwordForEmailChange: input,
    }
  | ShowEmailChangePasswordConfirm => {
      ...state,
      showEmailChangePasswordConfirm: true,
    }
  | InitiatePasswordReset => {
      ...state,
      initiatePasswordReset: true,
    }
  | FinishPasswordReset => {
      ...state,
      initiatePasswordReset: false,
    }
  }

module UpdateUserQuery = %graphql(`
  mutation UpdateUserMutation($name: String!, $preferredName: String, $about: String, $locale: String!, $currentPassword: String, $newPassword: String, $confirmPassword: String, $dailyDigest: Boolean!) {
    updateUser(name: $name, preferredName: $preferredName, about: $about, locale: $locale, currentPassword: $currentPassword, newPassword: $newPassword, confirmNewPassword: $confirmPassword, dailyDigest: $dailyDigest) {
      success
    }
  }
`)

module InitiateAccountDeletionQuery = %graphql(`
   mutation InitiateAccountDeletionMutation($email: String! ) {
     initiateAccountDeletion(email: $email ) {
        success
       }
     }
   `)

module SendEmailUpdateTokenQuery = %graphql(`
   mutation SendUpdateEmailToken($newEmail: String!, $password: String! ) {
     sendUpdateEmailToken(newEmail: $newEmail, password: $password ) {
        success
       }
     }
   `)

module InitiatePasswordResetQuery = %graphql(`
   mutation InitiatePasswordResetMutation($email: String! ) {
     initiatePasswordReset(email: $email ) {
        success
       }
     }
   `)

let uploadAvatar = (send, formData) => {
  open Json.Decode
  Api.sendFormData(
    "/user/upload_avatar",
    formData,
    json => {
      Notification.success(ts("notifications.done_exclamation"), t("avatar_uploaded_notification"))
      let avatarUrl = json |> field("avatarUrl", string)
      send(UpdateAvatarUrl(Some(avatarUrl)))
    },
    () => send(SetAvatarUploadError(Some(t("upload_failed")))),
  )
}

let updateEmail = (send, email, newEmail, password) => {
  send(SetDisableUpdateEmail(false))

  SendEmailUpdateTokenQuery.fetch({newEmail, password})
  |> Js.Promise.then_(_ => {
    send(UpdateEmailAndDisableInput(newEmail))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(UpdateEmailAndDisableInput(email))
    Js.Promise.resolve()
  })
  |> ignore
}

let submitAvatarForm = (send, formId) => {
  let element = ReactDOM.querySelector("#" ++ formId)

  switch element {
  | Some(element) => DomUtils.FormData.create(element) |> uploadAvatar(send)
  | None => Rollbar.error("Could not find form to upload file for content block: " ++ formId)
  }
}

let handleAvatarInputChange = (send, formId, event) => {
  event->ReactEvent.Form.preventDefault

  switch ReactEvent.Form.target(event)["files"] {
  | [] => ()
  | files =>
    let file = files[0]

    let isInvalidImageFile =
      file["size"] > maxUploadFileSize ||
        switch file["_type"] {
        | "image/jpeg"
        | "image/gif"
        | "image/png" => false
        | _ => true
        }

    let error = isInvalidImageFile ? Some(t("select_image_limit")) : None

    switch error {
    | Some(error) => send(SetAvatarUploadError(Some(error)))
    | None => submitAvatarForm(send, formId)
    }
  }
}

let initiatePasswordReset = (send, email) => {
  send(InitiatePasswordReset)

  InitiatePasswordResetQuery.fetch({email: email})
  |> Js.Promise.then_(_ => {
    send(FinishPasswordReset)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(FinishPasswordReset)
    Js.Promise.resolve()
  })
  |> ignore
}

let updateUser = (state, send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send(StartSaving)

  let variables = UpdateUserQuery.makeVariables(
    ~name=state.name,
    ~preferredName=state.preferredName,
    ~about=state.about,
    ~locale=state.locale,
    ~currentPassword=state.currentPassword,
    ~newPassword=state.newPassword,
    ~confirmPassword=state.confirmPassword,
    ~dailyDigest=state.dailyDigest,
    (),
  )

  UpdateUserQuery.fetch(variables)
  |> Js.Promise.then_((result: UpdateUserQuery.t) => {
    result.updateUser.success
      ? {
          let hasCurrentPassword = state.newPassword->String.length > 0
          send(FinishSaving(hasCurrentPassword))
        }
      : send(FinishSaving(state.hasCurrentPassword))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(ResetSaving)
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let initiateAccountDeletion = (state, send) => {
  send(StartDeletingAccount)

  InitiateAccountDeletionQuery.fetch({email: state.emailForAccountDeletion})
  |> Js.Promise.then_((result: InitiateAccountDeletionQuery.t) => {
    result.initiateAccountDeletion.success
      ? send(FinishAccountDeletion)
      : send(FinishAccountDeletion)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(FinishAccountDeletion)
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let hasInvalidPassword = state =>
  (state.newPassword == "" && state.confirmPassword == "") ||
    (state.newPassword == state.confirmPassword && state.newPassword->String.length >= 8)
    ? false
    : true

let saveDisabled = state =>
  hasInvalidPassword(state) || (state.name->String.trim->String.length < 2 || !state.dirty)

let confirmEmailChangeWindow = (currentEmail, state, send) =>
  state.showEmailChangePasswordConfirm
    ? {
        let body =
          <div ariaLabel={t("confirm_dialog_aria")}>
            <p className="text-sm text-center ltr:sm:text-left rtl:sm:text-right text-gray-600">
              {t("email_change_q")->str}
            </p>
            <div className="mt-3">
              <label htmlFor="password" className="block text-sm font-semibold">
                {t("confirm_using_password")->str}
              </label>
              <input
                type_="password"
                value=state.passwordForEmailChange
                onChange={event =>
                  send(UpdatePasswordForEmailChange(ReactEvent.Form.target(event)["value"]))}
                id="password"
                autoComplete="off"
                className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                placeholder={t("current_password_placeholder")}
              />
            </div>
          </div>

        <ConfirmWindow
          title={t("change_account_email")}
          body
          confirmButtonText={t("update_email")}
          cancelButtonText={t("cancel")}
          onConfirm={() =>
            updateEmail(send, currentEmail, state.email, state.passwordForEmailChange)}
          onCancel={() => send(UpdateEmailAndDisableInput(currentEmail))}
          disableConfirm={state.passwordForEmailChange->String.length < 1}
          alertType=#Normal
        />
      }
    : React.null

let confirmDeletionWindow = (state, send) =>
  state.showDeleteAccountForm
    ? {
        let body =
          <div ariaLabel={t("confirm_dialog_aria")}>
            <p className="text-sm text-center ltr:sm:text-left rtl:sm:text-right text-gray-600">
              {t("account_delete_q")->str}
            </p>
            <div className="mt-3">
              <label htmlFor="email" className="block text-sm font-semibold">
                {t("confirm_email")->str}
              </label>
              <input
                type_="email"
                value=state.emailForAccountDeletion
                onChange={event =>
                  send(UpdateEmailForDeletion(ReactEvent.Form.target(event)["value"]))}
                id="email"
                autoComplete="off"
                className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                placeholder={t("email_placeholder")}
              />
            </div>
          </div>

        <ConfirmWindow
          title={t("delete_account")}
          body
          confirmButtonText={t("initiate_deletion")}
          cancelButtonText={t("cancel")}
          onConfirm={() => initiateAccountDeletion(state, send)}
          onCancel={() => send(ChangeDeleteAccountFormVisibility(false))}
          disableConfirm={state.deletingAccount || state.email != state.emailForAccountDeletion}
          alertType=#Critical
        />
      }
    : React.null

let themeChip = theme =>
  <div
    className={theme ++ " w-16 h-8 grid grid-cols-3 gap-1 p-1 rounded-md border border-gray-200 bg-white"}>
    <div className="w-full h-full col-span-1 grid grid-rows-2 gap-1">
      <div className="bg-black h-full w-full rounded-md" />
      <div className="bg-primary-500 h-full w-full rounded-md" />
    </div>
    <div className="col-span-2 grid grid-cols-3 gap-1">
      <div className="bg-primary-300 h-full w-full rounded-md" />
      <div className="bg-primary-200 h-full w-full rounded-md" />
      <div className="bg-primary-100 h-full w-full rounded-md" />
      <div className="bg-gray-400 h-full w-full rounded-md" />
      <div className="bg-gray-300 h-full w-full rounded-md" />
      <div className="bg-gray-200 h-full w-full rounded-md" />
    </div>
  </div>

@react.component
let make = (
  ~name,
  ~preferredName,
  ~hasCurrentPassword,
  ~about,
  ~locale,
  ~availableLocales,
  ~avatarUrl,
  ~dailyDigest,
  ~isSchoolAdmin,
  ~hasValidDeleteAccountToken,
  ~email,
  ~schoolName,
) => {
  let initialState = {
    name,
    preferredName,
    about,
    locale,
    email,
    disableEmailInput: true,
    avatarUrl,
    dailyDigest: dailyDigest |> OptionUtils.mapWithDefault(d => d, false),
    themePreference: Dom.Storage2.localStorage
    ->Dom.Storage2.getItem("themePreference")
    ->Belt.Option.getWithDefault("system"),
    saving: false,
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
    emailForAccountDeletion: "",
    showEmailChangePasswordConfirm: false,
    showDeleteAccountForm: false,
    hasCurrentPassword,
    deletingAccount: false,
    avatarUploadError: None,
    dirty: false,
    passwordForEmailChange: "",
    initiatePasswordReset: false,
  }

  let (state, send) = React.useReducer(reducer, initialState)

  <div className="container mx-auto px-3 pt-4 pb-8 max-w-5xl">
    {confirmEmailChangeWindow(email, state, send)}
    {confirmDeletionWindow(state, send)}
    <div className="bg-white max-w-5xl mx-auto shadow sm:rounded-lg mt-4">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pe-4">
            <h3 className="text-lg font-semibold"> {t("edit_profile")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("displayed_publicly")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <div className="">
              <div className="">
                <label htmlFor="user_name" className="block text-sm font-semibold">
                  {ts("name")->str}
                </label>
              </div>
            </div>
            <input
              autoFocus=true
              id="user_name"
              name="name"
              value=state.name
              onChange={event => send(UpdateName(ReactEvent.Form.target(event)["value"]))}
              className="appearance-none mb-2 block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
              placeholder={t("name_placeholder")}
            />
            <School__InputGroupError
              message={t("name_error")} active={state.name->String.trim->String.length < 1}
            />
            <School__InputGroupError
              message={t("name_error_length")} active={state.name->String.trim->String.length == 1}
            />
            <div className="mt-6">
              <label htmlFor="user_preferred_name" className="block text-sm font-semibold">
                {ts("preferred_name")->str}
              </label>
              <input
                id="user_preferred_name"
                name="preferred_name"
                value={state.preferredName}
                onChange={event =>
                  send(UpdatePreferredName(ReactEvent.Form.target(event)["value"]))}
                className="appearance-none mb-2 block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                placeholder={t("preferred_name_placeholder")}
              />
            </div>
            <div className="mt-6">
              <label htmlFor="about" className="block text-sm font-semibold">
                {t("about")->str}
              </label>
              <div>
                <textarea
                  id="about"
                  value=state.about
                  rows=3
                  onChange={event => send(UpdateAbout(ReactEvent.Form.target(event)["value"]))}
                  className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                  placeholder={t("about_placeholder")}
                />
              </div>
            </div>
            <div className="mt-6">
              <form id="user-avatar-uploader">
                <input
                  name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()}
                />
                <label className="block text-sm font-semibold"> {t("photo")->str} </label>
                <div className="mt-2 flex items-center">
                  <span
                    className="inline-block h-14 w-14 rounded-full overflow-hidden bg-gray-50 border-2 boder-gray-400">
                    {switch state.avatarUrl {
                    | Some(url) => <img src=url />
                    | None => <Avatar name />
                    }}
                  </span>
                  <span className="ms-5 inline-flex">
                    <input
                      className="form-input__file-sr-only"
                      name="user[avatar]"
                      type_="file"
                      ariaLabel="User Avatar"
                      onChange={handleAvatarInputChange(send, "user-avatar-uploader")}
                      id="user-edit__avatar-input"
                      required=false
                      multiple=false
                    />
                    <label
                      htmlFor="user-edit__avatar-input"
                      ariaHidden=true
                      className="form-input__file-label shadow-sm py-2 px-3 border border-gray-300 rounded-md text-sm font-semibold hover:text-gray-800 active:bg-gray-50 active:text-gray-800">
                      {t("change_photo")->str}
                    </label>
                  </span>
                  {switch state.avatarUploadError {
                  | Some(error) => <School__InputGroupError message=error active=true />
                  | None => React.null
                  }}
                </div>
              </form>
            </div>
            <div className="mt-6">
              <label name="user_email" className="block text-sm font-semibold" htmlFor="user_email">
                {t("email_label")->str}
              </label>
              <div className="mt-2 flex items-stretch gap-2">
                <input
                  value=state.email
                  disabled={state.disableEmailInput}
                  onChange={event => send(UpdateEmail(ReactEvent.Form.target(event)["value"]))}
                  className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                  name="user_email"
                  type_="email"
                  ariaLabel="User Email"
                  id="user-update__email-input"
                  required=true
                />
                {state.disableEmailInput
                  ? <button
                      className="btn btn-primary"
                      disabled={!state.hasCurrentPassword}
                      onClick={evt => send(SetDisableUpdateEmail(false))}>
                      {ts("edit")->str}
                    </button>
                  : <div className="flex gap-2">
                      <button
                        className="btn btn-subtle"
                        onClick={_ => send(UpdateEmailAndDisableInput(email))}>
                        {ts("cancel")->str}
                      </button>
                      <button
                        className="btn btn-primary"
                        onClick={_ => send(ShowEmailChangePasswordConfirm)}
                        disabled={EmailUtils.isInvalid(false, state.email) || state.email == email}>
                        {ts("update")->str}
                      </button>
                    </div>}
              </div>
              {ReactUtils.nullIf(
                <p className="text-yellow-900 text-xs font-inter mt-1">
                  <PfIcon className="if i-info-light if-fw" />
                  {t("update_email_disabled_notice")->str}
                </p>,
                state.hasCurrentPassword,
              )}
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pe-4">
            <h3 className="text-lg font-semibold"> {t("security")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("update_credentials")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            {state.hasCurrentPassword
              ? <div className="mb-4">
                  <p className="font-semibold"> {t("change_password")->str} </p>
                  <div className="mt-6">
                    <label htmlFor="current_password" className="block text-sm font-semibold">
                      {t("current_password")->str}
                    </label>
                    <input
                      value=state.currentPassword
                      type_="password"
                      autoComplete="off"
                      onChange={event =>
                        send(UpdateCurrentPassword(ReactEvent.Form.target(event)["value"]))}
                      id="current_password"
                      className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                      placeholder={t("password_placeholder")}
                    />
                  </div>
                  <div className="mt-6">
                    <label htmlFor="new_password" className="block text-sm font-semibold">
                      {t("new_password")->str}
                    </label>
                    <input
                      autoComplete="off"
                      type_="password"
                      id="new_password"
                      value=state.newPassword
                      onChange={event =>
                        send(UpdateNewPassword(ReactEvent.Form.target(event)["value"]))}
                      className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                      placeholder={t("new_password_placeholder")}
                    />
                    {switch Zxcvbn.make(
                      ~password=state.newPassword,
                      ~userInputs=[state.name, state.email, schoolName],
                    ) {
                    | None => <div className="h-6" />
                    | Some(zxcvbn) =>
                      <div className="h-6">
                        <div className="flex justify-between items-center">
                          <p className="text-xs text-gray-400 font-inter">
                            {ts("password_strength")->str}
                          </p>
                          <div className="flex items-center gap-1 mt-1">
                            <span
                              key="0"
                              className="text-xs text-gray-400 pe-2 text-right rtl:text-left">
                              {zxcvbn->Zxcvbn.label->str}
                            </span>
                            {[1, 2, 3, 4]
                            ->Js.Array2.map(score =>
                              <span
                                key={score->string_of_int}
                                className={`rounded-md h-1 ${zxcvbn->Zxcvbn.colorClass(
                                    score,
                                  )} w-10`}
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
                  </div>
                  <div className="mt-6">
                    <label
                      autoComplete="off"
                      htmlFor="confirm_password"
                      className="block text-sm font-semibold">
                      {t("confirm_password")->str}
                    </label>
                    <input
                      autoComplete="off"
                      type_="password"
                      id="confirm_password"
                      value=state.confirmPassword
                      onChange={event =>
                        send(UpdateNewPassWordConfirm(ReactEvent.Form.target(event)["value"]))}
                      className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                      placeholder={t("confirm_password_placeholder")}
                    />
                    {ReactUtils.nullUnless(
                      <School__InputGroupError
                        message={t("confirm_password_error")} active={hasInvalidPassword(state)}
                      />,
                      state.confirmPassword->StringUtils.isPresent,
                    )}
                  </div>
                </div>
              : React.null}
            <div>
              <h3 className="font-semibold">
                {(state.hasCurrentPassword ? t("forgot_password") : t("set_up_password"))->str}
              </h3>
              <p className="mt-1 text-sm text-gray-600">
                {(
                  state.hasCurrentPassword ? t("reset_password_subtext") : t("set_password_subtext")
                )->str}
              </p>
              <button
                disabled={state.initiatePasswordReset}
                className="bg-primary-100 text-primary-600 border border-primary-200 rounded-md px-4 py-2 mt-2 text-sm font-semibold"
                onClick={_ => initiatePasswordReset(send, email)}>
                {(
                  state.hasCurrentPassword
                    ? t("reset_password_button_text")
                    : t("set_password_button_text")
                )->str}
              </button>
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pe-4">
            <h3 className="text-lg font-semibold"> {t("notifications")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("update_email_notifications")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold"> {t("community_digest")->str} </p>
            <p className="text-sm text-gray-600"> {t("community_digest_emails")->str} </p>
            <div className="mt-6">
              <div className="flex items-center">
                <Radio
                  id="daily_mail_enable"
                  label={t("send_email_radio")}
                  onChange={event =>
                    send(UpdateDailyDigest(ReactEvent.Form.target(event)["checked"]))}
                  checked=state.dailyDigest
                />
              </div>
              <div className="mt-4 flex items-center">
                <Radio
                  id="daily_mail_disable"
                  label={t("disable_email_radio")}
                  onChange={event =>
                    send(UpdateDailyDigest(!ReactEvent.Form.target(event)["checked"]))}
                  checked={!state.dailyDigest}
                />
              </div>
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pe-4">
            <h3 className="text-lg font-semibold"> {t("localization")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("update_locale")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <label htmlFor="language" className="font-semibold"> {t("language")->str} </label>
            <p className="text-sm text-gray-600"> {t("select_language")->str} </p>
            <div className="mt-6">
              <select
                id="language"
                value={state.locale}
                onChange={event => {
                  send(UpdateLocale(ReactEvent.Form.target(event)["value"]))
                }}
                className="select appearance-none block text-sm w-full bg-white shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500">
                {availableLocales
                ->Js.Array2.map(availableLocale =>
                  <option
                    key=availableLocale
                    value=availableLocale
                    ariaSelected={state.locale === availableLocale}>
                    {Locale.humanize(availableLocale)->str}
                  </option>
                )
                ->React.array}
              </select>
            </div>
          </div>
        </div>
      </div>
      <div className="bg-gray-100 px-4 py-5 sm:p-6 flex rounded-b-lg justify-end">
        <button
          disabled={saveDisabled(state)}
          onClick={updateUser(state, send)}
          className="btn btn-primary">
          {t("save_changes")->str}
        </button>
      </div>
    </div>
    <div className="bg-white max-w-5xl mx-auto shadow sm:rounded-lg mt-10">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pe-4">
            <h3 className="text-lg font-semibold"> {t("appearance_title")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("appearance_description")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <label htmlFor="language" className="font-semibold"> {t("theme_title")->str} </label>
            <div
              className="mt-6 flex flex-col md:flex-row items-start md:grow-0 md:items-center gap-3">
              <label
                htmlFor="theme-system"
                className="w-full md:w-auto p-3 cursor-pointer flex justify-between items-center border border-gray-300 rounded-lg focus-within:outline-none focus-within:border-transparent focus-within:ring-2 focus-within:ring-focusColor-500 ">
                <Radio
                  id="theme-system"
                  label={t("system")}
                  checked={state.themePreference == "system"}
                  onChange={event => send(UpdateThemePreference("system"))}
                />
                <div
                  className="w-16 h-8 flex items-center justify-center p-1 rounded-md border border-gray-200 bg-gray-100">
                  <PfIcon className="if i-desktop-monitor-regular if-fw text-lg text-gray-500" />
                </div>
              </label>
              <label
                htmlFor="theme-light"
                className="w-full md:w-auto p-3 cursor-pointer flex justify-between items-center border border-gray-300 rounded-lg focus-within:outline-none focus-within:border-transparent focus-within:ring-2 focus-within:ring-focusColor-500 ">
                <Radio
                  id="theme-light"
                  label={t("light")}
                  checked={state.themePreference == "light"}
                  onChange={event => send(UpdateThemePreference("light"))}
                />
                {themeChip("theme-pupilfirst")}
              </label>
              <label
                htmlFor="theme-dark"
                className="w-full md:w-auto p-3 cursor-pointer flex justify-between items-center border border-gray-300 rounded-lg focus-within:outline-none focus-within:border-transparent focus-within:ring-2 focus-within:ring-focusColor-500 ">
                <Radio
                  id="theme-dark"
                  label={t("dark")}
                  checked={state.themePreference == "dark"}
                  onChange={event => send(UpdateThemePreference("dark"))}
                />
                {themeChip("dark")}
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div className="bg-white max-w-5xl mx-auto shadow sm:rounded-lg mt-10">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pe-4">
            <h3 className="text-lg font-semibold"> {t("account")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("manage_account")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold text-red-700"> {t("delete_account")->str} </p>
            <p className="text-sm text-gray-600 mt-1">
              {(t("deleting_account_warning") ++ "  ")->str}
            </p>
            <div className="mt-4">
              {isSchoolAdmin || hasValidDeleteAccountToken
                ? <div className="bg-orange-100 border-s-4 border-orange-400 p-4">
                    <div className="flex">
                      <FaIcon classes="fas fa-exclamation-triangle text-orange-400" />
                      <div className="ms-3">
                        <p className="text-sm text-orange-900">
                          {(
                            isSchoolAdmin
                              ? t("you_admin_warning")
                              : t("already_iniated_deletion_warning")
                          )->str}
                        </p>
                      </div>
                    </div>
                  </div>
                : <button
                    onClick={_ => send(ChangeDeleteAccountFormVisibility(true))}
                    className="py-2 px-3 border border-red-500 text-red-600 rounded text-xs font-semibold hover:bg-red-600 hover:text-white focus:outline-none active:bg-red-700 active:text-white">
                    {t("delete_your_account")->str}
                  </button>}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}
