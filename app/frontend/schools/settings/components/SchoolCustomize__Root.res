open SchoolCustomize__Types
open ThemeSwitch

%%raw(`import "./SchoolCustomize__Root.css"`)

let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__Root")
let ts = I18n.ts

type editor =
  | LinksEditor(SchoolCustomize__LinkComponent.kind)
  | DetailsEditor
  | ImagesEditor
  | ContactsEditor
  | AgreementsEditor(SchoolCustomize__AgreementsEditor.kind)

type state = {
  visibleEditor: option<editor>,
  customizations: Customizations.t,
  schoolName: string,
  schoolAbout: option<string>,
}

type rec action =
  | ShowEditor(editor)
  | CloseEditor
  | AddLink(Customizations.link)
  | RemoveLink(Customizations.linkId)
  | UpdateLink(Customizations.linkId, string, Customizations.url)
  | MoveLink(Customizations.linkId, SchoolCustomize__LinkComponent.kind, Customizations.direction)
  | UpdateTermsAndConditions(string)
  | UpdatePrivacyPolicy(string)
  | UpdateCodeOfConduct(string)
  | UpdateAddress(string)
  | UpdateEmailAddress(string)
  | UpdateSchoolDetails(name, about)
  | UpdateImages(Js.Json.t)

and name = string
and about = option<string>

let renderLogo = (schoolName, logo, textSize, logoHeight) =>
  switch logo {
  | Some(logo) => <img className={logoHeight ++ " block"} src={logo->Customizations.url} />
  | None => <span className={textSize ++ " font-bold"}> {schoolName->str} </span>
  }

let headerLink = ((id, title, _, _)) =>
  <div className="ms-6 text-sm font-semibold cursor-default" key=id>
    <span> {title->str} </span>
  </div>

let headerLinks = links => {
  let (visibleLinks, dropdownLinks) =
    links->Js.Array2.length > 4
      ? (links->Js.Array2.slice(~start=0, ~end_=3), links->Js.Array2.sliceFrom(3))
      : (links, [])

  switch visibleLinks {
  | [] =>
    <div
      className="border border-gray-300 rounded-lg italic text-gray-600 cursor-default text-sm py-2 px-4">
      {t("customize_link_header")->str}
    </div>
  | visibleLinks =>
    visibleLinks
    ->Js.Array2.map(l => headerLink(l))
    ->Js.Array2.concat([<SchoolCustomize__MoreLinks links=dropdownLinks key="more-links" />])
    ->React.array
  }
}

let sitemap = links =>
  switch links {
  | [] =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-3 py-2 px-4">
      {t("customize_link_footer")->str}
    </div>
  | links =>
    <div className="flex flex-wrap">
      {links
      ->Js.Array2.map(((id, title, _, _)) =>
        <div className="w-1/3 pe-4 mt-3 text-xs font-semibold break-words" key=id>
          {title->str}
        </div>
      )
      ->React.array}
    </div>
  }

let socialLinks = links =>
  switch links {
  | [] =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-3 py-2 px-4">
      {t("social_links_q")->str}
    </div>
  | links =>
    <div className="flex flex-wrap">
      {links
      ->Js.Array2.map(((id, _title, url, _)) => <SchoolCustomize__SocialLink url key=id />)
      ->React.array}
    </div>
  }

let address = a =>
  switch a {
  | Some(a) =>
    <div
      className="text-xs font-semibold mt-3 leading-normal break-words"
      dangerouslySetInnerHTML={Markdown.toSafeHTML(a, Markdown.Permissive)}
    />
  | None =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-3 py-2 px-4">
      {t("add_address_q")->str}
    </div>
  }

let emailAddress = email =>
  switch email {
  | Some(email) =>
    <div className="text-xs font-semibold mt-4">
      {(t("reach_us_at") ++ ": ")->str}
      <span className="font-bold"> {email->str} </span>
    </div>
  | None =>
    <div
      className="border border-gray-500 rounded-lg italic text-gray-400 cursor-default text-sm max-w-fc mt-4 py-2 px-4">
      {t("add_contact_email_q")->str}
    </div>
  }

let editIcon = (additionalClasses, clickHandler, title) =>
  <button
    className={"cursor-pointer px-2 py-1 bg-primary-100 border border-primary-400 text-primary-500 hover:bg-primary-200 hover:border-primary-500 hover:text-primary-600 focus:bg-primary-200 focus:border-primary-500 focus:text-primary-600px rounded flex items-center " ++
    additionalClasses}
    title
    ariaLabel=title
    onClick=clickHandler>
    <i className="fas fa-pencil-alt text-xs" />
    <span className="text-xs font-semibold ms-2"> {ts("edit")->str} </span>
  </button>

let showEditor = (editor, send, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send(ShowEditor(editor))
}

let editor = (state, send, authenticityToken) =>
  switch state.visibleEditor {
  | Some(editor) =>
    <SchoolAdmin__EditorDrawer closeDrawerCB={() => send(CloseEditor)}>
      {switch editor {
      | LinksEditor(kind) =>
        <SchoolCustomize__LinksEditor
          key="sc-drawer__links-editor"
          kind
          customizations=state.customizations
          addLinkCB={link => send(AddLink(link))}
          moveLinkCB={(id, kind, direction) => send(MoveLink(id, kind, direction))}
          removeLinkCB={linkId => send(RemoveLink(linkId))}
          updateLinkCB={(linkId, title, url) => send(UpdateLink(linkId, title, url))}
        />
      | AgreementsEditor(kind) =>
        <SchoolCustomize__AgreementsEditor
          key="sc-drawer__agreements-editor"
          kind
          customizations=state.customizations
          updatePrivacyPolicyCB={agreement => send(UpdatePrivacyPolicy(agreement))}
          updateTermsAndConditionsCB={agreement => send(UpdateTermsAndConditions(agreement))}
          updateCodeOfConductCB={agreement => send(UpdateTermsAndConditions(agreement))}
        />
      | ContactsEditor =>
        <SchoolCustomize__ContactsEditor
          key="sc-drawer__contacts-editor"
          customizations=state.customizations
          updateAddressCB={address => send(UpdateAddress(address))}
          updateEmailAddressCB={emailAddress => send(UpdateEmailAddress(emailAddress))}
        />
      | ImagesEditor =>
        <SchoolCustomize__ImagesEditor
          key="sc-drawer__images-editor"
          customizations=state.customizations
          updateImagesCB={json => send(UpdateImages(json))}
          authenticityToken
        />
      | DetailsEditor =>
        <SchoolCustomize__DetailsEditor
          name=state.schoolName
          about=state.schoolAbout
          updateDetailsCB={(name, about) => send(UpdateSchoolDetails(name, about))}
        />
      }}
    </SchoolAdmin__EditorDrawer>

  | None => React.null
  }

let initialState = (customizations, schoolName, schoolAbout) => {
  visibleEditor: None,
  customizations,
  schoolName,
  schoolAbout,
}

let moveLink = (t, linkId, kind, direction) => {
  // find links of similar kind
  let similarKindLinks = switch kind {
  | SchoolCustomize__LinkComponent.HeaderLink => Customizations.filterLinks(~header=true, t)
  | SocialLink => Customizations.filterLinks(~social=true, t)
  | FooterLink => Customizations.filterLinks(~footer=true, t)
  }

  let linkIndex =
    similarKindLinks
    ->Js.Array2.map(l =>
      switch l {
      | HeaderLink(id, _, _, _)
      | FooterLink(id, _, _, _)
      | SocialLink(id, _, _) => id
      }
    )
    ->Js.Array2.indexOf(linkId)

  // swap links
  let swapedLinks = similarKindLinks->switch direction {
  | Customizations.Up => ArrayUtils.swapUp(linkIndex)
  | Down => ArrayUtils.swapDown(linkIndex)
  }
  // find links of different kind
  let differentKindLinks = switch kind {
  | HeaderLink => Customizations.filterLinks(~social=true, ~footer=true, t)
  | SocialLink => Customizations.filterLinks(~header=true, ~footer=true, t)
  | FooterLink => Customizations.filterLinks(~social=true, ~header=true, t)
  }

  // combile links
  let updatedLinks = differentKindLinks->Js.Array2.concat(swapedLinks)
  {
    ...t,
    links: updatedLinks,
  }
}

let reducer = (state, action) =>
  switch action {
  | ShowEditor(editor) => {...state, visibleEditor: Some(editor)}
  | CloseEditor => {...state, visibleEditor: None}
  | AddLink(link) => {
      ...state,
      customizations: state.customizations->Customizations.addLink(link),
    }
  | UpdateLink(linkId, title, url) => {
      ...state,
      customizations: state.customizations->Customizations.updateLink(linkId, title, url),
    }
  | RemoveLink(linkId) => {
      ...state,
      customizations: state.customizations->Customizations.removeLink(linkId),
    }
  | MoveLink(id, kind, direction) => {
      ...state,
      customizations: state.customizations->moveLink(id, kind, direction),
    }
  | UpdatePrivacyPolicy(agreement) => {
      ...state,
      customizations: state.customizations->Customizations.updatePrivacyPolicy(agreement),
    }
  | UpdateTermsAndConditions(agreement) => {
      ...state,
      customizations: state.customizations->Customizations.updateTermsAndConditions(agreement),
    }
  | UpdateCodeOfConduct(agreement) => {
      ...state,
      customizations: state.customizations->Customizations.updateCodeOfConduct(agreement),
    }
  | UpdateAddress(address) => {
      ...state,
      customizations: state.customizations->Customizations.updateAddress(address),
    }
  | UpdateEmailAddress(emailAddress) => {
      ...state,
      customizations: state.customizations->Customizations.updateEmailAddress(emailAddress),
    }
  | UpdateImages(json) => {
      ...state,
      customizations: state.customizations->Customizations.updateImages(json),
      visibleEditor: None,
    }
  | UpdateSchoolDetails(schoolName, schoolAbout) => {
      ...state,
      schoolName,
      schoolAbout,
      visibleEditor: None,
    }
  }

let about = state =>
  switch state.schoolAbout {
  | Some(about) => about
  | None => t("add_more_details")
  }

@react.component
let make = (~authenticityToken, ~customizations, ~schoolName, ~schoolAbout) => {
  let (state, send) = React.useReducer(
    reducer,
    initialState(customizations, schoolName, schoolAbout),
  )

  let logo =
    getTheme() == "light"
      ? state.customizations->Customizations.logoOnLightBg
      : state.customizations->Customizations.logoOnDarkBg

  <div className="bg-gray-50 min-h-full">
    <div className="px-6 py-6 w-full xl:max-w-6xl mx-auto">
      <h1 className="font-bold"> {t("homepage")->str} </h1>
      <div className="border rounded-t-lg px-5 py-4 flex justify-between mt-3">
        <div className="flex items-center bg-gray-50 rounded p-2">
          <div className="max-w-xs"> {renderLogo(schoolName, logo, "2xl", "h-12")} </div>
          {editIcon("ms-6", showEditor(ImagesEditor, send), t("edit_logo_light"))}
        </div>
        <div className="flex items-center">
          <div
            className="school-customize__header-links flex items-center bg-gray-50 rounded px-3 py-2 h-full">
            {headerLinks(
              state.customizations
              |> Customizations.filterLinks(~header=true)
              |> Customizations.unpackLinks,
            )}
            {editIcon("ms-3", showEditor(LinksEditor(HeaderLink), send), t("edit_header_links"))}
          </div>
        </div>
      </div>
      <div className="relative bg-gray-200 rounded-lg">
        <div className="absolute end-0 z-10 pt-3 pe-3 ">
          <button
            ariaLabel="Change cover"
            className="flex items-center text-xs bg-primary-100 text-primary-500 border border-primary-400 hover:bg-primary-200 hover:border-primary-500 hover:text-primary-600 focus:bg-primary-200 focus:border-primary-500 focus:text-primary-600px px-2 py-1 cursor-pointer rounded"
            onClick={showEditor(ImagesEditor, send)}>
            <i className="fas fa-pencil-alt" />
            <span className="font-semibold ms-2"> {t("change_cover")->str} </span>
          </button>
        </div>
        <div className="relative pb-1/2 md:pb-1/4 rounded-b-lg overflow-hidden">
          {switch state.customizations->Customizations.coverImage {
          | Some(image) =>
            <img className="absolute h-full w-full object-cover" src={image->Customizations.url} />
          | None =>
            <div
              className="school-customize__cover-default absolute h-full w-full svg-bg-pattern-6"
            />
          }}
        </div>
      </div>
      <div
        className="school-customize__about max-w-3xl relative mx-auto bg-primary-900 shadow-xl rounded-lg -mt-7">
        <div
          className="relative mx-auto flex flex-col justify-center items-center text-white p-10 text-center">
          <p> {t("hello_welcome")->str} </p>
          <div onClick={showEditor(DetailsEditor, send)}>
            <h1
              className="flex items-center border border-dashed border-gray-800 hover:border-primary-300 hover:text-primary-200 focus-within:border-primary-300 focus-within:text-primary-200 cursor-text rounded px-2 py-1 text-3xl mt-1">
              <span> {state.schoolName->str} </span>
              <button
                ariaLabel="Edit School name"
                className="flex items-center text-xs bg-primary-100 text-primary-500 border border-primary-400 hover:bg-primary-200 hover:border-primary-500 hover:text-primary-600 p-1 ms-1 cursor-pointer rounded"
                onClick={showEditor(DetailsEditor, send)}>
                <i className="fas fa-pencil-alt" />
              </button>
            </h1>
          </div>
          <div
            onClick={showEditor(DetailsEditor, send)}
            className="w-full max-w-2xl mt-2 relative flex items-center justify-center border border-dashed border-gray-800 rounded px-8 py-5 hover:border-primary-300 hover:text-primary-200 focus-within:border-primary-300 focus-within:text-primary-200 cursor-text">
            <div className="absolute end-0 top-0 z-10 pt-2 pe-2">
              <button
                ariaLabel={t("edit_school_details")}
                className="flex items-center text-xs bg-primary-100 text-primary-500 border border-primary-400 hover:bg-primary-200 hover:border-primary-500 hover:text-primary-600 p-1 cursor-pointer rounded">
                <i className="fas fa-pencil-alt" />
              </button>
            </div>
            <div className="text-sm">
              <MarkdownBlock profile=Markdown.AreaOfText markdown={about(state)} />
            </div>
          </div>
        </div>
      </div>
      <div className="mx-auto text-center pt-8 mt-8">
        <h2 className="school-customize__featured-courses-header relative text-2xl font-bold">
          {t("featured_courses")->str}
        </h2>
        <div className="text-sm"> {"Featured courses will be listed here"->str} </div>
        <div className="max-w-2xl bg-gray-50 rounded-lg mx-auto p-3 mt-4">
          <div className="school-customize__featured-courses-empty-placeholder" />
        </div>
      </div>
      <div className="mt-8 w-full">
        <div className="school-customize__footer-top-container rounded-t-lg p-6 flex">
          <div className="w-2/5">
            <div
              className="p-3 bg-gray-100 border border-dashed border-gray-500 rounded h-full me-2">
              <div className="flex items-center">
                <span className="uppercase font-bold text-sm"> {t("sitemap")->str} </span>
                {editIcon(
                  "ms-3",
                  showEditor(LinksEditor(FooterLink), send),
                  t("edit_footer_links"),
                )}
              </div>
              {sitemap(
                state.customizations
                |> Customizations.filterLinks(~footer=true)
                |> Customizations.unpackLinks,
              )}
            </div>
          </div>
          <div className="w-3/5">
            <div className="flex">
              <div className="w-3/5">
                <div
                  className="p-3 bg-gray-100 border border-dashed border-gray-500 rounded h-full me-2">
                  <div className="flex items-center">
                    <span className="uppercase font-bold text-sm"> {t("social")->str} </span>
                    {editIcon(
                      "ms-3",
                      showEditor(LinksEditor(SocialLink), send),
                      t("edit_social_links"),
                    )}
                  </div>
                  {socialLinks(
                    state.customizations
                    ->Customizations.filterLinks(~social=true)
                    ->Customizations.unpackLinks,
                  )}
                </div>
              </div>
              <div className="w-2/5">
                <div
                  className="p-3 bg-gray-100 border border-dashed border-gray-500 rounded h-full">
                  <div className="flex items-center">
                    <span className="uppercase font-bold text-sm"> {t("contact")->str} </span>
                    {editIcon("ms-3", showEditor(ContactsEditor, send), t("edit_contact_details"))}
                  </div>
                  {address(state.customizations |> Customizations.address)}
                  {emailAddress(state.customizations |> Customizations.emailAddress)}
                </div>
              </div>
            </div>
          </div>
        </div>
        <div
          className="school-customize__footer-bottom-container rounded-b-lg p-6 flex justify-between">
          <div className="flex items-center border border-dashed border-gray-500 rounded p-2">
            {renderLogo(schoolName, logo, "text-lg", "h-8")}
            {editIcon("ms-3", showEditor(ImagesEditor, send), t("edit_logo_dark"))}
          </div>
          <div className="flex items-center text-sm">
            <div
              className="flex items-center border border-dashed border-gray-500 rounded p-2 text-xs">
              <div> {t("privacy_policy")->str} </div>
              {editIcon(
                "ms-3",
                showEditor(AgreementsEditor(SchoolCustomize__AgreementsEditor.PrivacyPolicy), send),
                t("edit_privacy"),
              )}
            </div>
            <div
              className="flex items-center border border-dashed border-gray-500 rounded p-2 ms-6 text-xs">
              <div> {t("terms_and_conditions")->str} </div>
              {editIcon(
                "ms-3",
                showEditor(
                  AgreementsEditor(SchoolCustomize__AgreementsEditor.TermsAndConditions),
                  send,
                ),
                t("edit_terms"),
              )}
            </div>
            <div
              className="flex items-center border border-dashed border-gray-500 rounded p-2 ms-6 text-xs">
              <div> {ts("code_of_conduct")->str} </div>
              {editIcon(
                "ms-3",
                showEditor(AgreementsEditor(SchoolCustomize__AgreementsEditor.CodeOfConduct), send),
                t("edit_code_of_conduct"),
              )}
            </div>
            <div className="ms-6 flex items-center text-xs text-gray-600">
              <i className="far fa-copyright" />
              <span className="ms-1">
                {(Js.Date.make()->Js.Date.getFullYear->int_of_float->string_of_int ++
                  (" " ++
                  schoolName))->str}
              </span>
            </div>
          </div>
        </div>
      </div>
      <div className="mt-6 font-bold"> {t("icon")->str} </div>
      <div className="mt-3 w-1/2 max-w-sm">
        <div className="bg-gray-300 rounded-t-lg h-12 flex items-end">
          <div className="w-full flex items-center pe-3">
            <div className="h-3 w-3 rounded-full bg-gray-500 ms-4" />
            <div className="h-3 w-3 rounded-full bg-gray-500 ms-2" />
            <div className="h-3 w-3 rounded-full bg-gray-500 ms-2" />
            <div className="p-3 ms-4 bg-gray-50 rounded-t-lg flex items-center">
              <img
                src={state.customizations->Customizations.iconOnLightBg->Customizations.url}
                className="h-5 w-5 block dark:hidden"
              />
              <img
                src={state.customizations->Customizations.iconOnDarkBg->Customizations.url}
                className="h-5 w-5 hidden dark:block"
              />
              <span className="ms-1 text-xs font-semibold max-w-xs truncate">
                {schoolName->str}
              </span>
            </div>
            {editIcon("ms-2", showEditor(ImagesEditor, send), t("edit_icon"))}
          </div>
        </div>
        <div className="bg-gray-50 border border-t-0 h-16 rounded-b-lg" />
      </div>
    </div>
    {editor(state, send, authenticityToken)}
  </div>
}
