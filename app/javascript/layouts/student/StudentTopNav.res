%bs.raw(`require("./StudentTopNav.css")`)

let t = I18n.t(~scope="components.StudentTopNav")

let str = React.string

open StudentTopNav__Types

let headerLink = (key, link) =>
  <div
    key
    className="md:ml-2 text-sm font-semibold text-center cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-r border-b md:border-0 text-gray-100 hover:text-white">
    <a
      className="no-underline hover:underline rounded-lg w-full p-4 md:px-3 md:py-2"
      href={link |> NavLink.url}
      target=?{NavLink.local(link) ? None : Some("_blank")}
      rel=?{NavLink.local(link) ? None : Some("noopener")}>
      {link |> NavLink.title |> str}
    </a>
  </div>

let signOutLink = () =>
  <div
    key="Logout-button"
    className="md:ml-2 text-sm font-semibold cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-r border-b md:border-0 text-gray-100 hover:text-white">
    <div className="flex items-center justify-center">
      <a
        href="/users/sign_out"
        rel="nofollow"
        className="rounded px-2 py-1 text-xs md:text-sm md:leading-normal m-4 md:m-0 no-underline font-semibold hover:underline">
        <FaIcon classes="fas fa-power-off" /> <span className="ml-2"> {t("sign_out") |> str} </span>
      </a>
    </div>
  </div>

let signInLink = () =>
  <div
    key="SignIn-button"
    className="md:ml-2 text-sm font-semibold cursor-default flex w-1/2 sm:w-1/3 md:w-auto justify-center border-r border-b md:border-0 text-gray-100 hover:text-white">
    <div className="flex items-center justify-center">
      <a
        className="rounded px-2 py-1 text-xs md:text-sm md:leading-normal m-4 md:m-0 no-underline font-semibold hover:underline"
        href="/users/sign_in">
        <FaIcon classes="fas fa-power-off" /> <span className="ml-2"> {t("sign_in") |> str} </span>
      </a>
    </div>
  </div>

let notificationButton = hasNotifications =>
  <Notifications__Root
    key="notifications-button"
    wrapperClasses="relative md:ml-1 pt-1 md:pt-0 text-sm font-semibold cursor-default flex w-8 h-8 md:w-9 md:h-9 justify-center items-center rounded-lg"
    iconClasses="student-navbar__notifications-unread-bullet"
    buttonClasses="font-semibold w-full flex items-center justify-center text-gray-100 hover:text-preciseBlue"
    icon="fas fa-bell text-lg"
    hasNotifications
  />

let messagesButton = (communityHost) =>
  <div className="relative md:ml-1 pt-1 md:pt-0 text-sm font-semibold cursor-default flex w-8 h-8 md:w-9 md:h-9 justify-center items-center rounded-lg">
    <a
      className="font-semibold w-full flex items-center justify-center text-gray-100 hover:text-preciseBlue"
      href={communityHost ++ "/messages"}>
      <FaIcon classes="fas fa-comment text-lg" />
    </a>
  </div>

let isMobile = () => Webapi.Dom.window |> Webapi.Dom.Window.innerWidth < 768

let headerLinks = (links, isLoggedIn, user, hasNotifications, communityHost) => {
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
      ReactUtils.nullUnless(messagesButton(communityHost), isLoggedIn && !isMobile()),
      ReactUtils.nullUnless(notificationButton(hasNotifications), isLoggedIn && !isMobile()),
      ReactUtils.nullUnless(<StudentTopNav__CommunityActions key="community-actions" communityHost />, isLoggedIn && !isMobile()),
    ])
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

@react.component
let make = (~schoolName, ~logoUrl, ~links, ~isLoggedIn, ~currentUser, ~hasNotifications, ~communityHost) => {
  let (menuHidden, toggleMenuHidden) = React.useState(() => isMobile())

  React.useEffect(() => {
    let resizeCB = _ => toggleMenuHidden(_ => isMobile())
    Webapi.Dom.Window.asEventTarget(Webapi.Dom.window) |> Webapi.Dom.EventTarget.addEventListener(
      "resize",
      resizeCB,
    )
    None
  })

  <div className="bg-siliconBlue-900">
    <div className="container mx-auto px-3 max-w-6xl">
      <nav className="flex justify-between items-center h-20">
        <div className="flex w-full items-center justify-between">
          <a className="max-w-sm" href={isLoggedIn ? "/dashboard" : "/"}>
            {switch logoUrl {
            | Some(url) =>
              <img
                className="h-10 object-contain flex text-sm items-center"
                src=url
                alt={"Logo of " ++ schoolName}
              />
            | None =>
              <div
                className="p-2 rounded-lg">
                <span className="text-xl font-bold leading-tight"> {schoolName |> str} </span>
              </div>
            }}
          </a>
          {ReactUtils.nullUnless(
            <div className="flex items-center space-x-2">
              {ReactUtils.nullUnless(messagesButton(communityHost), isLoggedIn)}
              {ReactUtils.nullUnless(notificationButton(hasNotifications), isLoggedIn)}
              <div onClick={_ => toggleMenuHidden(menuHidden => !menuHidden)}>
                <div
                  className={"student-navbar__menu-btn cursor-pointer w-8 h-8 text-center relative focus:outline-none rounded-lg " ++ (
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
              className="student-navbar__links-container flex justify-end items-center w-3/5 lg:w-3/4 flex-no-wrap flex-shrink-0">
              {headerLinks(links, isLoggedIn, currentUser, hasNotifications, communityHost)}
            </div>
          : React.null}
      </nav>
    </div>
    {isMobile() && !menuHidden
      ? <div
          className="student-navbar__links-container flex flex-row border-t w-full flex-wrap shadow-lg">
          {headerLinks(links, isLoggedIn, currentUser, hasNotifications, communityHost)}
        </div>
      : React.null}
  </div>
}
