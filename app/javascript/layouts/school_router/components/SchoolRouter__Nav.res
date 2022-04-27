%raw(`require("./SchoolRouter__Nav.css")`)

let t = I18n.t(~scope="components.SchoolAdminNavbar__Root")

open SchoolRouter__Types

let str = React.string

let showUserLink = (icon, href) => {
  <div key=href className="whitespace-nowrap">
    <a
      rel="nofollow"
      className="flex justify-center items-center text-xs text-gray-800 bg-gray-300 px-2 py-1 rounded cursor-pointer font-semibold hover:text-red-800 focus:ring ring-gray-300 ring-offset-2 hover:bg-red-100 focus:bg-red-200 transition"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} /> <p className="ml-2"> {"Sign Out"->str} </p>
    </a>
  </div>
}

let showUserLink = () => {
  [showUserLink("power-off", "/users/sign_out")]
}

let showUser = user => {
  <div className="px-4 pt-6 pb-2">
    <div className="flex w-full items-center p-2 bg-gray-100 rounded-md">
      <div className="flex items-center justify-center rounded-full text-center flex-shrink-0">
        {User.avatarUrl(user)->Belt.Option.mapWithDefault(
          <Avatar
            name={User.name(user)}
            className="flex w-10 h-10 border border-gray-300 object-contain object-center rounded-full text-tiny flex-shrink-0"
          />,
          src =>
            <img
              className="flex w-10 h-10 border border-gray-300 object-cover object-center rounded-full text-tiny"
              src
              alt={User.name(user)}
            />,
        )}
      </div>
      <div className="pl-2 flex justify-between w-full items-center">
        <p className="text-sm font-semibold text-left"> {str(User.name(user))} </p>
        <div className="text-xs text-gray-700 flex space-x-2"> {showUserLink()->React.array} </div>
      </div>
    </div>
  </div>
}

let containerClasses = shrunk => {
  let defaultClasses = "bg-gradient-to-b from-primary-600 to-primary-800 school-admin-navbar__primary-nav flex flex-col justify-between "

  defaultClasses ++ (shrunk ? "school-admin-navbar__primary-nav--shrunk" : "overflow-y-auto")
}

let headerclasses = shrunk => {
  let defaultClasses = "school-admin-navbar__header "
  defaultClasses ++ (
    shrunk
      ? "mx-auto"
      : "px-5 py-2 relative z-20 border-r border-b border-gray-400 bg-white flex h-16 items-center"
  )
}

let imageContainerClasses = shrunk => {
  let defaultClasses = "school-admin-navbar__school-logo-container flex items-center "
  defaultClasses ++ (shrunk ? "justify-center w-16 h-16" : "bg-white h-8 w-3/5 rounded")
}

let bottomLinkClasses = shrunk => {
  let defaultClasses = "flex text-white text-sm py-4 px-5 hover:bg-primary-900 font-semibold items-center "
  defaultClasses ++ (shrunk ? "justify-center" : "")
}

let bottomLink = (path, shrunk, iconClasses, text) => {
  let title = shrunk ? Some(text) : None

  <li>
    <a ?title href=path className={bottomLinkClasses(shrunk)}>
      <i className={iconClasses ++ " fa-fw text-lg"} />
      {shrunk ? React.null : <span className="ml-2"> {text->str} </span>}
    </a>
  </li>
}

let topNavButtonContents = (selectedPage, page) => {
  [
    <i key="icon" className={Page.icon(page) ++ " fa-fw text-lg"} />,
    {
      Page.shrunk(selectedPage)
        ? React.null
        : <span key="content" className="ml-2"> {Page.name(page)->str} </span>
    },
  ]->React.array
}

let showLink = (selectedPage, page, classes, title, contents) => {
  Page.useSPA(selectedPage, page)
    ? <Link href={Page.path(page)} className=classes ?title> {contents} </Link>
    : <a href={Page.path(page)} className=classes ?title> {contents} </a>
}

let topLink = (selectedPage, page) => {
  let defaultClasses = "school-admin-navbar__primary-nav-link py-4 px-5"
  let classes =
    defaultClasses ++ (selectedPage == page ? " school-admin-navbar__primary-nav-link--active" : "")
  let title = Page.shrunk(selectedPage) ? Some(Page.name(page)) : None

  showLink(selectedPage, page, classes, title, topNavButtonContents(selectedPage, page))
}

let secondaryNavOption = (selectedPage, page) => {
  let defaultClasses = "flex text-indigo-800 text-sm py-3 px-4 hover:bg-gray-400 focus:bg-gray-400 font-semibold rounded items-center my-1"
  let classes = defaultClasses ++ (selectedPage == page ? " bg-gray-400" : "")

  <div key={Page.name(page)}>
    {showLink(selectedPage, page, classes, None, Page.name(page)->str)}
  </div>
}

let secondaryNavLinks = (selectedPage, courseId, currentUser) => {
  let navOptionsAdmin = [
    Page.Curriculum,
    Students,
    Applicants,
    Authors,
    Certificates,
    CourseCoaches,
    EvaluationCriteria,
    CourseExports,
  ]

  let navOptionsAuthor = [Page.Curriculum, EvaluationCriteria]

  (User.isAuthor(currentUser) ? navOptionsAuthor : navOptionsAdmin)->Js.Array2.map(page =>
    secondaryNavOption(selectedPage, SelectedCourse(courseId, page))
  )
}

let secondaryNav = (courses, currentUser, selectedPage) =>
  switch selectedPage {
  | Page.Settings(_settingsSelection) =>
    <div
      key="secondary-nav"
      className="bg-gray-200 school-admin-navbar__secondary-nav w-full border-r border-gray-400 pb-6 overflow-y-auto">
      <ul className="p-4">
        {secondaryNavOption(selectedPage, Page.Settings(Customization))}
        {secondaryNavOption(selectedPage, Page.Settings(Admins))}
      </ul>
    </div>
  | SelectedCourse(courseId, _courseSelection) =>
    <div
      key="secondary-nav"
      className="bg-gray-200 school-admin-navbar__secondary-nav w-full border-r border-gray-400 pb-6 overflow-y-auto">
      <div className="p-4">
        <SchoolRouter__CoursesDropdown courses currentCourseId=courseId />
        {secondaryNavLinks(selectedPage, courseId, currentUser)->React.array}
      </div>
    </div>
  | _ => React.null
  }

@react.component
let make = (~school, ~courses, ~selectedPage, ~currentUser) => {
  [
    <div key="main-nav" className={containerClasses(Page.shrunk(selectedPage))}>
      <div>
        <div className={headerclasses(Page.shrunk(selectedPage))}>
          <div className={imageContainerClasses(Page.shrunk(selectedPage))}>
            {Page.shrunk(selectedPage)
              ? <div className="bg-white flex items-center justify-center p-2 m-2 rounded">
                  {User.isAuthor(currentUser)
                    ? <img src={School.iconUrl(school)} alt={School.name(school)} />
                    : <a className="text-xs" href="/school">
                        <img src={School.iconUrl(school)} alt={School.name(school)} />
                      </a>}
                </div>
              : {
                  switch School.logoUrl(school) {
                  | Some(url) =>
                    <img
                      className="h-9 md:h-12 object-contain flex text-sm items-center"
                      src=url
                      alt={"Logo of " ++ School.name(school)}
                    />
                  | None =>
                    <div
                      className="p-2 rounded-lg bg-white text-gray-900 hover:bg-gray-100 hover:text-primary-600">
                      <span className="text-xl font-bold leading-tight">
                        {School.name(school)->str}
                      </span>
                    </div>
                  }
                }}
          </div>
        </div>
        {ReactUtils.nullIf(
          <ul>
            {[Page.Overview, SchoolCoaches, Settings(Customization)]
            ->Js.Array2.map(page => <li key={Page.name(page)}> {topLink(selectedPage, page)} </li>)
            ->React.array}
            <li>
              {topLink(selectedPage, Courses)}
              {ReactUtils.nullIf(
                <ul className="pr-4 pb-4 ml-10 mt-1">
                  {Js.Array.map(
                    course =>
                      <li key={Course.id(course)}>
                        <a
                          href={"/school/courses/" ++ Course.id(course) ++ "/curriculum"}
                          className="block text-white py-3 px-4 hover:bg-primary-800 rounded font-semibold text-xs">
                          {str(Course.name(course))}
                        </a>
                      </li>,
                    Js.Array.filter(course => !Course.ended(course), courses),
                  )->React.array}
                </ul>,
                Page.shrunk(selectedPage),
              )}
            </li>
            {topLink(selectedPage, Communities)}
          </ul>,
          User.isAuthor(currentUser),
        )}
      </div>
      <ul>
        <div className="relative">
          <Notifications__Root
            wrapperClasses="w-full"
            iconClasses="school-admin-navbar__notifications-unread-bullet"
            buttonClasses="flex relative text-white text-sm py-4 px-5 hover:bg-primary-900 font-semibold items-center w-full"
            title=?{Page.shrunk(selectedPage) ? None : Some("Notifications")}
            icon="fas fa-bell fa-fw text-lg mr-2"
            hasNotifications={User.hasNotifications(currentUser)}
          />
        </div>
        {bottomLink("/dashboard", Page.shrunk(selectedPage), "fas fa-home", "Dashboard")}
        <li>
          {Page.shrunk(selectedPage)
            ? <a
                title=?{Page.shrunk(selectedPage) ? Some("Sign Out") : None}
                className={bottomLinkClasses(Page.shrunk(selectedPage))}
                rel="nofollow"
                href="/users/sign_out">
                <i className="fas fa-sign-out-alt fa-fw text-lg" />
              </a>
            : showUser(currentUser)}
        </li>
      </ul>
    </div>,
    secondaryNav(courses, currentUser, selectedPage),
  ]->React.array
}
