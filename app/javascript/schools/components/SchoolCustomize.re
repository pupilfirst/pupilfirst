open SchoolCustomize__Types;

[%bs.raw {|require("./SchoolCustomize.css")|}];

let str = ReasonReact.string;

type editor =
  | LinksEditor
  | ImagesEditor
  | ContactsEditor
  | PrivacyPolicyEditor
  | TermsOfUseEditor;

type state = {
  visibleEditor: option(editor),
  customizations: Customizations.t,
};

type action =
  | ShowEditor(editor)
  | CloseEditor
  | AddLink(Customizations.link)
  | RemoveLink(Customizations.link);

let component = ReasonReact.reducerComponent("SchoolCustomize");

let headerLogo = (schoolName, logoOnLightBg) =>
  <div className="h-12">
    {
      switch (logoOnLightBg) {
      | Some(logo) => <img className="h-full" src=logo />
      | None => <span> {schoolName |> str} </span>
      }
    }
  </div>;

let headerLink = ((id, title, _)) =>
  <div className="ml-8 cursor-default" key=id>
    <span> {title |> str} </span>
  </div>;

let headerLinks = links => {
  let (visibleLinks, dropdownLinks) =
    switch (links) {
    | [l1, l2, l3, l4, l5, ...rest] => ([l1, l2, l3], [l4, l5, ...rest])
    | fourOrLessLinks => (fourOrLessLinks, [])
    };

  visibleLinks
  |> List.map(l => headerLink(l))
  |> List.rev_append([
       <SchoolCustomize__MoreLinks links=dropdownLinks key="more-links" />,
     ])
  |> Array.of_list
  |> ReasonReact.array;
};

let sitemap = links =>
  <div className="flex flex-wrap">
    {
      links
      |> List.map(((id, title, _)) =>
           <div className="w-1/3 pr-4 mt-3 text-sm" key=id>
             {title |> str}
           </div>
         )
      |> Array.of_list
      |> ReasonReact.array
    }
  </div>;

let socialLinks = links =>
  <div className="flex flex-wrap">
    {
      links
      |> List.map(((id, url)) => <SchoolCustomize__SocialLink url key=id />)
      |> Array.of_list
      |> ReasonReact.array
    }
  </div>;

let address = a =>
  switch (a) {
  | Some(a) =>
    <div
      className="text-sm mt-3 leading-normal"
      dangerouslySetInnerHTML={"__html": a}
    />
  | None => ReasonReact.null
  };

let emailAddress = email =>
  switch (email) {
  | Some(email) =>
    <div className="text-sm mt-4">
      {"React us at " |> str}
      <span className="font-bold"> {email |> str} </span>
    </div>
  | None => ReasonReact.null
  };

let footerLogo = (schoolName, logoOnDarkBg) =>
  <div className="h-8">
    {
      switch (logoOnDarkBg) {
      | Some(logo) => <img className="h-full" src=logo />
      | None => <span> {schoolName |> str} </span>
      }
    }
  </div>;

let editIcon = (additionalClasses, clickHandler) =>
  <div
    className={
      "cursor-pointer bg-grey-darker text-white p-1 rounded-lg flex items-center "
      ++ additionalClasses
    }
    onClick=clickHandler>
    <i className="material-icons text-xl"> {"edit" |> str} </i>
  </div>;

let showEditor = (editor, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(ShowEditor(editor));
};

let editor = (state, send, authenticityToken) =>
  switch (state.visibleEditor) {
  | Some(LinksEditor) =>
    let headerLinks = state.customizations |> Customizations.headerLinks;
    let footerLinks = state.customizations |> Customizations.footerLinks;
    let socialLinks = state.customizations |> Customizations.socialLinks;

    <SchoolCustomize__LinksEditor
      headerLinks
      footerLinks
      socialLinks
      closeEditorCB=(() => send(CloseEditor))
      authenticityToken
      addLinkCB=(link => send(AddLink(link)))
      removeLinkCB=(link => send(RemoveLink(link)))
    />;
  | _ => ReasonReact.null
  };

let make = (~authenticityToken, ~customizations, ~schoolName, _children) => {
  ...component,
  initialState: () => {visibleEditor: Some(LinksEditor), customizations},
  reducer: (action, state) =>
    switch (action) {
    | ShowEditor(editor) =>
      ReasonReact.Update({...state, visibleEditor: Some(editor)})
    | CloseEditor => ReasonReact.Update({...state, visibleEditor: None})
    | AddLink(link) =>
      ReasonReact.Update({
        ...state,
        customizations: state.customizations |> Customizations.addLink(link),
      })
    | RemoveLink(link) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations |> Customizations.removeLink(link),
      })
    },
  render: ({state, send}) =>
    <div>
      <div className="px-6 pt-6">
        <div className="font-bold"> {"Header" |> str} </div>
        <div className="border rounded-lg p-6 flex justify-between mt-3 w-2/3">
          <div className="flex items-center">
            {
              headerLogo(
                schoolName,
                state.customizations |> Customizations.logoOnLightBg,
              )
            }
            {editIcon("ml-6", showEditor(ImagesEditor, send))}
          </div>
          <div className="flex items-center">
            {headerLinks(state.customizations |> Customizations.headerLinks)}
            {editIcon("ml-3", showEditor(LinksEditor, send))}
            <div className="ml-8 w-12 h-12 border rounded-full bg-grey" />
          </div>
        </div>
        <div className="mt-6 font-bold"> {"Footer" |> str} </div>
        <div className="mt-3 w-2/3">
          <div className="bg-grey-darkest rounded-t-lg text-white p-6 flex">
            <div className="w-1/2">
              <div className="flex items-center">
                <span className="uppercase font-bold text-sm">
                  {"Sitemap" |> str}
                </span>
                {editIcon("ml-3", showEditor(LinksEditor, send))}
              </div>
              {sitemap(state.customizations |> Customizations.footerLinks)}
            </div>
            <div className="w-1/2">
              <div className="flex">
                <div className="w-1/2">
                  <div className="flex items-center">
                    <span className="uppercase font-bold text-sm">
                      {"Social" |> str}
                    </span>
                    {editIcon("ml-3", showEditor(LinksEditor, send))}
                  </div>
                  {
                    socialLinks(
                      state.customizations |> Customizations.socialLinks,
                    )
                  }
                </div>
                <div className="w-1/2">
                  <div className="flex items-center">
                    <span className="uppercase font-bold text-sm">
                      {"Contact" |> str}
                    </span>
                    {editIcon("ml-3", showEditor(ContactsEditor, send))}
                  </div>
                  {address(state.customizations |> Customizations.address)}
                  {
                    emailAddress(
                      state.customizations |> Customizations.emailAddress,
                    )
                  }
                </div>
              </div>
            </div>
          </div>
          <div
            className="bg-black rounded-b-lg text-white p-6 flex justify-between">
            <div className="flex items-center">
              {
                footerLogo(
                  schoolName,
                  state.customizations |> Customizations.logoOnDarkBg,
                )
              }
              {editIcon("ml-3", showEditor(ImagesEditor, send))}
            </div>
            <div className="flex items-center text-sm">
              <div> {"Privacy Policy" |> str} </div>
              {editIcon("ml-3", showEditor(PrivacyPolicyEditor, send))}
              <div className="ml-8"> {"Terms of Use" |> str} </div>
              {editIcon("ml-3", showEditor(TermsOfUseEditor, send))}
              <div className="ml-8 flex items-center">
                <i className="material-icons text-base">
                  {"copyright" |> str}
                </i>
                <span className="ml-1">
                  {
                    (
                      Js.Date.make()
                      |> Js.Date.getFullYear
                      |> int_of_float
                      |> string_of_int
                    )
                    ++ " "
                    ++ schoolName
                    |> str
                  }
                </span>
              </div>
            </div>
          </div>
        </div>
        <div className="mt-6 font-bold"> {"Icon" |> str} </div>
        <div className="mt-3 w-1/4">
          <div className="bg-grey rounded-t-lg h-12 flex items-end">
            <div className="w-full flex items-center">
              <div className="h-3 w-3 rounded-full bg-red-lightest ml-4" />
              <div className="h-3 w-3 rounded-full bg-yellow-lightest ml-2" />
              <div className="h-3 w-3 rounded-full bg-green-lightest ml-2" />
              <div
                className="p-3 ml-4 bg-grey-lighter rounded-t-lg flex items-center">
                <img
                  src={state.customizations |> Customizations.icon}
                  className="h-5 w-5"
                />
                <span className="ml-2"> {schoolName |> str} </span>
              </div>
              {editIcon("ml-2", showEditor(ImagesEditor, send))}
            </div>
          </div>
          <div className="bg-grey-lighter h-16" />
        </div>
      </div>
      {editor(state, send, authenticityToken)}
    </div>,
};