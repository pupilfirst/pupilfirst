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
};

type action =
  | UpdateKind(kind)
  | UpdateTitle(string, bool)
  | UpdateUrl(string, bool);

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

let showLinks = links =>
  links
  |> List.map(((title, url)) =>
       <div
         className="flex items-center justify-between bg-grey-lightest text-xs text-grey-darkest border rounded p-3 mt-2"
         key=url>
         <div className="flex items-center">
           <span> {title |> str} </span>
           <i className="material-icons text-base ml-1">
             {"arrow_forward" |> str}
           </i>
           <code className="ml-1"> {url |> str} </code>
         </div>
         <button> <Icon kind=Icon.Delete size="4" /> </button>
       </div>
     )
  |> Array.of_list
  |> ReasonReact.array;

let socialMediaLinks = links =>
  links
  |> List.map(url =>
       <div
         className="flex items-center justify-between bg-grey-lightest text-xs text-grey-darkest border rounded p-3 mt-2"
         key=url>
         <code> {url |> str} </code>
         <button> <Icon kind=Icon.Delete size="4" /> </button>
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

let addLinkDisabled = state =>
  if (state.formDirty) {
    switch (state.kind) {
    | HeaderLink
    | FooterLink =>
      isTitleInvalid(state.title) || UrlUtils.isInvalid(state.url)
    | SocialLink => UrlUtils.isInvalid(state.url)
    };
  } else {
    true;
  };

let handleAddLink = (state, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (addLinkDisabled(state)) {
    ();
  } else {
    Js.log("boo!");
  };
};

let make =
    (~closeEditorCB, ~headerLinks, ~footerLinks, ~socialLinks, _children) => {
  ...component,
  initialState: () => {
    kind: HeaderLink,
    title: "",
    url: "",
    titleInvalid: false,
    urlInvalid: false,
    formDirty: false,
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
    },
  render: ({state, send}) =>
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            onClick={handleCloseEditor(closeEditorCB)}
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> str} </i>
          </button>
        </div>
        <div className="w-full overflow-scroll">
          <div className="mx-auto bg-white">
            <div className="max-w-md p-6 mx-auto">
              <h5
                className="uppercase text-center border-b border-grey-light pb-2">
                {"Add a Link" |> str}
              </h5>
              <div className="mt-3">
                <label
                  className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
                  htmlFor="email">
                  {"Location of Custom Link" |> str}
                </label>
                <div className="flex">
                  <div
                    className={kindClasses(state.kind == HeaderLink)}
                    onClick={handleKindChange(send, HeaderLink)}>
                    {"Header" |> str}
                  </div>
                  <div
                    className={
                      kindClasses(state.kind == FooterLink) ++ " ml-2"
                    }
                    onClick={handleKindChange(send, FooterLink)}>
                    {"Footer" |> str}
                  </div>
                  <div
                    className={
                      kindClasses(state.kind == SocialLink) ++ " ml-2"
                    }
                    onClick={handleKindChange(send, SocialLink)}>
                    {"Social" |> str}
                  </div>
                </div>
              </div>
              <div className="flex mt-3">
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
                        placeholder="A short title for this link"
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
                disabled={addLinkDisabled(state)}
                onClick={handleAddLink(state, send)}
                className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
                {"Add a New Link" |> str}
              </button>
              <h5
                className="uppercase text-center border-b border-grey-light pb-2 mt-6">
                {"Current Links" |> str}
              </h5>
              <label
                className="inline-block tracking-wide text-grey-darker text-xs font-semibold mt-4">
                {"Header Links" |> str}
              </label>
              {showLinks(headerLinks)}
              <label
                className="block tracking-wide text-grey-darker text-xs font-semibold mt-4">
                {"Footer Links" |> str}
              </label>
              {showLinks(footerLinks)}
              <label
                className="block tracking-wide text-grey-darker text-xs font-semibold mt-4">
                {"Social Media Links" |> str}
              </label>
              {socialMediaLinks(socialLinks)}
            </div>
          </div>
        </div>
      </div>
    </div>,
};