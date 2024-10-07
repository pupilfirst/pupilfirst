let str = React.string

let t = I18n.t(~scope="components.SchoolAdmins__Form", ...)
let ts = I18n.ts

module CreateSchoolAdminQuery = %graphql(`
  mutation CreateSchoolAdminMutation($name: String!, $email: String!) {
    createSchoolAdmin(name: $name, email: $email){
      schoolAdmin{
        id,
        avatarUrl
      }
    }
  }
`)

module UpdateSchoolAdminQuery = %graphql(`
  mutation UpdateSchoolAdminMutation($id: ID!, $name: String!) {
    updateSchoolAdmin(id: $id, name: $name) {
      success
    }
  }
`)

let createSchoolAdminQuery = (email, name, setSaving, updateCB) => {
  setSaving(_ => true)

  ignore(Js.Promise.then_(response => {
      switch response["createSchoolAdmin"]["schoolAdmin"] {
      | Some(schoolAdmin) =>
        updateCB(
          SchoolAdmin.create(
            ~id=schoolAdmin["id"],
            ~name,
            ~email,
            ~avatarUrl=schoolAdmin["avatarUrl"],
          ),
        )
        Notification.success(ts("notifications.success"), t("admin_created_notification"))
      | None => setSaving(_ => false)
      }
      Js.Promise.resolve()
    }, CreateSchoolAdminQuery.make({email, name})))
  ()
}

let updateSchoolAdminQuery = (admin, name, setSaving, updateCB) => {
  setSaving(_ => true)
  let id = SchoolAdmin.id(admin)

  ignore(Js.Promise.then_((response: UpdateSchoolAdminQuery.t) => {
      response.updateSchoolAdmin.success
        ? {
            updateCB(SchoolAdmin.updateName(name, admin))
            Notification.success(ts("notifications.success"), t("admin_updated_notification"))
          }
        : setSaving(_ => false)
      Js.Promise.resolve()
    }, UpdateSchoolAdminQuery.fetch({id, name})))
}

let handleButtonClick = (admin, setSaving, name, email, updateCB, event) => {
  ReactEvent.Mouse.preventDefault(event)
  switch admin {
  | Some(admin) => updateSchoolAdminQuery(admin, name, setSaving, updateCB)
  | None => createSchoolAdminQuery(email, name, setSaving, updateCB)
  }
}

let isInvalidEmail = email => EmailUtils.isInvalid(false, email)

let showInvalidEmailError = (email, admin) =>
  switch admin {
  | Some(_) => isInvalidEmail(email)
  | None => email == "" ? false : isInvalidEmail(email)
  }

let showInvalidNameError = (name, admin) =>
  switch admin {
  | Some(_) => name == ""
  | None => false
  }
let saveDisabled = (email, name, saving, admin) =>
  isInvalidEmail(email) ||
  (saving ||
  (name == "" ||
    switch admin {
    | Some(admin) => SchoolAdmin.name(admin) == name && SchoolAdmin.email(admin) == email
    | None => false
    }))

let buttonText = (saving, admin) =>
  switch (saving, admin) {
  | (true, _) => "Saving"
  | (false, Some(_)) => t("update_admin")
  | (false, None) => t("create_admin")
  }

let emailInputDisabled = admin =>
  switch admin {
  | Some(_) => true
  | None => false
  }

@react.component
let make = (~admin, ~updateCB) => {
  let (saving, setSaving) = React.useState(() => false)

  let (name, setName) = React.useState(() =>
    switch admin {
    | Some(admin) => SchoolAdmin.name(admin)
    | None => ""
    }
  )

  let (email, setEmail) = React.useState(() =>
    switch admin {
    | Some(admin) => SchoolAdmin.email(admin)
    | None => ""
    }
  )

  <div className="w-full">
    <DisablingCover disabled=saving>
      <div className="mx-auto bg-white">
        <div className="max-w-2xl p-6 mx-auto">
          <h5 className="uppercase text-center border-b border-gray-300 pb-2 mb-4">
            {str(
              switch admin {
              | Some(admin) => SchoolAdmin.name(admin)
              | None => t("add_new_admin")
              },
            )}
          </h5>
          <div>
            <label
              className="inline-block tracking-wide text-sm font-medium pb-2 leading-tight"
              htmlFor="email">
              {str(ts("email"))}
            </label>
            <input
              autoFocus=true
              value=email
              onChange={event => setEmail(ReactEvent.Form.target(event)["value"])}
              className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
              id="email"
              type_="email"
              placeholder={t("email_placeholder")}
              disabled={emailInputDisabled(admin)}
            />
            <School__InputGroupError
              message={t("email_error")} active={showInvalidEmailError(email, admin)}
            />
          </div>
          <div className="mt-5">
            <label
              className="inline-block tracking-wide text-sm font-medium pb-2 leading-tight"
              htmlFor="name">
              {str(ts("name"))}
            </label>
            <input
              value=name
              onChange={event => setName(ReactEvent.Form.target(event)["value"])}
              className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
              id="name"
              type_="text"
              placeholder={t("name_placeholder")}
            />
            <School__InputGroupError
              message="Enter a valid name" active={showInvalidNameError(name, admin)}
            />
          </div>
          <div className="w-auto mt-8">
            <button
              disabled={saveDisabled(email, name, saving, admin)}
              onClick={handleButtonClick(admin, setSaving, name, email, updateCB)}
              className="w-full btn btn-large btn-primary">
              {str(buttonText(saving, admin))}
            </button>
          </div>
        </div>
      </div>
    </DisablingCover>
  </div>
}
