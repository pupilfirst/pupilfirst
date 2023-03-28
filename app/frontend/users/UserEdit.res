let str = React.string

@val @scope(("window", "pupilfirst"))
external maxUploadFileSize: int = "maxUploadFileSize"

let t = I18n.t(~scope="components.UserEdit")
let ts = I18n.ts

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
  dailyDigest: bool,
  emailForAccountDeletion: string,
  showDeleteAccountForm: bool,
  hasCurrentPassword: bool,
  deletingAccount: bool,
  avatarUploadError: option<string>,
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
  | UpdateAvatarUrl(option<string>)
  | ChangeDeleteAccountFormVisibility(bool)
  | SetAvatarUploadError(option<string>)
  | StartSaving
  | ResetSaving
  | FinishSaving(bool)
  | StartDeletingAccount
  | FinishAccountDeletion
  | UpdateEmailAndDisableInput(string)

let reducer = (state, action) =>
  switch action {
  | UpdateName(name) => {...state, name: name, dirty: true}
  | UpdatePreferredName(preferredName) => {...state, preferredName: preferredName, dirty: true}
  | UpdateAbout(about) => {...state, about: about, dirty: true}
  | UpdateEmail(email) => {...state, email: email, dirty: true}
  | SetDisableUpdateEmail(disableEmailInput) => {
      ...state,
      disableEmailInput: disableEmailInput,
    }
  | UpdateLocale(locale) => {...state, locale: locale, dirty: true}
  | UpdateCurrentPassword(currentPassword) => {
      ...state,
      currentPassword: currentPassword,
      dirty: true,
    }
  | UpdateNewPassword(newPassword) => {...state, newPassword: newPassword, dirty: true}
  | UpdateNewPassWordConfirm(confirmPassword) => {
      ...state,
      confirmPassword: confirmPassword,
      dirty: true,
    }
  | UpdateEmailForDeletion(emailForAccountDeletion) => {
      ...state,
      emailForAccountDeletion: emailForAccountDeletion,
    }
  | UpdateDailyDigest(dailyDigest) => {...state, dailyDigest: dailyDigest, dirty: true}
  | StartSaving => {...state, saving: true}
  | ChangeDeleteAccountFormVisibility(showDeleteAccountForm) => {
      ...state,
      showDeleteAccountForm: showDeleteAccountForm,
      emailForAccountDeletion: "",
    }
  | SetAvatarUploadError(avatarUploadError) => {...state, avatarUploadError: avatarUploadError}
  | UpdateAvatarUrl(avatarUrl) => {
      ...state,
      avatarUrl: avatarUrl,
      avatarUploadError: None,
    }
  | FinishSaving(hasCurrentPassword) => {
      ...state,
      saving: false,
      dirty: false,
      currentPassword: "",
      newPassword: "",
      confirmPassword: "",
      hasCurrentPassword: hasCurrentPassword,
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
      email: email,
      dirty: true,
      disableEmailInput: true,
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
   mutation SendUpdateEmailToken($newEmail: String! ) {
     sendUpdateEmailToken(newEmail: $newEmail ) {
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

let updateEmail = (send, email, newEmail) => {
  send(SetDisableUpdateEmail(false))

  SendEmailUpdateTokenQuery.fetch({newEmail: newEmail})
  |> Js.Promise.then_(_ => {
    send(SetDisableUpdateEmail(true))
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
  hasInvalidPassword(state) || (state.name->String.trim->String.length == 0 || !state.dirty)

let confirmDeletionWindow = (state, send) =>
  state.showDeleteAccountForm
    ? {
        let body =
          <div ariaLabel={t("confirm_dialog_aria")}>
            <p className="text-sm text-center sm:text-left text-gray-600">
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
          disableConfirm=state.deletingAccount
          alertType=#Critical
        />
      }
    : React.null

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
) => {
  let initialState = {
    name: name,
    preferredName: preferredName,
    about: about,
    locale: locale,
    email: email,
    disableEmailInput: true,
    avatarUrl: avatarUrl,
    dailyDigest: dailyDigest |> OptionUtils.mapWithDefault(d => d, false),
    saving: false,
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
    emailForAccountDeletion: "",
    showDeleteAccountForm: false,
    hasCurrentPassword: hasCurrentPassword,
    deletingAccount: false,
    avatarUploadError: None,
    dirty: false,
  }

  let (state, send) = React.useReducer(reducer, initialState)

  <div className="container mx-auto px-3 py-8 max-w-5xl">
    {confirmDeletionWindow(state, send)}
    <div className="bg-white shadow sm:rounded-lg">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pr-4">
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
              message={t("name_error")} active={state.name->String.trim->String.length < 2}
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
                  <span className="ml-5 inline-flex">
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
                        onClick={_ => updateEmail(send, email, state.email)}
                        disabled={EmailUtils.isInvalid(false, state.email) || state.email == email}>
                        {ts("update")->str}
                      </button>
                    </div>}
              </div>
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold"> {t("security")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("update_credentials")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold">
              {(state.hasCurrentPassword ? t("change_password") : t("set_password"))->str}
            </p>
            {state.hasCurrentPassword
              ? <div className="mt-6">
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
              : React.null}
            <div className="mt-6">
              <label htmlFor="new_password" className="block text-sm font-semibold">
                {t("new_password")->str}
              </label>
              <input
                autoComplete="off"
                type_="password"
                id="new_password"
                value=state.newPassword
                onChange={event => send(UpdateNewPassword(ReactEvent.Form.target(event)["value"]))}
                className="appearance-none block text-sm w-full shadow-sm border border-gray-300 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                placeholder={t("new_password_placeholder")}
              />
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
              <School__InputGroupError
                message={t("confirm_password_error")} active={hasInvalidPassword(state)}
              />
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold"> {t("notifications")->str} </h3>
            <p className="mt-1 text-sm text-gray-600"> {t("update_email_notifications")->str} </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold"> {"Community Digest"->str} </p>
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
          <div className="w-full md:w-1/3 pr-4">
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
      <div className="bg-gray-50 px-4 py-5 sm:p-6 flex rounded-b-lg justify-end">
        <button
          disabled={saveDisabled(state)}
          onClick={updateUser(state, send)}
          className="btn btn-primary">
          {t("save_changes")->str}
        </button>
      </div>
    </div>
    <div className="bg-white shadow sm:rounded-lg mt-10">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pr-4">
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
                ? <div className="bg-orange-100 border-l-4 border-orange-400 p-4">
                    <div className="flex">
                      <FaIcon classes="fas fa-exclamation-triangle text-orange-400" />
                      <div className="ml-3">
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
