open SchoolCustomize__Types

%raw(`require("./SchoolCustomize__LinksEditor.css")`)

let str = React.string

type kind =
  | HeaderLink
  | FooterLink
  | SocialLink

type state = {
  kind: kind,
  title: string,
  url: string,
  titleInvalid: bool,
  urlInvalid: bool,
  formDirty: bool,
  adding: bool,
  deleting: list<Customizations.linkId>,
}

type action =
  | UpdateKind(kind)
  | UpdateTitle(string, bool)
  | UpdateUrl(string, bool)
  | DisableForm
  | EnableForm
  | ClearForm
  | DisableDelete(Customizations.linkId)

let handleKindChange = (send, kind, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send(UpdateKind(kind))
}

let isTitleInvalid = title => title |> String.trim |> String.length == 0

let handleTitleChange = (send, event) => {
  let title = ReactEvent.Form.target(event)["value"]
  send(UpdateTitle(title, isTitleInvalid(title)))
}

let handleUrlChange = (send, event) => {
  let url = ReactEvent.Form.target(event)["value"]
  send(UpdateUrl(url, url |> UrlUtils.isInvalid(false)))
}

module DestroySchoolLinkQuery = %graphql(`
  mutation DestroySchoolLinkMutation($id: ID!) {
    destroySchoolLink(id: $id) {
      success
    }
  }
  `)

let handleDelete = (state, send, removeLinkCB, id, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if state.deleting |> List.mem(id) {
    ()
  } else {
    send(DisableDelete(id))

    DestroySchoolLinkQuery.make(~id, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(_response => {
      removeLinkCB(id)
      Js.Promise.resolve()
    })
    |> ignore
  }
}

let titleInputVisible = state =>
  switch state.kind {
  | HeaderLink
  | FooterLink => true
  | SocialLink => false
  }

let kindClasses = selected => {
  let classes = "nav-tab-item border-t cursor-pointer w-1/3 appearance-none flex justify-center items-center w-full text-sm text-center text-gray-800 bg-white hover:bg-gray-200 hover:text-gray-900 py-3 px-4 font-semibold leading-tight focus:outline-none focus:bg-gray-200 focus:text-gray-900"
  classes ++ (
    selected
      ? " nav-tab-item--selected text-primary-500 bg-white hover:bg-white hover:text-primary-500"
      : " text-gray-600"
  )
}

let addLinkText = adding => adding ? "Adding new link..." : "Add a New Link"

let addLinkDisabled = state =>
  if state.adding {
    true
  } else if state.formDirty {
    switch state.kind {
    | HeaderLink
    | FooterLink =>
      isTitleInvalid(state.title) || state.url |> UrlUtils.isInvalid(false)
    | SocialLink => state.url |> UrlUtils.isInvalid(false)
    }
  } else {
    true
  }

module CreateSchoolLinkQuery = %graphql(`
  mutation CreateSchoolLinkMutation($kind: String!, $title: String, $url: String!) {
    createSchoolLink(kind: $kind, title: $title, url: $url) @bsVariant {
      schoolLink {
        id
      }
      errors
    }
  }
`)

module UpdateSchoolLinkQuery = %graphql(`
  mutation UpdateSchoolLinkMutation($id: ID!, $title: String, $url: String!) {
    updateSchoolLink(id: $id, title: $title, url: $url) {
     success
    }
  }
`)

let displayNewLink = (state, addLinkCB, id) =>
  switch state.kind {
  | HeaderLink => Customizations.HeaderLink(id, state.title, state.url)
  | FooterLink => Customizations.FooterLink(id, state.title, state.url)
  | SocialLink => Customizations.SocialLink(id, state.url)
  } |> addLinkCB

module CreateLinkError = {
  type t = [#InvalidUrl | #InvalidLengthTitle | #InvalidKind | #BlankTitle]

  let notification = error =>
    switch error {
    | #InvalidUrl => (
        "Invalid URL",
        "It looks like the URL you've entered isn't valid. Please check, and try again.",
      )
    | #InvalidKind => ("InvalidKind", "")
    | #InvalidLengthTitle => ("InvalidLengthTitle", "")
    | #BlankTitle => ("BlankTitle", "")
    }
}

module CreateLinkErrorHandler = GraphqlErrorHandler.Make(CreateLinkError)

let handleAddLink = (state, send, addLinkCB, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if addLinkDisabled(state) {
    ()
  } else {
    send(DisableForm)
    switch state.kind {
    | HeaderLink =>
      CreateSchoolLinkQuery.make(~kind="header", ~title=state.title, ~url=state.url, ())
    | FooterLink =>
      CreateSchoolLinkQuery.make(~kind="footer", ~title=state.title, ~url=state.url, ())
    | SocialLink => CreateSchoolLinkQuery.make(~kind="social", ~url=state.url, ())
    }
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response =>
      switch response["createSchoolLink"] {
      | #SchoolLink(schoolLink) =>
        schoolLink["id"] |> displayNewLink(state, addLinkCB)
        send(ClearForm)
        Notification.success("Done!", "A custom link has been added.")
        Js.Promise.resolve()
      | #Errors(errors) => Js.Promise.reject(CreateLinkErrorHandler.Errors(errors))
      }
    )
    |> CreateLinkErrorHandler.catch(() => send(EnableForm))
    |> ignore
  }
}

let handleLinkEdit = (~setUpdating, ~setIsEditingDisabled, ~id, ~title, ~url) => {
  setUpdating(_ => true)
  UpdateSchoolLinkQuery.make(~id, ~title, ~url, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(_ => {
    setUpdating(_ => false)
    setIsEditingDisabled(_ => true)
    Notification.success("Done!", "A link has been updated.")
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let linksTitle = kind =>
  switch kind {
  | HeaderLink => "Current Header Links"
  | FooterLink => "Current Sitemap Links"
  | SocialLink => "Current Social Media Links"
  } |> str

let unpackLinks = (kind, customizations) =>
  customizations
  |> switch kind {
  | HeaderLink => Customizations.headerLinks
  | FooterLink => Customizations.footerLinks
  | SocialLink => Customizations.socialLinks
  }
  |> Customizations.unpackLinks

let initialState = kind => {
  kind: kind,
  title: "",
  url: "",
  titleInvalid: false,
  urlInvalid: false,
  formDirty: false,
  adding: false,
  deleting: list{},
}
let reducer = (state, action) =>
  switch action {
  | UpdateKind(kind) => {...state, kind: kind, formDirty: true}
  | UpdateTitle(title, invalid) => {
      ...state,
      title: title,
      titleInvalid: invalid,
      formDirty: true,
    }
  | UpdateUrl(url, invalid) => {
      ...state,
      url: url,
      urlInvalid: invalid,
      formDirty: true,
    }
  | DisableForm => {...state, adding: true}
  | EnableForm => {...state, adding: false}
  | ClearForm => {...state, adding: false, title: "", url: ""}
  | DisableDelete(linkId) => {
      ...state,
      deleting: list{linkId, ...state.deleting},
    }
  }

module LinkComponent = {
  let inputClasses = "bg-white border border-gray-400 rounded py-2 px-3 focus:outline-none focus:ring-2 focus:ring-indigo-500 placeholder-gray-500"

  let deleteIconClasses = deleting => deleting ? "fas fa-spinner fa-pulse" : "far fa-trash-alt"

  @react.component
  let make = (~id, ~title, ~url, ~state, ~send, ~removeLinkCB, ~kind) => {
    let (isEditingDisabled, setIsEditingDisabled) = React.useState(_ => true)
    let (_title, setTitle) = React.useState(_ => title)
    let (_url, setUrl) = React.useState(_ => url)
    let (updating, setUpdating) = React.useState(_ => false)
    let (error, setError) = React.useState(_ => false)
    <DisablingCover disabled=updating message="Updating...">
      <div
        className={"flex justify-between items-center gap-8 bg-gray-100 text-xs text-gray-900 border rounded mt-2"}>
        <div className="flex items-center flex-1">
          {isEditingDisabled
            ? <div className="pl-3">
                {switch kind {
                | HeaderLink
                | FooterLink => <>
                    <span> {title |> str} </span>
                    <FaIcon classes="fas fa-link mx-2" />
                    <code> {url |> str} </code>
                  </>
                | SocialLink => <code> {url |> str} </code>
                }}
              </div>
            : <>
                {switch kind {
                | HeaderLink
                | FooterLink => <>
                    <input
                      value=_title
                      required=true
                      autoFocus=true
                      className=inputClasses
                      placeholder="A short title for a new link"
                      onChange={event => {
                        let value = ReactEvent.Form.target(event)["value"]
                        setTitle(_ => value)
                      }}
                    />
                    <FaIcon classes="fas fa-link mx-2" />
                  </>
                | SocialLink => React.null
                }}
                <div className="flex flex-col gap-1 flex-1">
                  <input
                    value=_url
                    type_="url"
                    required=true
                    placeholder="Full URL, staring with https://"
                    className={inputClasses ++ " flex-1 invalid:ring-red-500"}
                    autoFocus={kind == SocialLink}
                    onChange={event => {
                      let value = ReactEvent.Form.target(event)["value"]
                      setError(_ => value |> UrlUtils.isInvalid(false))
                      setUrl(_ => value)
                    }}
                  />
                  <School__InputGroupError active={error} message="Invalid Url" />
                </div>
              </>}
        </div>
        <div>
          {isEditingDisabled
            ? <div>
                <button
                  ariaLabel={"Edit " ++ title}
                  title={"Edit " ++ url}
                  onClick={e => setIsEditingDisabled(_ => false)}
                  className="p-3 hover:text-primary-500 focus:text-primary-500">
                  <FaIcon classes="fas fa-edit" />
                </button>
                <button
                  ariaLabel={"Delete " ++ title}
                  title={"Delete " ++ url}
                  onClick={handleDelete(state, send, removeLinkCB, id)}
                  className="p-3 hover:text-red-500 focus:text-red-500">
                  <FaIcon classes={deleteIconClasses(state.deleting |> List.mem(id))} />
                </button>
              </div>
            : <div>
                <button
                  ariaLabel={"Cancel Editing " ++ title}
                  title={"Cancel Editing " ++ url}
                  onClick={e => {
                    setIsEditingDisabled(_ => true)
                    setTitle(_ => title)
                    setError(_ => url |> UrlUtils.isInvalid(false))
                    setUrl(_ => url)
                  }}
                  className="p-3 hover:text-primary-500 focus:text-primary-500">
                  <FaIcon classes={"fas fa-times"} />
                </button>
                <button
                  ariaLabel={"Update " ++ title}
                  title={"Update " ++ url}
                  disabled={error}
                  onClick={e =>
                    if !error {
                      handleLinkEdit(
                        ~setUpdating,
                        ~setIsEditingDisabled,
                        ~id,
                        ~title=_title,
                        ~url=_url,
                      )
                    }}
                  className="p-3 hover:text-primary-500 focus:text-primary-500">
                  <FaIcon classes={"fas fa-check"} />
                </button>
              </div>}
        </div>
      </div>
    </DisablingCover>
  }
}

let showLinks = (state, send, removeLinkCB, kind, links) =>
  switch links {
  | list{} =>
    <div
      className="border border-gray-400 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
      {"There are no custom links here. Add some?" |> str}
    </div>
  | links =>
    links
    |> List.map(((id, title, url)) =>
      <LinkComponent key=id id title url kind removeLinkCB send state />
    )
    |> Array.of_list
    |> React.array
  }

@react.component
let make = (~kind, ~customizations, ~addLinkCB, ~removeLinkCB) => {
  let (state, send) = React.useReducer(reducer, initialState(kind))

  <div className="mt-8 mx-8 pb-6">
    <h5 className="uppercase text-center border-b border-gray-400 pb-2">
      {"Manage custom links" |> str}
    </h5>
    <div className="mt-3">
      <label className="inline-block tracking-wide text-xs font-semibold">
        {"Location of Link" |> str}
      </label>
      <div role="tablist" className="flex bg-white border border-t-0 rounded-t mt-2">
        <button
          role="tab"
          ariaSelected={state.kind == HeaderLink}
          ariaLabel="View and edit header links"
          title="View and edit header links"
          className={kindClasses(state.kind == HeaderLink)}
          onClick={handleKindChange(send, HeaderLink)}>
          {"Header" |> str}
        </button>
        <button
          role="tab"
          ariaSelected={state.kind == FooterLink}
          ariaLabel="View and edit footer links"
          title="View and edit footer links"
          className={kindClasses(state.kind == FooterLink) ++ " border-l"}
          onClick={handleKindChange(send, FooterLink)}>
          {"Footer Sitemap" |> str}
        </button>
        <button
          role="tab"
          ariaSelected={state.kind == SocialLink}
          ariaLabel="View and edit social media links"
          title="View and edit social media links"
          className={kindClasses(state.kind == SocialLink) ++ " border-l"}
          onClick={handleKindChange(send, SocialLink)}>
          {"Social" |> str}
        </button>
      </div>
    </div>
    <div className="p-5 border border-t-0 rounded-b">
      <label className="inline-block tracking-wide text-xs font-semibold mt-4">
        {linksTitle(state.kind)}
      </label>
      {showLinks(state, send, removeLinkCB, state.kind, unpackLinks(state.kind, customizations))}
      <DisablingCover disabled=state.adding>
        <div className="flex mt-3" key="sc-links-editor__form-body">
          {if state |> titleInputVisible {
            <div className="flex-grow mr-4">
              <label
                className="inline-block tracking-wide text-xs font-semibold" htmlFor="link-title">
                {"Title" |> str}
              </label>
              <input
                autoFocus=true
                className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-indigo-500"
                id="link-title"
                type_="text"
                placeholder="A short title for a new link"
                onChange={handleTitleChange(send)}
                value=state.title
                maxLength=24
              />
              <School__InputGroupError message="can't be empty" active=state.titleInvalid />
            </div>
          } else {
            React.null
          }}
          <div className="flex-grow">
            <label
              className="inline-block tracking-wide text-xs font-semibold" htmlFor="link-full-url">
              {"Full URL" |> str}
            </label>
            <input
              className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-indigo-500"
              id="link-full-url"
              type_="text"
              placeholder="Full URL, staring with https://"
              onChange={handleUrlChange(send)}
              value=state.url
            />
            <School__InputGroupError message="is not a valid URL" active=state.urlInvalid />
          </div>
        </div>
        <div className="flex justify-end">
          <button
            key="sc-links-editor__form-button"
            disabled={addLinkDisabled(state)}
            onClick={handleAddLink(state, send, addLinkCB)}
            className="btn btn-primary btn-large mt-6">
            {state.adding |> addLinkText |> str}
          </button>
        </div>
      </DisablingCover>
    </div>
  </div>
}
