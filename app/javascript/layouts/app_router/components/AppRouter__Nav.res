%bs.raw(`require("courses/shared/background_patterns.css")`)
%bs.raw(`require("./AppRouter__Nav.css")`)

open AppRouter__Types

let str = React.string

let renderLinks = (courses, selectedPage) => {
  switch Page.courseId(selectedPage) {
  | Some(currentCourseId) =>
    let currentCourse = ArrayUtils.unsafeFind(
      course => Course.id(course) == currentCourseId,
      "Could not find currentCourse with ID " ++ currentCourseId,
      courses,
    )

    <div>
      <div className="relative pb-1/2 bg-gray-800 rounded-lg">
        {switch Course.thumbnailUrl(currentCourse) {
        | Some(url) => <img className="absolute h-full w-full object-cover rounded-lg" src=url />
        | None =>
          <div
            className="app-router-nav-course__cover absolute h-full w-full svg-bg-pattern-1 rounded-lg "
          />
        }}
      </div>
      <div className="mt-4">
        <AppRouter__CourseSelector courses selectedPage currentCourseId />
      </div>
      <div className="mt-4 space-y-2"> {Js.Array.map(link => {
          let (title, icon) = switch link {
          | Page.Student__Curriculum(_) => ("Curriculum", "i-book-open-light")
          | Student__Report(_) => ("Report", "i-check-circle-alt-light")
          | Student__Students(_) => ("Student", "i-book-open-light")
          | Student__Review(_) => ("Review", "i-clock-light")
          | Student__Leaderboard(_) => ("Leaderboard", "i-book-open-light")
          | Student__SubmissionShow(_) => ("Unknown", "")
          }
          <a
            key=title
            href={Page.path(link)}
            className="flex items-center p-3 rounded-md text-sm font-semibold hover:text-primary-500 hover:bg-gray-200">
            <Icon className={`if ${icon} text-lg if-fw`} />
            <div className="pl-2"> {str(title)} </div>
          </a>
        }, Page.activeLinks(currentCourse))->React.array} </div>
    </div>
  | None => React.null
  }
}

let courseSelector = (courses, selectedPage) => {
  switch Page.courseId(selectedPage) {
  | Some(currentCourseId) =>
    let currentCourse = ArrayUtils.unsafeFind(
      course => Course.id(course) == currentCourseId,
      "Could not find currentCourse with ID " ++ currentCourseId,
      courses,
    )

    <div>
      <div className="relative pb-1/2 bg-gray-800 rounded-lg">
        {switch Course.thumbnailUrl(currentCourse) {
        | Some(url) => <img className="absolute h-full w-full object-cover rounded-lg" src=url />
        | None =>
          <div
            className="app-router-nav-course__cover absolute h-full w-full svg-bg-pattern-1 rounded-lg "
          />
        }}
      </div>
      <div className="mt-4">
        <AppRouter__CourseSelector courses selectedPage currentCourseId />
      </div>
    </div>
  | None => React.null
  }
}

let renderLinksMobile = (courses, selectedPage) => {
  switch Page.courseId(selectedPage) {
  | Some(currentCourseId) =>
    let currentCourse = ArrayUtils.unsafeFind(
      course => Course.id(course) == currentCourseId,
      "Could not find currentCourse with ID " ++ currentCourseId,
      courses,
    )

    <div className="flex"> {Js.Array.map(link => {
        let (title, icon) = switch link {
        | Page.Student__Curriculum(_) => ("Curriculum", "i-book-open-light")
        | Student__Report(_) => ("Report", "i-check-circle-alt-light")
        | Student__Students(_) => ("Student", "i-book-open-light")
        | Student__Review(_) => ("Review", "i-clock-light")
        | Student__Leaderboard(_) => ("Leaderboard", "i-book-open-light")
        | Student__SubmissionShow(_) => ("Unknown", "")
        }
        <a
          key=title
          href={Page.path(link)}
          className="flex flex-col flex-1 items-center py-3 text-xs text-gray-800 font-semibold hover:text-primary-500 hover:bg-gray-200">
          <Icon className={`if ${icon} text-lg if-fw`} /> <div className="pt-1"> {str(title)} </div>
        </a>
      }, Page.activeLinks(currentCourse))->React.array} </div>
  | None => React.null
  }
}

@react.component
let make = (~school, ~courses, ~selectedPage, ~currentUser) => {
  let (sidebarOpen, setSidebarOpen) = React.useState(_ => false)
  [
    ReactUtils.nullUnless(
      <div className="fixed inset-0 flex z-40 md:hidden">
        <div>
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div>
              <div className="absolute top-0 right-0 -mr-12 pt-2">
                <button
                  className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                  onClick={_e => setSidebarOpen(_ => false)}>
                  <span className="sr-only"> {str("Close sidebar")} </span>
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
    <div className="flex flex-shrink-0">
      <div className="flex flex-1 flex-col">
        <div className="p-2 bg-white border-b h-16 md:fixed w-full md:inset-x-0 md:top-0 z-50">
          <AppRouter__Header school currentUser />
        </div>
        <div className="md:hidden p-4 md:mt-16"> {courseSelector(courses, selectedPage)} </div>
      </div>
      <div className="approuter-nav__sidebar hidden md:flex flex-col">
        <div className="flex flex-col h-0 flex-1 border-r bg-white">
          <div className="flex-1 flex flex-col pt-4 pb-4 overflow-y-auto md:mt-16">
            <nav className="flex-1 px-4 bg-white"> {renderLinks(courses, selectedPage)} </nav>
          </div>
        </div>
      </div>
    </div>,
    <div className="md:hidden fixed inset-x-0 bottom-0 flex-1 bg-white border-t">
      {renderLinksMobile(courses, selectedPage)}
    </div>,
  ]->React.array
}
