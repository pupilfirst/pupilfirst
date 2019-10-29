open SchoolCustomize__Types;

[%bs.raw {|require("./SchoolCustomize__Root.css")|}];

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
  switch (logoOnLightBg) {
  | Some(logo) =>
    <div className="max-w-xs">
      <img className="h-12" src={logo |> Customizations.url} />
    </div>
  | None => <span className="text-2xl font-bold"> {schoolName |> str} </span>
  };

let headerLink = ((id, title, _)) =>
  <div className="ml-6 text-sm font-semibold cursor-default" key=id>
    <span> {title |> str} </span>
  </div>;

let headerLinks = links => {
  let (visibleLinks, dropdownLinks) =
    switch (links) {
    | [l1, l2, l3, l4, l5, ...rest] => ([l1, l2, l3], [l4, l5, ...rest])
    | fourOrLessLinks => (fourOrLessLinks, [])
    };

  switch (visibleLinks) {
  | [] =>
    <div
      className="border border-gray-400 rounded-lg italic text-gray-600 cursor-default text-sm py-2 px-4">
      {"You can customize links on the header." |> str}
    </div>
  | visibleLinks =>
    (visibleLinks |> List.map(l => headerLink(l)))
    ->List.append([
        <SchoolCustomize__MoreLinks links=dropdownLinks key="more-links" />,
      ])
    |> Array.of_list
    |> ReasonReact.array
  };
};

let sitemap = links =>
  switch (links) {
  | [] =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-3 py-2 px-4">
      {"You can customize links in the footer." |> str}
    </div>
  | links =>
    <div className="flex flex-wrap">
      {links
       |> List.map(((id, title, _)) =>
            <div className="w-1/3 pr-4 mt-3 text-sm" key=id>
              {title |> str}
            </div>
          )
       |> Array.of_list
       |> ReasonReact.array}
    </div>
  };

let socialLinks = links =>
  switch (links) {
  | [] =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-3 py-2 px-4">
      {"Add social media links?" |> str}
    </div>
  | links =>
    <div className="flex flex-wrap">
      {links
       |> List.map(((id, _title, url)) =>
            <SchoolCustomize__SocialLink url key=id />
          )
       |> Array.of_list
       |> ReasonReact.array}
    </div>
  };

let address = a =>
  switch (a) {
  | Some(a) =>
    <div
      className="text-sm mt-3 leading-normal"
      dangerouslySetInnerHTML={
        "__html": a |> Markdown.parse(Markdown.Permissive),
      }
    />
  | None =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-3 py-2 px-4">
      {"Add an address?" |> str}
    </div>
  };

let emailAddress = email =>
  switch (email) {
  | Some(email) =>
    <div className="text-sm mt-4">
      {"React us at " |> str}
      <span className="font-bold"> {email |> str} </span>
    </div>
  | None =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-4 py-2 px-4">
      {"Add a contact email?" |> str}
    </div>
  };

let footerLogo = (schoolName, logoOnDarkBg) =>
  switch (logoOnDarkBg) {
  | Some(logo) => <img className="h-8" src={logo |> Customizations.url} />
  | None => <span className="text-xl font-bold"> {schoolName |> str} </span>
  };

let editIcon = (additionalClasses, clickHandler, title) =>
  <div
    className={
      "cursor-pointer bg-primary-100 border border-primary-400 text-primary-500 hover:bg-primary-200 hover:border-primary-500 hover:text-primary-600 px-2 py-1 rounded flex items-center "
      ++ additionalClasses
    }
    title
    onClick=clickHandler>
    <i className="fas fa-pencil-alt text-xs" />
    <span className="text-xs font-semibold ml-2"> {"Edit" |> str} </span>
  </div>;

let showEditor = (editor, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(ShowEditor(editor));
};

let editor = (state, send, authenticityToken) =>
  switch (state.visibleEditor) {
  | Some(editor) =>
    <SchoolAdmin__EditorDrawer.Jsx2 closeDrawerCB={() => send(CloseEditor)}>
      {switch (editor) {
       | LinksEditor(kind) =>
         <SchoolCustomize__LinksEditor
           key="sc-drawer__links-editor"
           kind
           customizations={state.customizations}
           authenticityToken
           addLinkCB={link => send(AddLink(link))}
           removeLinkCB={linkId => send(RemoveLink(linkId))}
         />
       | AgreementsEditor(kind) =>
         <SchoolCustomize__AgreementsEditor
           key="sc-drawer__agreements-editor"
           kind
           customizations={state.customizations}
           updatePrivacyPolicyCB={agreement =>
             send(UpdatePrivacyPolicy(agreement))
           }
           updateTermsOfUseCB={agreement =>
             send(UpdateTermsOfUse(agreement))
           }
           authenticityToken
         />
       | ContactsEditor =>
         <SchoolCustomize__ContactsEditor
           key="sc-drawer__contacts-editor"
           customizations={state.customizations}
           updateAddressCB={address => send(UpdateAddress(address))}
           updateEmailAddressCB={emailAddress =>
             send(UpdateEmailAddress(emailAddress))
           }
           authenticityToken
         />
       | ImagesEditor =>
         <SchoolCustomize__ImagesEditor
           key="sc-drawer__images-editor"
           customizations={state.customizations}
           updateImagesCB={json => send(UpdateImages(json))}
           authenticityToken
         />
       }}
    </SchoolAdmin__EditorDrawer.Jsx2>

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
      <div className="px-6 pt-6 w-full xl:max-w-6xl mx-auto">
        <div className="font-bold"> {"Header" |> str} </div>
        <div
          className="border rounded-lg px-5 py-4 flex justify-between mt-3 shadow">
          <div className="flex items-center bg-gray-200 rounded p-2">
            {headerLogo(
               schoolName,
               state.customizations |> Customizations.logoOnLightBg,
             )}
            {editIcon(
               "ml-6",
               showEditor(ImagesEditor, send),
               "Edit logo (on light backgrounds)",
             )}
          </div>
          <div className="flex items-center">
            <div
              className="school-customize__header-links flex items-center bg-gray-200 rounded px-3 py-2 h-full">
              {headerLinks(
                 state.customizations
                 |> Customizations.headerLinks
                 |> Customizations.unpackLinks,
               )}
              {editIcon(
                 "ml-3",
                 showEditor(
                   LinksEditor(SchoolCustomize__LinksEditor.HeaderLink),
                   send,
                 ),
                 "Edit header links",
               )}
            </div>
          </div>
        </div>
        <div className="mt-6 font-bold"> {"Footer" |> str} </div>
        <div className="mt-3 w-full">
          <div
            className="school-customize__footer-top-container rounded-t-lg text-white p-6 flex">
            <div className="w-1/2">
              <div
                className="p-3 bg-black border border-dashed border-gray-900 rounded h-full mr-2">
                <div className="flex items-center">
                  <span className="uppercase font-bold text-sm">
                    {"Sitemap" |> str}
                  </span>
                  {editIcon(
                     "ml-3",
                     showEditor(
                       LinksEditor(SchoolCustomize__LinksEditor.FooterLink),
                       send,
                     ),
                     "Edit footer links",
                   )}
                </div>
                {sitemap(
                   state.customizations
                   |> Customizations.footerLinks
                   |> Customizations.unpackLinks,
                 )}
              </div>
            </div>
            <div className="w-1/2">
              <div className="flex">
                <div className="w-1/2">
                  <div
                    className="p-3 bg-black border border-dashed border-gray-900 rounded h-full mr-2">
                    <div className="flex items-center">
                      <span className="uppercase font-bold text-sm">
                        {"Social" |> str}
                      </span>
                      {editIcon(
                         "ml-3",
                         showEditor(
                           LinksEditor(
                             SchoolCustomize__LinksEditor.SocialLink,
                           ),
                           send,
                         ),
                         "Edit social media links",
                       )}
                    </div>
                    {socialLinks(
                       state.customizations
                       |> Customizations.socialLinks
                       |> Customizations.unpackLinks,
                     )}
                  </div>
                </div>
                <div className="w-1/2">
                  <div
                    className="p-3 bg-black border border-dashed border-gray-900 rounded h-full">
                    <div className="flex items-center">
                      <span className="uppercase font-bold text-sm">
                        {"Contact" |> str}
                      </span>
                      {editIcon(
                         "ml-3",
                         showEditor(ContactsEditor, send),
                         "Edit contact details",
                       )}
                    </div>
                    {address(state.customizations |> Customizations.address)}
                    {emailAddress(
                       state.customizations |> Customizations.emailAddress,
                     )}
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            className="school-customize__footer-bottom-container rounded-b-lg text-white p-6 flex justify-between">
            <div
              className="flex items-center bg-black border border-dashed border-gray-900 rounded p-2">
              {footerLogo(
                 schoolName,
                 state.customizations |> Customizations.logoOnDarkBg,
               )}
              {editIcon(
                 "ml-3",
                 showEditor(ImagesEditor, send),
                 "Edit logo (on dark backgrounds)",
               )}
            </div>
            <div className="flex items-center text-sm">
              <div
                className="flex items-center bg-black border border-dashed border-gray-900 rounded p-2">
                <div> {"Privacy Policy" |> str} </div>
                {editIcon(
                   "ml-3",
                   showEditor(
                     AgreementsEditor(
                       SchoolCustomize__AgreementsEditor.PrivacyPolicy,
                     ),
                     send,
                   ),
                   "Edit privacy policy",
                 )}
              </div>
              <div
                className="flex items-center bg-black border border-dashed border-gray-900 rounded p-2 ml-6">
                <div> {"Terms of Use" |> str} </div>
                {editIcon(
                   "ml-3",
                   showEditor(
                     AgreementsEditor(
                       SchoolCustomize__AgreementsEditor.TermsOfUse,
                     ),
                     send,
                   ),
                   "Edit terms of use",
                 )}
              </div>
              <div className="ml-6 flex items-center">
                <i className="far fa-copyright" />
                <span className="ml-1">
                  {(
                     Js.Date.make()
                     |> Js.Date.getFullYear
                     |> int_of_float
                     |> string_of_int
                   )
                   ++ " "
                   ++ schoolName
                   |> str}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div className="mt-6 font-bold"> {"Icon" |> str} </div>
        <div className="mt-3 w-2/4 max-w-sm">
          <div className="bg-gray-400 rounded-t-lg h-12 flex items-end">
            <div className="w-full flex items-center pr-3">
              <div className="h-3 w-3 rounded-full bg-gray-500 ml-4" />
              <div className="h-3 w-3 rounded-full bg-gray-500 ml-2" />
              <div className="h-3 w-3 rounded-full bg-gray-500 ml-2" />
              <div
                className="p-3 ml-4 bg-gray-100 rounded-t-lg flex items-center">
                <img
                  src={
                    state.customizations
                    |> Customizations.icon
                    |> Customizations.url
                  }
                  className="h-5 w-5"
                />
                <span className="ml-1 text-sm font-semibold">
                  {schoolName |> str}
                </span>
              </div>
              {editIcon("ml-2", showEditor(ImagesEditor, send), "Edit icon")}
            </div>
          </div>
          <div className="bg-gray-100 border border-t-0 h-16 rounded-b-lg" />
        </div>
      </div>
      {editor(state, send, authenticityToken)}
    </div>,
};
