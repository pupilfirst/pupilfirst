let str = React.string;

type state = {
  name: string,
  about: string,
  avatarUrl: option(string),
  currentPassword: string,
  newPassword: string,
  confirmPassword: string,
  dailyDigest: bool,
  passwordForAccountDeletion: string,
  showDeleteAccountForm: bool,
  hasCurrentPassword: bool,
  deletingAccount: bool,
  avatarUploadError: option(string),
  saving: bool,
  dirty: bool,
};

type action =
  | UpdateName(string)
  | UpdateAbout(string)
  | UpdateCurrentPassword(string)
  | UpdateNewPassword(string)
  | UpdateNewPassWordConfirm(string)
  | UpdatePasswordForDeletion(string)
  | UpdateDailyDigest(bool)
  | UpdateAvatarUrl(option(string))
  | ChangeDeleteAccountFormVisibility(bool)
  | SetAvatarUploadError(option(string))
  | StartSaving
  | FinishSaving(bool)
  | StartDeletingAccount
  | FinishAccountDeletion;

let reducer = (state, action) => {
  switch (action) {
  | UpdateName(name) => {...state, name, dirty: true}
  | UpdateAbout(about) => {...state, about, dirty: true}
  | UpdateCurrentPassword(currentPassword) => {
      ...state,
      currentPassword,
      dirty: true,
    }
  | UpdateNewPassword(newPassword) => {...state, newPassword, dirty: true}
  | UpdateNewPassWordConfirm(confirmPassword) => {
      ...state,
      confirmPassword,
      dirty: true,
    }
  | UpdatePasswordForDeletion(passwordForAccountDeletion) => {
      ...state,
      passwordForAccountDeletion,
    }
  | UpdateDailyDigest(dailyDigest) => {...state, dailyDigest}
  | StartSaving => {...state, saving: true}
  | ChangeDeleteAccountFormVisibility(showDeleteAccountForm) => {
      ...state,
      showDeleteAccountForm,
      passwordForAccountDeletion: "",
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
  | StartDeletingAccount => {...state, deletingAccount: true}
  | FinishAccountDeletion => {
      ...state,
      showDeleteAccountForm: false,
      deletingAccount: false,
      passwordForAccountDeletion: "",
    }
  };
};

module UpdateUserQuery = [%graphql
  {|
   mutation UpdateUserMutation($id: ID!, $name: String!, $about: String, $currentPassword: String, $newPassword: String, $confirmPassword: String, $dailyDigest: Boolean! ) {
     updateUser(id: $id, name: $name, about: $about, currentPassword: $currentPassword, newPassword: $newPassword, confirmNewPassword: $confirmPassword, dailyDigest: $dailyDigest  ) {
        success
       }
     }
   |}
];

module InitiateAccountDeletionQuery = [%graphql
  {|
   mutation InitiateAccountDeletionMutation($id: ID!, $password: String! ) {
     initiateAccountDeletion(id: $id, password: $password ) {
        success
       }
     }
   |}
];

let uploadAvatar = (send, formData) => {
  Json.Decode.(
    Api.sendFormData(
      "/user/upload_avatar",
      formData,
      json => {
        Notification.success("Done!", "Avatar uploaded successfully.");
        let avatarUrl = json |> field("avatarUrl", string);
        send(UpdateAvatarUrl(Some(avatarUrl)));
      },
      () => send(SetAvatarUploadError(Some("Failed to upload"))),
    )
  );
};
let submitAvatarForm = (send, formId) => {
  let element = ReactDOMRe._getElementById(formId);

  switch (element) {
  | Some(element) => DomUtils.FormData.create(element) |> uploadAvatar(send)
  | None =>
    Rollbar.error(
      "Could not find form to upload file for content block: " ++ formId,
    )
  };
};

let handleAvatarInputChange = (send, formId, event) => {
  event |> ReactEvent.Form.preventDefault;

  switch (ReactEvent.Form.target(event)##files) {
  | [||] => ()
  | files =>
    let file = files[0];

    let maxAllowedFileSize = 5 * 1024 * 1024;
    let isInvalidImageFile =
      file##size > maxAllowedFileSize
      || (
        switch (file##_type) {
        | "image/jpeg"
        | "image/gif"
        | "image/png" => false
        | _ => true
        }
      );

    let error =
      isInvalidImageFile
        ? Some("Please select an image with a size less than 5 MB") : None;

    switch (error) {
    | Some(error) => send(SetAvatarUploadError(Some(error)))
    | None => submitAvatarForm(send, formId)
    };
  };
};

let updateUser = (state, send, id, event) => {
  ReactEvent.Mouse.preventDefault(event);
  send(StartSaving);

  UpdateUserQuery.make(
    ~id,
    ~name=state.name,
    ~about=state.about,
    ~currentPassword=state.currentPassword,
    ~newPassword=state.newPassword,
    ~confirmPassword=state.confirmPassword,
    ~dailyDigest=state.dailyDigest,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       result##updateUser##success
         ? {
           let hasCurrentPassword = state.newPassword |> String.length > 0;
           send(FinishSaving(hasCurrentPassword));
         }
         : send(FinishSaving(state.hasCurrentPassword));
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(FinishSaving(state.hasCurrentPassword));
       Js.Promise.resolve();
     })
  |> ignore;
  ();
};

let initiateAccountDeletion = (state, send, id) => {
  send(StartDeletingAccount);

  InitiateAccountDeletionQuery.make(
    ~id,
    ~password=state.passwordForAccountDeletion,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       result##initiateAccountDeletion##success
         ? {
           send(FinishAccountDeletion);
         }
         : send(FinishAccountDeletion);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(FinishAccountDeletion);
       Js.Promise.resolve();
     })
  |> ignore;
  ();
};

let hasInvalidPassword = state => {
  state.newPassword == ""
  && state.confirmPassword == ""
  || state.newPassword == state.confirmPassword
  && state.newPassword
  |> String.length >= 8
    ? false : true;
};

let saveDisabled = state => {
  hasInvalidPassword(state)
  || state.name
  |> String.trim
  |> String.length < 2
  || !state.dirty;
};

let confirmDeletionWindow = (state, send, currentUserId) => {
  state.showDeleteAccountForm
    ? {
      let body =
        <div>
          <p className="text-sm text-center sm:text-left text-gray-700">
            {"Are you sure you want to deactivate your account? All of your data will be permanently removed from our servers forever. This action cannot be undone."
             |> str}
          </p>
          <div className="mt-3">
            <label
              htmlFor="confirm_password"
              className="block text-sm font-semibold">
              {"Password" |> str}
            </label>
            <input
              type_="password"
              value={state.passwordForAccountDeletion}
              onChange={event =>
                send(
                  UpdatePasswordForDeletion(
                    ReactEvent.Form.target(event)##value,
                  ),
                )
              }
              id="confirm_password"
              autoComplete="off"
              className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
              placeholder="Type your password"
            />
          </div>
        </div>;

      <ConfirmWindow
        title="Delete account"
        body
        confirmButtonText="Confirm Deletion"
        cancelButtonText="Cancel"
        onConfirm={() => initiateAccountDeletion(state, send, currentUserId)}
        onCancel={() => send(ChangeDeleteAccountFormVisibility(false))}
        alertType=`Critical
      />;
    }
    : React.null;
};

[@react.component]
let make =
    (
      ~currentUserId,
      ~name,
      ~hasCurrentPassword,
      ~about,
      ~avatarUrl,
      ~dailyDigest,
    ) => {
  let initialState = {
    name,
    about,
    avatarUrl,
    dailyDigest: dailyDigest |> OptionUtils.mapWithDefault(d => d, false),
    saving: false,
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
    passwordForAccountDeletion: "",
    showDeleteAccountForm: false,
    hasCurrentPassword,
    deletingAccount: false,
    avatarUploadError: None,
    dirty: false,
  };

  let (state, send) = React.useReducer(reducer, initialState);
  <div className="container mx-auto px-3 py-8 max-w-5xl">
    {confirmDeletionWindow(state, send, currentUserId)}
    <div className="bg-white shadow sm:rounded-lg">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold">
              {"Edit your profile" |> str}
            </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"This information will be displayed publicly so be careful what you share."
               |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <div className="">
              <div className="">
                <label
                  htmlFor="user_name" className="block text-sm font-semibold">
                  {"Name" |> str}
                </label>
              </div>
            </div>
            <input
              id="user_name"
              name="name"
              value={state.name}
              onChange={event =>
                send(UpdateName(ReactEvent.Form.target(event)##value))
              }
              className="appearance-none mb-2 block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
              placeholder="Type your name"
            />
            <School__InputGroupError
              message="Name can't be blank"
              active={state.name |> String.trim |> String.length < 2}
            />
            <div className="mt-6">
              <label htmlFor="about" className="block text-sm font-semibold">
                {"About" |> str}
              </label>
              <div>
                <textarea
                  id="about"
                  value={state.about}
                  rows=3
                  onChange={event =>
                    send(UpdateAbout(ReactEvent.Form.target(event)##value))
                  }
                  className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                  placeholder="A brief introduction about yourself"
                />
              </div>
            </div>
            <div className="mt-6">
              <form id="user-avatar-uploader">
                <input
                  name="authenticity_token"
                  type_="hidden"
                  value={AuthenticityToken.fromHead()}
                />
                <label className="block text-sm font-semibold">
                  {"Photo" |> str}
                </label>
                <div className="mt-2 flex items-center">
                  <span
                    className="inline-block h-14 w-14 rounded-full overflow-hidden bg-gray-200 border-2 boder-gray-400">
                    {switch (state.avatarUrl) {
                     | Some(url) => <img src=url />
                     | None => <Avatar name />
                     }}
                  </span>
                  <span className="ml-5 inline-flex">
                    <input
                      className="form-input__file-sr-only"
                      name="user[avatar]"
                      type_="file"
                      ariaLabel="user-edit__avatar-input"
                      onChange={handleAvatarInputChange(
                        send,
                        "user-avatar-uploader",
                      )}
                      id="user-edit__avatar-input"
                      required=false
                      multiple=false
                    />
                    <label
                      htmlFor="user-edit__avatar-input"
                      ariaHidden=true
                      className="form-input__file-label rounded-md shadow-sm py-2 px-3 border border-gray-400 rounded-md text-sm font-semibold hover:text-gray-800 active:bg-gray-100 active:text-gray-800">
                      {"Change photo" |> str}
                    </label>
                  </span>
                  {switch (state.avatarUploadError) {
                   | Some(error) =>
                     <School__InputGroupError message=error active=true />
                   | None => React.null
                   }}
                </div>
              </form>
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold"> {"Security" |> str} </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"Update your login credentials for the school." |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold">
              {"Change your current password" |> str}
            </p>
            {state.hasCurrentPassword
               ? <div className="mt-6">
                   <label
                     htmlFor="current_password"
                     className="block text-sm font-semibold">
                     {"Current Password" |> str}
                   </label>
                   <input
                     value={state.currentPassword}
                     type_="password"
                     autoComplete="off"
                     onChange={event =>
                       send(
                         UpdateCurrentPassword(
                           ReactEvent.Form.target(event)##value,
                         ),
                       )
                     }
                     id="current_password"
                     className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                     placeholder="Type current password"
                   />
                 </div>
               : React.null}
            <div className="mt-6">
              <label
                htmlFor="new_password" className="block text-sm font-semibold">
                {"New Password" |> str}
              </label>
              <input
                autoComplete="off"
                type_="password"
                id="new_password"
                value={state.newPassword}
                onChange={event =>
                  send(
                    UpdateNewPassword(ReactEvent.Form.target(event)##value),
                  )
                }
                className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                placeholder="Type new password"
              />
            </div>
            <div className="mt-6">
              <label
                autoComplete="off"
                htmlFor="confirm_password"
                className="block text-sm font-semibold">
                {"Confirm password" |> str}
              </label>
              <input
                autoComplete="off"
                type_="password"
                id="confirm_password"
                value={state.confirmPassword}
                onChange={event =>
                  send(
                    UpdateNewPassWordConfirm(
                      ReactEvent.Form.target(event)##value,
                    ),
                  )
                }
                className="appearance-none block text-sm w-full shadow-sm border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:border-gray-500"
                placeholder="Confirm new password"
              />
              <School__InputGroupError
                message="New password and confirmation should match and must be atleast 8 characters"
                active={hasInvalidPassword(state)}
              />
            </div>
          </div>
        </div>
        <div className="flex flex-col md:flex-row mt-10 md:mt-12">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold">
              {"Notifications" |> str}
            </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"Update settings for email notifications." |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold"> {"Community Digest" |> str} </p>
            <p className="text-sm text-gray-700">
              {"Community digest emails contain new questions from your communities, and a selection of unanswered questions from the past week."
               |> str}
            </p>
            <div className="mt-6">
              <div className="flex items-center">
                <Radio
                  id="daily_mail_enable"
                  label="Send me a daily email"
                  onChange={event =>
                    send(
                      UpdateDailyDigest(
                        ReactEvent.Form.target(event)##checked,
                      ),
                    )
                  }
                  checked={state.dailyDigest}
                />
              </div>
              <div className="mt-4 flex items-center">
                <Radio
                  id="daily_mail_disable"
                  label="Disable"
                  onChange={event =>
                    send(
                      UpdateDailyDigest(
                        !ReactEvent.Form.target(event)##checked,
                      ),
                    )
                  }
                  checked={!state.dailyDigest}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div
        className="bg-gray-100 px-4 py-5 sm:p-6 flex rounded-b-lg justify-end">
        <button
          disabled={saveDisabled(state)}
          onClick={updateUser(state, send, currentUserId)}
          className="btn btn-primary">
          {"Save Changes" |> str}
        </button>
      </div>
    </div>
    <div className="bg-white shadow sm:rounded-lg mt-10">
      <div className="px-4 py-5 sm:p-6">
        <div className="flex flex-col md:flex-row">
          <div className="w-full md:w-1/3 pr-4">
            <h3 className="text-lg font-semibold"> {"Account" |> str} </h3>
            <p className="mt-1 text-sm text-gray-700">
              {"Manage your account in this school" |> str}
            </p>
          </div>
          <div className="mt-5 md:mt-0 w-full md:w-2/3">
            <p className="font-semibold text-red-700">
              {"Delete account" |> str}
            </p>
            <p className="text-sm text-gray-700 mt-1">
              {"Deleting your user account removes all your data from this school. Replies to posts in communities and feedback to students (if user has a coach profile) will not be deleted. Admin rights need to be revoked if you are an admin in this school.  "
               |> str}
            </p>
            <div className="mt-4">
              <button
                onClick={_ => send(ChangeDeleteAccountFormVisibility(true))}
                className="py-2 px-3 border border-red-500 text-red-600 rounded text-xs font-semibold hover:bg-red-600 hover:text-white focus:outline-none active:bg-red-700 active:text-white">
                {"Delete your account" |> str}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>;
};
