%%raw(`import "./StudentTopNav.css"`)

let t = I18n.t(~scope="components.StudentTopNav")

let str = React.string

open StudentTopNav__Types

let headerLink = (key, link) =>
  <div
    key
    className="md:ms-2 text-sm font-medium text-center cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-e border-b md:border-0">
    <a
      className="whitespace-nowrap no-underline bg-gray-50 md:bg-white hover:bg-gray-50 text-gray-900 rounded-lg hover:text-primary-500 w-full p-4 md:px-3 md:py-2 focus:outline-none focus:bg-gray-50 focus:text-primary-500"
      href={link |> NavLink.url}
      target=?{NavLink.local(link) ? None : Some("_blank")}
      rel=?{NavLink.local(link) ? None : Some("noopener")}>
      {link |> NavLink.title |> str}
    </a>
  </div>

let signOutLink = () =>
  <div
    key="Logout-button"
    className="md:ms-2 text-sm font-semibold cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-e border-b md:border-0">
    <div className="flex items-center justify-center">
      <a
        href="/users/sign_out"
        rel="nofollow"
        className="border border-primary-500 rounded px-2 py-1 text-primary-500 text-xs md:text-sm md:leading-normal m-4 md:m-0 no-underline font-semibold">
        <FaIcon classes="fas fa-power-off" />
        <span className="ms-2"> {t("sign_out") |> str} </span>
      </a>
    </div>
  </div>

let editProfileLink = () =>
  <div
    key="edit-profile-button"
    className="md:ms-2 text-sm font-medium text-center cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-e border-b md:border-0">
    <a
      href="/user/edit"
      rel="nofollow"
      className="whitespace-nowrap no-underline bg-gray-50 md:bg-white hover:bg-gray-50 text-gray-900 rounded-lg hover:text-primary-500 w-full p-4 md:px-3 md:py-2 focus:outline-none focus:bg-gray-50 focus:text-primary-500">
      <span className="ms-2"> {t("edit_profile")->str} </span>
    </a>
  </div>

let signInLink = () =>
  <div
    key="SignIn-button"
    className="md:ms-2 text-sm font-semibold cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-e border-b md:border-0">
    <div className="flex items-center justify-center">
      <a
        className="border border-primary-500 rounded px-2 py-1 text-primary-500 text-xs md:text-sm md:leading-normal m-4 md:m-0 no-underline font-semibold"
        href="/users/sign_in">
        <FaIcon classes="fas fa-power-off" />
        <span className="ms-2"> {t("sign_in") |> str} </span>
      </a>
    </div>
  </div>

let notificationButton = hasNotifications =>
  <Notifications__Root
    key="notifications-button"
    wrapperClasses="relative md:ms-1 pt-1 md:pt-0 text-sm font-semibold cursor-default flex w-8 h-8 md:w-9 md:h-9 justify-center items-center rounded-lg hover:bg-gray-50"
    iconClasses="student-navbar__notifications-unread-bullet"
    buttonClasses="font-semibold text-gray-900 hover:text-primary-500 w-full flex items-center justify-center focus:text-primary-500 "
    hasNotifications
  />

let isMobile = () => Webapi.Dom.window |> Webapi.Dom.Window.innerWidth < 768

let headerLinks = (links, isLoggedIn, user, hasNotifications) => {
  let (visibleLinks, dropdownLinks) = switch (Array.to_list(links), isMobile()) {
  | (links, true) => (Array.of_list(links), [])
  | (list{l1, l2, l3, l4, l5, ...rest}, false) => (
      [l1, l2, l3],
      Js.Array.concat(Array.of_list(rest), [l4, l5]),
    )
  | (fourOrLessLinks, false) => (Array.of_list(fourOrLessLinks), [])
  }

  switch visibleLinks {
  | visibleLinks =>
    visibleLinks
    |> Js.Array.mapi((l, index) => headerLink(index |> string_of_int, l))
    |> Js.Array.concat([<StudentTopNav__DropDown links=dropdownLinks key="more-links" />])
    |> Js.Array.concat([
      ReactUtils.nullUnless(notificationButton(hasNotifications), isLoggedIn && !isMobile()),
    ])
    |> Js.Array.concat([ReactUtils.nullUnless(editProfileLink(), isLoggedIn && isMobile())])
    |> Js.Array.concat([
      switch (isLoggedIn, isMobile()) {
      | (true, true) => signOutLink()
      | (true, false) => <StudentTopNav__UserControls user key="user-controls" />
      | (false, true)
      | (false, false) =>
        signInLink()
      },
    ])
    |> React.array
  }
}

let renderLogo = (logoUrl, schoolName, additionalClasses) =>
  switch logoUrl {
  | Some(url) =>
    <img
      className={"h-8 md:h-10 object-contain flex text-sm items-center " ++ additionalClasses}
      src=url
      alt={"Logo of " ++ schoolName}
    />
  | None =>
    <div
      className={"p-2 rounded-lg bg-white text-gray-900 hover:bg-gray-50 hover:text-primary-600 " ++
      additionalClasses}>
      <span className="text-xl font-bold leading-tight"> {schoolName->str} </span>
    </div>
  }

@react.component
let make = (
  ~schoolName,
  ~logoOnLightBgUrl,
  ~logoOnDarkBgUrl,
  ~links,
  ~isLoggedIn,
  ~currentUser,
  ~hasNotifications,
) => {
  let (menuHidden, toggleMenuHidden) = React.useState(() => isMobile())

  React.useEffect(() => {
    let resizeCB = _ => toggleMenuHidden(_ => isMobile())
    Webapi.Dom.Window.asEventTarget(Webapi.Dom.window)->Webapi.Dom.EventTarget.addEventListener(
      "resize",
      resizeCB,
    )
    None
  })

  <div className="border-b">
    <div className="mx-auto p-4">
      <nav className="flex justify-between items-center">
        <div className="flex w-full items-center justify-between">
          <a className="max-w-sm focus:outline-none" href={isLoggedIn ? "/dashboard" : "/"}>
            {renderLogo(logoOnLightBgUrl, schoolName, "logo_on_light_bg")}
            {renderLogo(logoOnDarkBgUrl, schoolName, "logo_on_dark_bg")}
          </a>
          {ReactUtils.nullUnless(
            <div className="flex items-center space-x-2">
              {ReactUtils.nullUnless(notificationButton(hasNotifications), isLoggedIn)}
              <div onClick={_ => toggleMenuHidden(menuHidden => !menuHidden)}>
                <div
                  className={"student-navbar__menu-btn cursor-pointer hover:bg-gray-50 w-8 h-8 text-center relative focus:outline-none rounded-lg " ++ (
                    menuHidden ? "" : "open"
                  )}>
                  <span className="student-navbar__menu-icon">
                    <span className="student-navbar__menu-icon-bar" />
                  </span>
                </div>
              </div>
            </div>,
            isMobile(),
          )}
        </div>
        {!menuHidden && !isMobile()
          ? <div
              className="student-navbar__links-container flex justify-end items-center w-3/5 lg:w-3/4 flex-nowrap shrink-0">
              {headerLinks(links, isLoggedIn, currentUser, hasNotifications)}
            </div>
          : React.null}
      </nav>
    </div>
    {isMobile() && !menuHidden
      ? <div
          className="student-navbar__links-container flex flex-row border-t w-full flex-wrap shadow-lg">
          {headerLinks(links, isLoggedIn, currentUser, hasNotifications)}
        </div>
      : React.null}
  </div>
}
