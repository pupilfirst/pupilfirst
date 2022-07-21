%%raw(`import "./SchoolRouter__Nav.css"`)

let t = I18n.t(~scope="components.SchoolAdminNavbar__Root")

open SchoolRouter__Types

let str = React.string

let showUserLink = (icon, href) => {
  <div key=href className="whitespace-nowrap">
    <a
      ariaLabel="Sign out"
      title="Sign out"
      rel="nofollow"
      className="flex justify-center items-center text-xs text-gray-500 bg-gray-50 px-2 py-2 rounded cursor-pointer font-semibold hover:text-red-800 focus:ring ring-gray-300 ring-offset-2 hover:bg-red-100 focus:bg-red-200 transition"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} />
    </a>
  </div>
}

let showUserLink = () => {
  [showUserLink("power-off", "/users/sign_out")]
}

let showUser = user => {
  <div className="mt-3">
    <div className="p-3 flex w-full items-center bg-gray-50 rounded-md">
      <div className="flex items-center justify-center rounded-full text-center flex-shrink-0">
        {User.avatarUrl(user)->Belt.Option.mapWithDefault(
          <Avatar
            name={User.name(user)}
            className="w-8 h-8 border border-gray-300 object-contain object-center rounded-full"
          />,
          src =>
            <img
              className="w-9 h-9 border border-gray-300 object-cover object-center rounded-full"
              src
              alt={User.name(user)}
            />,
        )}
      </div>
      <div className="pl-2 flex justify-between w-full items-center">
        <p className="text-sm font-medium"> {str(User.name(user))} </p>
        <div> {showUserLink()->React.array} </div>
      </div>
    </div>
  </div>
}

let containerClasses = shrunk => {
  let defaultClasses = "bg-white school-admin-navbar__primary-nav border-r border-gray-200 flex flex-col justify-between py-3 "

  defaultClasses ++ (
    shrunk ? "school-admin-navbar__primary-nav--shrunk px-1" : "overflow-y-auto px-3 "
  )
}

let headerclasses = shrunk => {
  let defaultClasses = "school-admin-navbar__header "
  defaultClasses ++ (shrunk ? "mx-auto" : "px-3 pt-2 pb-4 relative z-20 bg-white")
}

let imageContainerClasses = shrunk => {
  let defaultClasses = "school-admin-navbar__school-logo-container object-contain mx-auto  "
  defaultClasses ++ (shrunk ? "justify-center w-16 h-16" : "bg-white rounded")
}

let bottomLinkClasses = shrunk => {
  let defaultClasses = "py-3 px-2 flex text-gray-800 rounded text-sm font-medium hover:text-primary-500 hover:bg-gray-50 "
  defaultClasses ++ (shrunk ? "justify-center" : "items-center")
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

let topNavButtonContents = page => {
  [
    <PfIcon key="icon" className={"if i-" ++ Page.icon(page) ++ "-light if-fw text-lg"} />,
    <span key="content" className="ml-2"> {Page.name(page)->str} </span>,
  ]->React.array
}

let showLink = (selectedPage, page, classes, title, contents) => {
  Page.useSPA(selectedPage, page)
    ? <Link href={Page.path(page)} className=classes ?title> {contents} </Link>
    : <a href={Page.path(page)} className=classes ?title> {contents} </a>
}

let topLink = (selectedPage, page) => {
  let defaultClasses = "school-admin-navbar__primary-nav-link py-3 px-2 mb-1"
  let classes =
    defaultClasses ++ (selectedPage == page ? " school-admin-navbar__primary-nav-link--active" : "")
  let title = Page.shrunk(selectedPage) ? Some(Page.name(page)) : None

  showLink(selectedPage, page, classes, title, topNavButtonContents(page))
}

let secondaryNavOption = (selectedPage, page) => {
  let defaultClasses = "flex text-sm py-3 px-4 hover:bg-gray-50 hover:text-primary-500 focus:bg-gray-50 focus:text-primary-500 rounded items-center my-1"
  let classes =
    defaultClasses ++ (
      selectedPage == page
        ? " bg-primary-50 text-primary-500 font-semibold"
        : " font-medium text-gray-500"
    )

  <div key={Page.name(page)}>
    {showLink(selectedPage, page, classes, None, Page.name(page)->str)}
  </div>
}

let secondaryNavLinks = (selectedPage, courseId, currentUser) => {
  let navOptionsAdmin = [
    Page.Curriculum,
    Cohorts,
    Students,
    Applicants,
    Teams,
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
      className="bg-white school-admin-navbar__secondary-nav border-r border-gray-200 pb-6 overflow-y-auto">
      <ul className="p-4">
        {secondaryNavOption(selectedPage, Page.Settings(Customization))}
        {secondaryNavOption(selectedPage, Page.Settings(Admins))}
      </ul>
    </div>
  | SelectedCourse(courseId, _courseSelection) =>
    <div
      key="secondary-nav"
      className="bg-white school-admin-navbar__secondary-nav border-r border-gray-200 pb-6 overflow-y-auto">
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
              ? <div className="bg-white flex items-center justify-center px-3 py-1 rounded">
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
                      className="h-10 object-contain text-sm"
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
            {[Page.Courses, SchoolCoaches, Communities, Settings(Customization)]
            ->Js.Array2.map(page => <li key={Page.name(page)}> {topLink(selectedPage, page)} </li>)
            ->React.array}
            <li>
              {ReactUtils.nullIf(
                <ul>
                  <div
                    className="px-2 pt-3 pb-1 text-xs font-semibold text-gray-400 border-t-2 border-gray-100">
                    {"Courses"->str}
                  </div>
                  {Js.Array.map(course =>
                    <li key={Course.id(course)}>
                      <a
                        ariaLabel={Course.name(course)}
                        href={"/school/courses/" ++ Course.id(course) ++ "/curriculum"}
                        className="text-gray-800 py-3 px-2 rounded font-medium text-xs flex items-center hover:bg-gray-50 hover:text-primary-500">
                        <Avatar name={Course.name(course)} className="w-5 h-5 mr-2" />
                        {str(Course.name(course))}
                      </a>
                    </li>
                  , Js.Array.filter(course => !Course.ended(course), courses))->React.array}
                </ul>,
                Page.shrunk(selectedPage),
              )}
            </li>
          </ul>,
          User.isAuthor(currentUser),
        )}
      </div>
      <ul>
        <div className="relative">
          <Notifications__Root
            wrapperClasses=""
            iconClasses="school-admin-navbar__notifications-unread-bullet"
            buttonClasses="w-full flex gap-2 relative text-gray-800 text-sm py-3 px-2 hover:text-primary-500 hover:bg-gray-50 font-medium items-center"
            title=?{Page.shrunk(selectedPage) ? None : Some("Notifications")}
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
