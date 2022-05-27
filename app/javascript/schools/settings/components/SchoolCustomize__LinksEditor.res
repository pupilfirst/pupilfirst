open SchoolCustomize__Types.SchoolLinks
open SchoolCustomize__Types

%raw(`require("./SchoolCustomize__LinksEditor.css")`)

let str = React.string

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

let titleInputVisible = (state: state) =>
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

let addLinkDisabled = (state: state) =>
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

let displayNewLink = (state: state, addLinkCB, id) =>
  switch state.kind {
  | HeaderLink => Customizations.HeaderLink(id, state.title, state.url, 0)
  | FooterLink => Customizations.FooterLink(id, state.title, state.url, 0)
  | SocialLink => Customizations.SocialLink(id, state.url, 0)
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

let showLinks = (state, send, removeLinkCB, updateLinkCB, moveLinkCB, kind, links) =>
  switch links {
  | list{} =>
    <div
      className="border border-gray-400 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
      {"There are no custom links here. Add some?" |> str}
    </div>
  | links =>
    links
    |> List.mapi((index, (id, title, url, sortIndex)) =>
      <SchoolCustomize__LinkComponent
        key=id
        id
        title
        url
        kind
        removeLinkCB
        updateLinkCB
        moveLinkCB
        links
        send
        state
        index
        total={List.length(links)}
      />
    )
    |> Array.of_list
    |> React.array
  }

@react.component
let make = (~kind, ~customizations, ~addLinkCB, ~moveLinkCB, ~removeLinkCB, ~updateLinkCB) => {
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
      {showLinks(
        state,
        send,
        removeLinkCB,
        updateLinkCB,
        moveLinkCB,
        state.kind,
        unpackLinks(state.kind, customizations),
      )}
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
