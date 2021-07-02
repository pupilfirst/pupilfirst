%bs.raw(`require("courses/shared/background_patterns.css")`)
%bs.raw(`require("./AppRouter__Nav.css")`)

exception UnknownPathEncountered(list<string>)

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
        | Some(url) => <img className="absolute h-full w-full object-cover" src=url />
        | None =>
          <div className="app-router-nav-course__cover absolute h-full w-full svg-bg-pattern-1 " />
        }}
      </div>
      <div className="mt-2">
        <AppRouter__CourseSelector courses selectedPage currentCourseId />
      </div>
      <div> {Js.Array.map(link => {
          let (title, icon) = switch link {
          | Page.Student__Curriculum(_) => ("Curriculum", "i-book-open-light")
          | Student__Report(_) => ("Report", "i-check-circle-alt-regular")
          | Student__Students(_) => ("Student", "i-book-open-light")
          | Student__Review(_) => ("Review", "i-clock-regular")
          | Student__Leaderboard(_) => ("Leaderboard", "i-book-open-light")
          | Student__SubmissionShow(_) => ("Unknown", "")
          }
          <Link
            key=title
            href={Page.path(link)}
            className="flex items-center py-3 px-3 hover:text-primary-700 hover:font-semibold hover:bg-primary-100">
            <PfIcon className={`if ${icon} if-fw`} /> <div className="pl-2"> {str(title)} </div>
          </Link>
        }, Page.activeLinks(currentCourse))->React.array} </div>
    </div>
  | None => React.null
  }
}

@react.component
let make = (~courses, ~selectedPage) => {
  let url = RescriptReactRouter.useUrl()

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
    <div className="hidden md:flex md:flex-shrink-0">
      <div className="flex flex-col w-64">
        <div className="flex flex-col h-0 flex-1 border-r border-gray-200 bg-white">
          <div className="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
            <nav className="mt-5 flex-1 px-2 bg-white space-y-1">
              {renderLinks(courses, selectedPage)}
            </nav>
          </div>
        </div>
      </div>
    </div>,
  ]->React.array
}
