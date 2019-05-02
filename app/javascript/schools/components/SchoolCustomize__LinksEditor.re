open SchoolCustomize__Types;

let str = ReasonReact.string;

type kind =
  | HeaderLink
  | FooterLink
  | SocialLink;

type state = {
  kind,
  title: string,
  url: string,
  titleInvalid: bool,
  urlInvalid: bool,
  formDirty: bool,
  adding: bool,
  deleting: list(Customizations.linkId),
};

type action =
  | UpdateKind(kind)
  | UpdateTitle(string, bool)
  | UpdateUrl(string, bool)
  | DisableForm
  | EnableForm
  | ClearForm
  | DisableDelete(Customizations.linkId);

let component = ReasonReact.reducerComponent("SchoolCustomize__LinksEditor");

let handleKindChange = (send, kind, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(UpdateKind(kind));
};

let isTitleInvalid = title => title |> String.trim |> String.length == 0;

let handleTitleChange = (send, event) => {
  let title = ReactEvent.Form.target(event)##value;
  send(UpdateTitle(title, isTitleInvalid(title)));
};

let handleUrlChange = (send, event) => {
  let url = ReactEvent.Form.target(event)##value;
  send(UpdateUrl(url, UrlUtils.isInvalid(url)));
};

let handleCloseEditor = (cb, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  cb();
};

module DestroySchoolLinkQuery = [%graphql
  {|
  mutation($id: ID!) {
    destroySchoolLink(id: $id) {
      success
    }
  }
  |}
];

let handleDelete = (state, send, authenticityToken, removeLinkCB, id, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (state.deleting |> List.mem(id)) {
    (); /* Do nothing if this link is already being deleted. */
  } else {
    send(DisableDelete(id));

    DestroySchoolLinkQuery.make(~id, ())
    |> GraphqlQuery.sendQuery(authenticityToken)
    |> Js.Promise.then_(_response => {
         removeLinkCB(id);
         Js.Promise.resolve();
       })
    |> ignore;
  };
};

let showLinks = (state, send, authenticityToken, removeLinkCB, kind, links) =>
  links
  |> List.map(((id, title, url)) =>
       <div
         className="flex items-center justify-between bg-grey-lightest text-xs text-grey-darkest border rounded p-3 mt-2"
         key=id>
         <div className="flex items-center">
           {
             switch (kind) {
             | HeaderLink
             | FooterLink =>
               [|
                 <span key="link-editor-entry__title"> {title |> str} </span>,
                 <i
                   key="link-editor-entry__icon"
                   className="far fa-link mx-2"
                 />,
                 <code key="link-editor-entry__url"> {url |> str} </code>,
               |]
               |> ReasonReact.array
             | SocialLink => <code> {url |> str} </code>
             }
           }
         </div>
         <button
           onClick={
             handleDelete(state, send, authenticityToken, removeLinkCB, id)
           }>
           <Icon
             kind=Icon.Delete
             size="4"
             rotate={state.deleting |> List.mem(id)}
           />
         </button>
       </div>
     )
  |> Array.of_list
  |> ReasonReact.array;

let titleInputVisible = state =>
  switch (state.kind) {
  | HeaderLink
  | FooterLink => true
  | SocialLink => false
  };

let kindClasses = selected => {
  let classes = "cursor-pointer w-1/3 appearance-none block w-full text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-grey-lightest focus:border-grey";
  classes ++ (selected ? " bg-white" : " bg-grey-light");
};

let addLinkText = adding => adding ? "Adding new link..." : "Add a New Link";

let addLinkDisabled = state =>
  if (state.adding) {
    true;
  } else if (state.formDirty) {
    switch (state.kind) {
    | HeaderLink
    | FooterLink =>
      isTitleInvalid(state.title) || UrlUtils.isInvalid(state.url)
    | SocialLink => UrlUtils.isInvalid(state.url)
    };
  } else {
    true;
  };

module CreateSchoolLinkQuery = [%graphql
  {|
  mutation($kind: String!, $title: String, $url: String!) {
    createSchoolLink(kind: $kind, title: $title, url: $url) @bsVariant {
      schoolLink {
        id
      }
      errors
    }
  }
|}
];

let displayNewLink = (state, addLinkCB, id) =>
  (
    switch (state.kind) {
    | HeaderLink => Customizations.HeaderLink(id, state.title, state.url)
    | FooterLink => Customizations.FooterLink(id, state.title, state.url)
    | SocialLink => Customizations.SocialLink(id, state.url)
    }
  )
  |> addLinkCB;

module CreateLinkError = {
  type t = [ | `InvalidUrl | `InvalidLengthTitle | `InvalidKind | `BlankTitle];

  let notification = error =>
    switch (error) {
    | `InvalidUrl => (
        "Invalid URL",
        "It looks like the URL you've entered isn't valid. Please check, and try again.",
      )
    | `InvalidKind => ("InvalidKind", "")
    | `InvalidLengthTitle => ("InvalidLengthTitle", "")
    | `BlankTitle => ("BlankTitle", "")
    };
};

module CreateLinkErrorHandler = GraphqlErrorHandler.Make(CreateLinkError);

let handleAddLink = (state, send, authenticityToken, addLinkCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (addLinkDisabled(state)) {
    (); /* Do nothing! */
  } else {
    send(DisableForm);
    (
      switch (state.kind) {
      | HeaderLink =>
        CreateSchoolLinkQuery.make(
          ~kind="header",
          ~title=state.title,
          ~url=state.url,
          (),
        )
      | FooterLink =>
        CreateSchoolLinkQuery.make(
          ~kind="footer",
          ~title=state.title,
          ~url=state.url,
          (),
        )
      | SocialLink =>
        CreateSchoolLinkQuery.make(~kind="social", ~url=state.url, ())
      }
    )
    |> GraphqlQuery.sendQuery(authenticityToken)
    |> Js.Promise.then_(response =>
         switch (response##createSchoolLink) {
         | `SchoolLink(schoolLink) =>
           schoolLink##id |> displayNewLink(state, addLinkCB);
           send(ClearForm);
           Notification.success("Done!", "A custom link has been added.");
           Js.Promise.resolve();
         | `Errors(errors) =>
           Js.Promise.reject(CreateLinkErrorHandler.Errors(errors))
         }
       )
    |> CreateLinkErrorHandler.catch(() => send(EnableForm))
    |> ignore;
  };
};

let linksTitle = kind =>
  (
    switch (kind) {
    | HeaderLink => "Current Header Links"
    | FooterLink => "Current Sitemap Links"
    | SocialLink => "Current Social Media Links"
    }
  )
  |> str;

let unpackLinks = (kind, customizations) =>
  customizations
  |> (
    switch (kind) {
    | HeaderLink => Customizations.headerLinks
    | FooterLink => Customizations.footerLinks
    | SocialLink => Customizations.socialLinks
    }
  )
  |> Customizations.unpackLinks;

let make =
    (
      ~kind,
      ~customizations,
      ~authenticityToken,
      ~addLinkCB,
      ~removeLinkCB,
      _children,
    ) => {
  ...component,
  initialState: () => {
    kind,
    title: "",
    url: "",
    titleInvalid: false,
    urlInvalid: false,
    formDirty: false,
    adding: false,
    deleting: [],
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateKind(kind) =>
      ReasonReact.Update({...state, kind, formDirty: true})
    | UpdateTitle(title, invalid) =>
      ReasonReact.Update({
        ...state,
        title,
        titleInvalid: invalid,
        formDirty: true,
      })
    | UpdateUrl(url, invalid) =>
      ReasonReact.Update({
        ...state,
        url,
        urlInvalid: invalid,
        formDirty: true,
      })
    | DisableForm => ReasonReact.Update({...state, adding: true})
    | EnableForm => ReasonReact.Update({...state, adding: false})
    | ClearForm =>
      ReasonReact.Update({...state, adding: false, title: "", url: ""})
    | DisableDelete(linkId) =>
      ReasonReact.Update({...state, deleting: [linkId, ...state.deleting]})
    },
  render: ({state, send}) =>
    <div className="mt-8 mx-8">
      <h5 className="uppercase text-center border-b border-grey-light pb-2">
        {"Manage custom links" |> str}
      </h5>
      <div className="mt-3">
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
          htmlFor="email">
          {"Location of Link" |> str}
        </label>
        <div className="flex">
          <div
            className={kindClasses(state.kind == HeaderLink)}
            onClick={handleKindChange(send, HeaderLink)}>
            {"Header" |> str}
          </div>
          <div
            className={kindClasses(state.kind == FooterLink) ++ " ml-2"}
            onClick={handleKindChange(send, FooterLink)}>
            {"Footer Sitemap" |> str}
          </div>
          <div
            className={kindClasses(state.kind == SocialLink) ++ " ml-2"}
            onClick={handleKindChange(send, SocialLink)}>
            {"Social" |> str}
          </div>
        </div>
      </div>
      <label
        className="inline-block tracking-wide text-grey-darker text-xs font-semibold mt-4">
        {linksTitle(state.kind)}
      </label>
      {
        showLinks(
          state,
          send,
          authenticityToken,
          removeLinkCB,
          state.kind,
          unpackLinks(state.kind, customizations),
        )
      }
      <DisablingCover.Jsx2 disabled={state.adding}>
        <div className="flex mt-3" key="sc-links-editor__form-body">
          {
            if (state |> titleInputVisible) {
              <div className="flex-grow mr-4">
                <label
                  className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
                  htmlFor="email">
                  {"Title" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                  id="link-title"
                  type_="text"
                  placeholder="A short title for a new link"
                  onChange={handleTitleChange(send)}
                  value={state.title}
                  maxLength=24
                />
                <School__InputGroupError
                  message="can't be empty"
                  active={state.titleInvalid}
                />
              </div>;
            } else {
              ReasonReact.null;
            }
          }
          <div className="flex-grow">
            <label
              className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
              htmlFor="link-full-url">
              {"Full URL" |> str}
            </label>
            <input
              className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-grey"
              id="link-full-url"
              type_="text"
              placeholder="Full URL, staring with https://"
              onChange={handleUrlChange(send)}
              value={state.url}
            />
            <School__InputGroupError
              message="is not a valid URL"
              active={state.urlInvalid}
            />
          </div>
        </div>
        <button
          key="sc-links-editor__form-button"
          disabled={addLinkDisabled(state)}
          onClick={handleAddLink(state, send, authenticityToken, addLinkCB)}
          className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
          {state.adding |> addLinkText |> str}
        </button>
      </DisablingCover.Jsx2>
    </div>,
};