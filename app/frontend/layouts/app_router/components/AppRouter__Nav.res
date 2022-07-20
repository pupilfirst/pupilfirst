%%raw(`import "./AppRouter__Nav.css"`)

let t = I18n.t(~scope="components.AppRouter__Nav")

open AppRouter__Types

let str = React.string

let showLink = (id, selectedPage, page, classes, title, contents) => {
  Page.useSPA(selectedPage, Page.SelectedCourse(id, page))
    ? <Link key=title href={Page.coursePath(id, page)} className=classes title> {contents} </Link>
    : <a key=title href={Page.coursePath(id, page)} className=classes title> {contents} </a>
}

let renderLinks = (courses, selectedPage) => {
  switch selectedPage {
  | Page.SelectedCourse(courseId, coursePage) =>
    let currentCourse = ArrayUtils.unsafeFind(
      course => Course.id(course) == courseId,
      "Could not find currentCourse with ID " ++ courseId,
      courses,
    )

    <div>
      <div className="relative pb-1/2 bg-gray-800 rounded-lg">
        {switch Course.thumbnailUrl(currentCourse) {
        | Some(url) => <img className="absolute h-full w-full object-cover rounded-lg" src=url />
        | None =>
          <div
            className="app-router-nav__course-cover absolute h-full w-full svg-bg-pattern-1 rounded-lg "
          />
        }}
      </div>
      <div className="mt-4">
        <AppRouter__CourseSelector courses coursePage currentCourse selectedPage />
      </div>
      <div className="mt-4 space-y-3">
        {Page.activeLinks(currentCourse)
        ->Js.Array2.map(link => {
          let (title, icon) = switch link {
          | Page.Curriculum => (t("curriculum"), "i-journal-text-light")
          | Report => (t("report"), "i-graph-up-light")
          | Students => (t("students"), "i-users-light")
          | Review => (t("review"), "i-clipboard-check-light")
          | Leaderboard => (t("leaderboard"), "i-tachometer-alt-light")
          }

          let classes =
            "app-router-navbar__primary-nav-link py-3 px-2 mb-1 " ++ (
              link == coursePage ? "app-router-navbar__primary-nav-link--active" : ""
            )

          showLink(
            courseId,
            selectedPage,
            link,
            classes,
            title,
            [
              <Icon key="icon" className={`if ${icon} text-xl if-fw`} />,
              <div key="title" className="pl-3"> {str(title)} </div>,
            ]->React.array,
          )
        })
        ->React.array}
      </div>
    </div>
  | _ => React.null
  }
}

let courseSelector = (courses, selectedPage) => {
  switch selectedPage {
  | Page.SelectedCourse(courseId, coursePage) =>
    let currentCourse = ArrayUtils.unsafeFind(
      course => Course.id(course) == courseId,
      "Could not find currentCourse with ID " ++ courseId,
      courses,
    )

    <div>
      <div className="relative pb-1/2 bg-gray-800">
        {switch Course.thumbnailUrl(currentCourse) {
        | Some(url) => <img className="absolute h-full w-full object-cover" src=url />
        | None =>
          <div
            className="app-router-nav__course-cover absolute h-full w-full svg-bg-pattern-1 rounded-lg "
          />
        }}
      </div>
      <div className="-mt-11 pb-2 md:pb-0 md:mt-4 px-2">
        <AppRouter__CourseSelector courses coursePage currentCourse selectedPage />
      </div>
    </div>
  | _ => React.null
  }
}

let renderLinksMobile = (courses, selectedPage) => {
  switch selectedPage {
  | Page.SelectedCourse(courseId, coursePage) =>
    let currentCourse = ArrayUtils.unsafeFind(
      course => Course.id(course) == courseId,
      "Could not find currentCourse with ID " ++ courseId,
      courses,
    )

    <div className="flex">
      {Page.activeLinks(currentCourse)
      ->Js.Array2.map(link => {
        let (title, icon) = switch link {
        | Page.Curriculum => (t("curriculum"), "i-journal-text-regular")
        | Report => (t("report"), "i-graph-up-regular")
        | Students => (t("students"), "i-users-regular")
        | Review => (t("review"), "i-clipboard-check-regular")
        | Leaderboard => (t("leaderboard"), "i-tachometer-alt-regular")
        }

        let classes = {
          "flex flex-col flex-1 items-center py-3 text-xs text-gray-800 font-semibold " ++ (
            coursePage == link
              ? "text-primary-500 bg-gray-50"
              : "hover:text-primary-500 hover:bg-gray-50"
          )
        }

        showLink(
          courseId,
          selectedPage,
          link,
          classes,
          title,
          [
            <Icon key="icon" className={`if ${icon} text-lg if-fw`} />,
            <div key="title" className="pt-1"> {str(title)} </div>,
          ]->React.array,
        )
      })
      ->React.array}
    </div>
  | _ => React.null
  }
}

let showLink = (icon, href) => {
  <div key=href className="whitespace-nowrap">
    <a
      rel="nofollow"
      className="flex justify-center items-center text-xs text-gray-800 bg-gray-200 px-2 py-1 rounded cursor-pointer font-semibold hover:text-red-800 focus:ring ring-gray-300 ring-offset-2 hover:bg-red-100 focus:bg-red-200 transition"
      href>
      <FaIcon classes={"fas fw fa-" ++ icon} />
      <p className="ml-2"> {t("sign_out")->str} </p>
    </a>
  </div>
}

let links = () => {
  [showLink("power-off", "/users/sign_out")]
}

let showUser = user => {
  switch user {
  | Some(user) =>
    <div className="mt-3 mx-3">
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
          <p className="text-sm font-semibold text-left"> {str(User.name(user))} </p>
          <div className="text-xs text-gray-600 flex space-x-2"> {links()->React.array} </div>
        </div>
      </div>
    </div>

  | None => React.null
  }
}

@react.component
let make = (~school, ~courses, ~selectedPage, ~currentUser) => {
  let (sidebarOpen, setSidebarOpen) = React.useState(_ => false)
  [
    ReactUtils.nullUnless(
      <div className="fixed inset-0 flex z-40 md:hidden" key="sidebar">
        <div>
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div>
              <div className="absolute top-0 right-0 -mr-12 pt-2">
                <button
                  className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                  onClick={_e => setSidebarOpen(_ => false)}>
                  <span className="sr-only"> {str(t("close_sidebar"))} </span>
                </button>
              </div>
            </div>
            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <nav className="mt-5 px-2 space-y-1"> {renderLinks(courses, selectedPage)} </nav>
            </div>
          </div>
        </div>
        <div className="flex-shrink-0 w-14" />
      </div>,
      sidebarOpen,
    ),
    <div className="flex flex-shrink-0" key="main">
      <div className="flex flex-1 flex-col">
        <div
          className="px-4 py-2 bg-white border-b h-16 md:fixed w-full md:inset-x-0 md:top-0 z-50">
          <AppRouter__Header school currentUser />
        </div>
        <div className="md:hidden"> {courseSelector(courses, selectedPage)} </div>
      </div>
      <div className="approuter-nav__sidebar hidden md:flex flex-col">
        <div className="flex flex-col flex-1 border-r bg-white">
          <div className="flex-1 flex flex-col pt-4 pb-4 overflow-y-auto md:mt-16">
            <nav className="flex-1 px-4 bg-white"> {renderLinks(courses, selectedPage)} </nav>
            {showUser(currentUser)}
          </div>
        </div>
      </div>
    </div>,
    <div
      className="md:hidden fixed inset-x-0 bottom-0 flex-1 bg-white border-t z-50"
      key="mobile-links">
      {renderLinksMobile(courses, selectedPage)}
    </div>,
  ]->React.array
}
