%%raw(`import "./AppRouter__Header.css"`)

open AppRouter__Types

let str = React.string

let t = I18n.t(~scope="components.AppRouter__Header")

let showLink = (icon, text, href) => {
  <div key=href className="whitespace-nowrap">
    <a
      rel="nofollow"
      className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} /> <span className="ps-2 "> {str(text)} </span>
    </a>
  </div>
}

let links = () => {
  [
    showLink("edit", t("edit_profile"), "/user/edit"),
    showLink("power-off", t("sign_out"), "/users/sign_out"),
  ]
}

let selected = user => {
  <button
    title="Show user controls"
    className="md:hidden md:ms-2 h-10 w-10 rounded-full border-2 border-gray-300 hover:border-primary-500 focus:border-primary-500">
    {User.avatarUrl(user)->Belt.Option.mapWithDefault(
      <Avatar
        name={User.name(user)} className="inline-block object-contain rounded-full text-tiny"
      />,
      src =>
        <img
          className="inline-block object-contain rounded-full text-tiny" src alt={User.name(user)}
        />,
    )}
  </button>
}

let renderLinks = user => {
  <Dropdown2 selected={selected(user)} contents={links()} right=true key="links-dropdown" />
}

let headerLink = (key, link) =>
  <div
    key
    className="md:ms-2 text-sm font-semibold text-center cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center">
    <a
      className="no-underline bg-gray-50 md:bg-white hover:bg-gray-50 text-gray-900 rounded-lg hover:text-primary-500 w-full p-4 md:px-3 md:py-2"
      href={link->School.linkUrl}
      target=?{School.localLinks(link) ? None : Some("_blank")}
      rel=?{School.localLinks(link) ? None : Some("noopener")}>
      {School.linkTitle(link)->str}
    </a>
  </div>

let signOutLink = () =>
  <div
    key="Logout-button"
    className="md:ms-2 text-sm font-semibold cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center">
    <div className="flex items-center justify-center">
      <a
        href="/users/sign_out"
        rel="nofollow"
        className="border border-primary-500 rounded px-2 py-1 text-primary-500 text-xs md:text-sm md:leading-normal m-4 md:m-0 no-underline font-semibold">
        <FaIcon classes="fas fa-power-off" />
        <span className="ms-2"> {t("sign_out")->str} </span>
      </a>
    </div>
  </div>

let signInLink = () =>
  <div
    key="SignIn-button"
    className="md:ms-2 text-sm font-semibold cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center">
    <div className="flex items-center justify-center">
      <a
        className="border border-primary-500 rounded px-2 py-1 text-primary-500 text-xs md:text-sm md:leading-normal m-4 md:m-0 no-underline font-semibold"
        href="/users/sign_in">
        <FaIcon classes="fas fa-power-off" />
        <span className="ms-2"> {t("sign_in")->str} </span>
      </a>
    </div>
  </div>

let notificationButton = hasNotifications =>
  <Notifications__Root
    key="notifications-button"
    wrapperClasses="relative md:ms-1 pt-1 md:pt-0 text-sm font-semibold cursor-default flex w-8 h-8 md:w-9 md:h-9 justify-center items-center rounded-lg hover:bg-gray-50"
    iconClasses="app-router-header__notifications-unread-bullet"
    buttonClasses="font-semibold text-gray-900 hover:text-primary-500 w-full flex items-center justify-center "
    hasNotifications
  />

let isMobile = () => Webapi.Dom.Window.innerWidth(Webapi.Dom.window) < 768

let headerLinks = (links, isLoggedIn, user, hasNotifications) => {
  let (visibleLinks, dropdownLinks) = switch (Array.to_list(links), isMobile()) {
  | (links, true) => (Array.of_list(links), [])
  | (list{l1, l2, l3, l4, l5, ...rest}, false) => (
      [l1, l2, l3],
      Js.Array.concat(Array.of_list(rest), [l4, l5]),
    )
  | (fourOrLessLinks, false) => (Array.of_list(fourOrLessLinks), [])
  }

  visibleLinks
  ->Js.Array2.mapi((l, index) => headerLink(string_of_int(index), l))
  ->Js.Array2.concat([<AppRouter__Dropdown links=dropdownLinks key="more-links" />])
  ->Js.Array2.concat([
    ReactUtils.nullUnless(notificationButton(hasNotifications), isLoggedIn && !isMobile()),
  ])
  ->Js.Array2.concat([
    switch (user, isMobile()) {
    | (Some(_), true) => signOutLink()
    | (Some(user), false) => renderLinks(user)
    | (None, true)
    | (None, false) =>
      signInLink()
    },
  ])
  ->React.array
}

@react.component
let make = (~school, ~currentUser) => {
  let (menuHidden, toggleMenuHidden) = React.useState(() => isMobile())

  React.useEffect(() => {
    let resizeCB = _ => toggleMenuHidden(_ => isMobile())
    Webapi.Dom.Window.asEventTarget(Webapi.Dom.window)->Webapi.Dom.EventTarget.addEventListener(
      "resize",
      resizeCB
    )
    None
  })

  let isLoggedIn = Belt.Option.isSome(currentUser)
  let hasNotifications = Belt.Option.mapWithDefault(currentUser, false, User.hasNotifications)

  <div>
    <div className="mx-auto">
      <nav className="flex justify-between items-center">
        <div className="flex w-full items-center justify-between">
          <a
            className="max-w-sm focus-within:outline-none"
            href={Belt.Option.isSome(currentUser) ? "/dashboard" : "/"}>
            {switch School.logoUrl(school) {
            | Some(url) =>
              <img
                className="h-9 md:h-12 object-contain flex text-sm items-center"
                src=url
                alt={"Logo of " ++ School.name(school)}
              />
            | None =>
              <div
                className="p-2 rounded-lg bg-white text-gray-900 hover:bg-gray-50 hover:text-primary-600">
                <span className="text-xl font-bold leading-tight">
                  {School.name(school)->str}
                </span>
              </div>
            }}
          </a>
          {ReactUtils.nullUnless(
            <div className="flex items-center space-x-2">
              {ReactUtils.nullUnless(notificationButton(hasNotifications), isLoggedIn)}
              <div onClick={_ => toggleMenuHidden(menuHidden => !menuHidden)}>
                <div
                  className={"app-router-header__menu-btn cursor-pointer hover:bg-gray-50 w-8 h-8 text-center relative focus:outline-none rounded-lg " ++ (
                    menuHidden ? "" : "open"
                  )}>
                  <span className="app-router-header__menu-icon">
                    <span className="app-router-header__menu-icon-bar" />
                  </span>
                </div>
              </div>
            </div>,
            isMobile(),
          )}
        </div>
        {!menuHidden && !isMobile()
          ? <div
              className="relative flex justify-end items-center w-3/5 lg:w-3/4 flex-nowrap shrink-0 transition">
              {headerLinks(School.links(school), isLoggedIn, currentUser, hasNotifications)}
              <Layout__UserControls user={currentUser} />
            </div>
          : React.null}
      </nav>
    </div>
    {isMobile() && !menuHidden
      ? <div
          className="relative mt-2 flex flex-row w-full flex-wrap bg-gray-50 rounded-lg shadow-lg transition">
          {headerLinks(School.links(school), isLoggedIn, currentUser, hasNotifications)}
        </div>
      : React.null}
  </div>
}
