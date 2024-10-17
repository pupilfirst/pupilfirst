let str = React.string

let t = I18n.t(~scope="components.CourseAuthors__Form", ...)

open CourseAuthors__Types

module CreateCourseAuthorQuery = %graphql(`
  mutation CreateCourseAuthorMutation($courseId: ID!, $name: String!, $email: String!) {
    createCourseAuthor(courseId: $courseId, name: $name, email: $email){
      courseAuthor{
        id,
        avatarUrl
      }
    }
  }
`)

module UpdateCourseAuthorQuery = %graphql(`
  mutation UpdateCourseAuthorMutation($id: ID!, $name: String!) {
    updateCourseAuthor(id: $id, name: $name) {
      success
    }
  }
`)

let createCourseAuthorQuery = (courseId, rootPath, email, name, setSaving, addAuthorCB) => {
  setSaving(_ => true)

  let variables = CreateCourseAuthorQuery.makeVariables(~courseId, ~email, ~name, ())

  ignore(
    Js.Promise.catch(
      _ => {
        setSaving(_ => false)
        Js.Promise.resolve()
      },
      Js.Promise.then_(response => {
        switch response["createCourseAuthor"]["courseAuthor"] {
        | Some(courseAuthor) =>
          addAuthorCB(
            Author.create(
              ~id=courseAuthor["id"],
              ~name,
              ~email,
              ~avatarUrl=courseAuthor["avatarUrl"],
            ),
          )

          RescriptReactRouter.push(rootPath)
        | None => setSaving(_ => false)
        }
        Js.Promise.resolve()
      }, CreateCourseAuthorQuery.make(variables)),
    ),
  )
}

let updateCourseAuthorQuery = (rootPath, author, name, setSaving, updateAuthorCB) => {
  setSaving(_ => true)
  let id = Author.id(author)

  ignore(
    Js.Promise.catch(
      _ => {
        setSaving(_ => false)
        Js.Promise.resolve()
      },
      Js.Promise.then_((response: UpdateCourseAuthorQuery.t) => {
        if response.updateCourseAuthor.success {
          updateAuthorCB(Author.updateName(name, author))
          RescriptReactRouter.push(rootPath)
        } else {
          setSaving(_ => false)
        }

        Js.Promise.resolve()
      }, UpdateCourseAuthorQuery.fetch({id, name})),
    ),
  )
}

let handleButtonClick = (
  courseId,
  rootPath,
  author,
  setSaving,
  name,
  email,
  addAuthorCB,
  updateAuthorCB,
  event,
) => {
  ReactEvent.Mouse.preventDefault(event)
  switch author {
  | Some(author) => updateCourseAuthorQuery(rootPath, author, name, setSaving, updateAuthorCB)
  | None => createCourseAuthorQuery(courseId, rootPath, email, name, setSaving, addAuthorCB)
  }
}

let isInvalidEmail = email => EmailUtils.isInvalid(false, email)

let showInvalidEmailError = (email, author) =>
  switch author {
  | Some(_) => isInvalidEmail(email)
  | None => email == "" ? false : isInvalidEmail(email)
  }

let showInvalidNameError = (name, author) =>
  switch author {
  | Some(_) => name == ""
  | None => false
  }
let saveDisabled = (email, name, saving, author) =>
  isInvalidEmail(email) ||
  (saving ||
  (name == "" ||
    switch author {
    | Some(author) => Author.name(author) == name && Author.email(author) == email
    | None => false
    }))

let buttonText = (saving, author) =>
  switch (saving, author) {
  | (true, _) => t("saving")
  | (false, Some(_)) => t("update_author")
  | (false, None) => t("create_author")
  }

let emailInputDisabled = author =>
  switch author {
  | Some(_) => true
  | None => false
  }

@react.component
let make = (~courseId, ~rootPath, ~author, ~addAuthorCB, ~updateAuthorCB) => {
  let (saving, setSaving) = React.useState(() => false)

  let (name, setName) = React.useState(() =>
    switch author {
    | Some(author) => Author.name(author)
    | None => ""
    }
  )

  let (email, setEmail) = React.useState(() =>
    switch author {
    | Some(author) => Author.email(author)
    | None => ""
    }
  )

  <div className="w-full">
    <DisablingCover disabled=saving>
      <div className="mx-auto bg-white">
        <div className="max-w-2xl p-6 mx-auto">
          <h5 className="uppercase text-center border-b border-gray-300 pb-2 mb-4">
            {str(
              switch author {
              | Some(author) => Author.name(author)
              | None => t("add_new_author")
              },
            )}
          </h5>
          <div>
            <label
              className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
              htmlFor="email">
              {str(t("email"))}
            </label>
            <input
              autoFocus=true
              value=email
              onChange={event => setEmail(ReactEvent.Form.target(event)["value"])}
              className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
              id="email"
              type_="email"
              placeholder={t("email_placeholder")}
              disabled={emailInputDisabled(author)}
            />
            <School__InputGroupError
              message={t("email_message")} active={showInvalidEmailError(email, author)}
            />
          </div>
          <div className="mt-5">
            <label
              className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
              htmlFor="name">
              {str(t("name"))}
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
              message={t("name_message")} active={showInvalidNameError(name, author)}
            />
          </div>
          <div className="w-auto mt-8">
            <button
              disabled={saveDisabled(email, name, saving, author)}
              onClick={handleButtonClick(
                courseId,
                rootPath,
                author,
                setSaving,
                name,
                email,
                addAuthorCB,
                updateAuthorCB,
              )}
              className="w-full btn btn-large btn-primary">
              {str(buttonText(saving, author))}
            </button>
          </div>
        </div>
      </div>
    </DisablingCover>
  </div>
}
