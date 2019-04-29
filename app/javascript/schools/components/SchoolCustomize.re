open SchoolCustomize__Types;

[%bs.raw {|require("./SchoolCustomize.css")|}];

let str = ReasonReact.string;

type editor =
  | LinksEditor(SchoolCustomize__LinksEditor.kind)
  | ImagesEditor
  | ContactsEditor
  | AgreementsEditor(SchoolCustomize__AgreementsEditor.kind);

type state = {
  visibleEditor: option(editor),
  customizations: Customizations.t,
};

type action =
  | ShowEditor(editor)
  | CloseEditor
  | AddLink(Customizations.link)
  | RemoveLink(Customizations.linkId)
  | UpdateTermsOfUse(string)
  | UpdatePrivacyPolicy(string)
  | UpdateAddress(string)
  | UpdateEmailAddress(string)
  | UpdateImages(Js.Json.t);

let component = ReasonReact.reducerComponent("SchoolCustomize");

let headerLogo = (schoolName, logoOnLightBg) =>
  <div className="h-12">
    {
      switch (logoOnLightBg) {
      | Some(logo) =>
        <img className="h-full" src={logo |> Customizations.url} />
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

  (visibleLinks |> List.map(l => headerLink(l)))
  ->List.append([
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
      |> List.map(((id, _title, url)) =>
           <SchoolCustomize__SocialLink url key=id />
         )
      |> Array.of_list
      |> ReasonReact.array
    }
  </div>;

let address = a =>
  switch (a) {
  | Some(a) =>
    <div
      className="text-sm mt-3 leading-normal"
      dangerouslySetInnerHTML={"__html": a |> Markdown.parse}
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
      | Some(logo) =>
        <img className="h-full" src={logo |> Customizations.url} />
      | None => <span> {schoolName |> str} </span>
      }
    }
  </div>;

let editIcon = (additionalClasses, clickHandler) =>
  <div
    className={
      "cursor-pointer bg-grey-darker hover:bg-primary text-white p-2 rounded-lg flex items-center "
      ++ additionalClasses
    }
    onClick=clickHandler>
    <i className="fas fa-pen-nib text-lg" />
  </div>;

let showEditor = (editor, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(ShowEditor(editor));
};

let editor = (state, send, authenticityToken) =>
  switch (state.visibleEditor) {
  | Some(editor) =>
    <SchoolAdmin__EditorDrawer closeDrawerCB=(() => send(CloseEditor))>
      {
        switch (editor) {
        | LinksEditor(kind) =>
          <SchoolCustomize__LinksEditor
            key="sc-drawer__links-editor"
            kind
            customizations={state.customizations}
            authenticityToken
            addLinkCB=(link => send(AddLink(link)))
            removeLinkCB=(linkId => send(RemoveLink(linkId)))
          />
        | AgreementsEditor(kind) =>
          <SchoolCustomize__AgreementsEditor
            key="sc-drawer__agreements-editor"
            kind
            customizations={state.customizations}
            updatePrivacyPolicyCB=(
              agreement => send(UpdatePrivacyPolicy(agreement))
            )
            updateTermsOfUseCB=(
              agreement => send(UpdateTermsOfUse(agreement))
            )
            authenticityToken
          />
        | ContactsEditor =>
          <SchoolCustomize__ContactsEditor
            key="sc-drawer__contacts-editor"
            customizations={state.customizations}
            updateAddressCB=(address => send(UpdateAddress(address)))
            updateEmailAddressCB=(
              emailAddress => send(UpdateEmailAddress(emailAddress))
            )
            authenticityToken
          />
        | ImagesEditor =>
          <SchoolCustomize__ImagesEditor
            key="sc-drawer__images-editor"
            customizations={state.customizations}
            updateImagesCB=(json => send(UpdateImages(json)))
            authenticityToken
          />
        }
      }
    </SchoolAdmin__EditorDrawer>

  | None => ReasonReact.null
  };

let make = (~authenticityToken, ~customizations, ~schoolName, _children) => {
  ...component,
  initialState: () => {visibleEditor: None, customizations},
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
    | RemoveLink(linkId) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations |> Customizations.removeLink(linkId),
      })
    | UpdatePrivacyPolicy(agreement) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations
          |> Customizations.updatePrivacyPolicy(agreement),
      })
    | UpdateTermsOfUse(agreement) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations |> Customizations.updateTermsOfUse(agreement),
      })
    | UpdateAddress(address) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations |> Customizations.updateAddress(address),
      })
    | UpdateEmailAddress(emailAddress) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations
          |> Customizations.updateEmailAddress(emailAddress),
      })
    | UpdateImages(json) =>
      ReasonReact.Update({
        ...state,
        customizations:
          state.customizations |> Customizations.updateImages(json),
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
            {
              headerLinks(
                state.customizations
                |> Customizations.headerLinks
                |> Customizations.unpackLinks,
              )
            }
            {
              editIcon(
                "ml-3",
                showEditor(
                  LinksEditor(SchoolCustomize__LinksEditor.HeaderLink),
                  send,
                ),
              )
            }
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
                {
                  editIcon(
                    "ml-3",
                    showEditor(
                      LinksEditor(SchoolCustomize__LinksEditor.FooterLink),
                      send,
                    ),
                  )
                }
              </div>
              {
                sitemap(
                  state.customizations
                  |> Customizations.footerLinks
                  |> Customizations.unpackLinks,
                )
              }
            </div>
            <div className="w-1/2">
              <div className="flex">
                <div className="w-1/2">
                  <div className="flex items-center">
                    <span className="uppercase font-bold text-sm">
                      {"Social" |> str}
                    </span>
                    {
                      editIcon(
                        "ml-3",
                        showEditor(
                          LinksEditor(
                            SchoolCustomize__LinksEditor.SocialLink,
                          ),
                          send,
                        ),
                      )
                    }
                  </div>
                  {
                    socialLinks(
                      state.customizations
                      |> Customizations.socialLinks
                      |> Customizations.unpackLinks,
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
              {
                editIcon(
                  "ml-3",
                  showEditor(
                    AgreementsEditor(
                      SchoolCustomize__AgreementsEditor.PrivacyPolicy,
                    ),
                    send,
                  ),
                )
              }
              <div className="ml-8"> {"Terms of Use" |> str} </div>
              {
                editIcon(
                  "ml-3",
                  showEditor(
                    AgreementsEditor(
                      SchoolCustomize__AgreementsEditor.TermsOfUse,
                    ),
                    send,
                  ),
                )
              }
              <div className="ml-8 flex items-center">
                <i className="far fa-copyright" />
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
                  src={
                    state.customizations
                    |> Customizations.icon
                    |> Customizations.url
                  }
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