%%raw(`import "./SchoolRouter.css"`)
exception UnknownPathEncountered(list<string>)

open SchoolRouter__Types

let str = React.string

let classNames = (default, trueClasses, falseClasses, bool) => {
  default ++ " " ++ (bool ? trueClasses : falseClasses)
}

let findAndSetSelectedCourse = (setSelectedCourse, courses, currentCourseId) => {
  let currentCourse = courses->Js.Array2.find(c => Course.id(c) == currentCourseId)
  setSelectedCourse(_ => currentCourse)
}

let topNavButtonContents = page => {
  [
    <PfIcon key="icon" className={"if i-" ++ Page.icon(page) ++ "-light if-fw text-lg"} />,
    <span key="content" className="ml-2"> {Page.name(page)->str} </span>,
  ]->React.array
}

let showLink = (selectedPage, selectedCourse, page, classes, title, contents) => {
  let courseId = selectedCourse->Belt.Option.map(Course.id)
  let disabled = courseId->Belt.Option.isNone

  Page.path(~courseId?, page) != "#"
    ? Page.useSPA(selectedPage, page)
        ? <Link disabled href={Page.path(~courseId?, page)} className=classes ?title>
            {contents}
          </Link>
        : <a disabled href={Page.path(~courseId?, page)} className=classes ?title> {contents} </a>
    : SkeletonLoading.singleLink()
}

let topLink = (selectedPage, selectedCourse, page) => {
  let defaultClasses = "school-admin-navbar__primary-nav-link py-3 px-2 mb-1"
  let classes =
    defaultClasses ++ (selectedPage == page ? " school-admin-navbar__primary-nav-link--active" : "")
  let title = Page.shrunk(selectedPage) ? Some(Page.name(page)) : None

  showLink(selectedPage, selectedCourse, page, classes, title, topNavButtonContents(page))
}

let secondaryNavOption = (selectedPage, selectedCourse, page) => {
  let defaultClasses = "flex text-sm py-3 px-4 hover:bg-gray-50 hover:text-primary-500 focus:bg-gray-50 focus:text-primary-500 rounded items-center my-1"
  let classes =
    defaultClasses ++ (
      selectedPage == page
        ? " bg-primary-50 text-primary-500 font-semibold"
        : " font-medium text-gray-500"
    )

  <div key={Page.name(page)}>
    {showLink(selectedPage, selectedCourse, page, classes, None, Page.name(page)->str)}
  </div>
}

let secondaryNavLinks = (selectedPage, selectedCourse, currentUser) => {
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
    secondaryNavOption(selectedPage, selectedCourse, SelectedCourse(page))
  )
}

let secondaryNav = (currentUser, selectedCourse, selectedPage) =>
  switch selectedPage {
  | Page.Settings(_settingsSelection) =>
    <div
      key="secondary-nav"
      className="bg-white school-admin-navbar__secondary-nav border-r border-gray-200 pb-6 overflow-y-auto">
      <div className="p-4">
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Customization))}
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Admins))}
      </div>
    </div>
  | SelectedCourse(_courseSelection) =>
    <div
      key="secondary-nav"
      className="bg-white school-admin-navbar__secondary-nav border-r border-gray-200 pb-6 overflow-y-auto">
      <div>
        <div className="border-t px-4">
          {secondaryNavLinks(selectedPage, selectedCourse, currentUser)->React.array}
        </div>
      </div>
    </div>
  | _ => React.null
  }

let breadcrumbs = (path, courses, currentUser, selectedPage) => {
  <div
    className={"flex justify-between p-4 bg-white border-b " ++ (
      Page.shrunk(selectedPage) ? "top-header--shrunk" : "top-header"
    )}>
    <div>
      <div className="flex items-center space-x-2 mt-1">
        {
          // Experimental and this logic needs to be refactored
          switch path {
          | list{"school", "courses", _courseId, primaryPage, ...tale} =>
            <div className="flex items-center space-x-2">
              <div> <SchoolRouter__CoursesDropdown courses /> </div>
              {switch tale {
              | list{_resourceId, secondaryPage, ..._tale} =>
                <div> {`${primaryPage}/${secondaryPage}`->str} </div>
              | _ => primaryPage->str
              }}
            </div>
          | list{"school", primaryPage, _resourceId, secondaryPage} =>
            <div className="flex items-center space-x-2">
              <div> <SchoolRouter__CoursesDropdown courses /> </div>
              <div> {`${primaryPage}/${secondaryPage}`->str} </div>
            </div>
          | list{"school"} => "school"->str
          | list{"school", page, ..._tale} => page->str
          | _ => React.null
          }
        }
      </div>
    </div>
    <div className="relative">
      <Notifications__Root
        wrapperClasses=""
        iconClasses="school-admin-navbar__notifications-unread-bullet"
        buttonClasses="w-full flex items-center bg-gray-50 rounded relative text-gray-800 text-sm p-2 hover:text-primary-500 hover:bg-gray-50 font-medium items-center"
        hasNotifications={User.hasNotifications(currentUser)}
      />
    </div>
  </div>
}

@react.component
let make = (~school, ~courses, ~currentUser) => {
  let (selectedCourse, setSelectedCourse) = React.useState(() => None)
  let url = RescriptReactRouter.useUrl()

  React.useEffect1(() => {
    switch url.path {
    | list{"school", "courses", courseId, ..._tale} =>
      findAndSetSelectedCourse(setSelectedCourse, courses, courseId)
    | _ => setSelectedCourse(_ => None)
    }
    None
  }, [url])

  let (selectedPage: Page.t, component) = switch url.path {
  | list{"school", "coaches"} => (SchoolCoaches, None)
  | list{"school", "customize"} => (Settings(Customization), None)
  | list{"school"}
  | list{"school", "courses"}
  | list{"school", "courses", "new"} => (Courses, Some(<CourseEditor__Root school />))
  | list{"school", "courses", _courseId} => (Courses, Some(<CourseEditor__Root school />))
  | list{"school", "courses", _courseId, "details" | "images" | "actions"} => (
      Courses,
      Some(<CourseEditor__Root school />),
    )
  | list{"school", "students", studentId, "details"} => (
      SelectedCourse(Students),
      Some(<StudentDetails__Root studentId />),
    )
  | list{"school", "students", studentId, "actions"} => (
      SelectedCourse(Students),
      Some(<StudentActions__Root studentId />),
    )
  | list{"school", "teams", studentId, "details"} => (
      SelectedCourse(Teams),
      Some(<TeamsDetails__Root studentId />),
    )
  | list{"school", "teams", studentId, "actions"} => (
      SelectedCourse(Teams),
      Some(<TeamsActions__Root studentId />),
    )
  | list{"school", "cohorts", cohortId, "details"} => (
      SelectedCourse(Cohorts),
      Some(<CohortsDetails__Root cohortId />),
    )
  | list{"school", "cohorts", cohortId, "actions"} => (
      SelectedCourse(Cohorts),
      Some(<CohortsActions__Root cohortId />),
    )
  | list{"school", "courses", courseId, ...tail} => {
      let (coursePage: Page.coursePages, courseComponent) = switch tail {
      | list{"cohorts"} => (Cohorts, Some(<CohortsIndex__Root courseId search={url.search} />))
      | list{"cohorts", "new"} => (Cohorts, Some(<CohortsCreator__Root courseId />))
      | list{"students"} => (Students, Some(<StudentsIndex__Root courseId search={url.search} />))
      | list{"students", "new"} => (Students, Some(<StudentCreator__Root courseId />))
      | list{"students", "import"} => (Students, Some(<StudentBulkImport__Root courseId />))
      | list{"students", studentId, "details"} => (
          Students,
          Some(<StudentDetails__Root studentId />),
        )
      | list{"students", studentId, "actions"} => (
          Students,
          Some(<StudentActions__Root studentId />),
        )
      | list{"teams"} => (Teams, Some(<TeamsIndex__Root courseId search={url.search} />))
      | list{"teams", "new"} => (Teams, Some(<TeamsCreator__Root courseId />))
      | list{"inactive_students"} => (Students, None)
      | list{"coaches"} => (CourseCoaches, None)
      | list{"curriculum"} => (Curriculum, None)
      | list{"targets", _targetId, "content" | "versions" | "details"} => (Curriculum, None)
      | list{"exports"} => (CourseExports, None)
      | list{"applicants"} => (Applicants, None)
      | list{"applicants", _applicantId, "details" | "actions"} => (Applicants, None)
      | list{"authors"} => (Authors, None)
      | list{"authors", _authorId} => (Authors, None)
      | list{"certificates"} => (Certificates, None)
      | list{"evaluation_criteria"} => (EvaluationCriteria, None)
      | _ =>
        Rollbar.critical(
          "Unknown path encountered by school router: " ++
          Js.Array.joinWith("/", Array.of_list(url.path)),
        )
        raise(UnknownPathEncountered(url.path))
      }
      (SelectedCourse(coursePage), courseComponent)
    }

  | list{"school", "communities"} => (Communities, None)
  | list{"school", "admins"} => (Settings(Admins), None)
  | _ =>
    Rollbar.critical(
      "Unknown path encountered by school router: " ++
      Js.Array.joinWith("/", Array.of_list(url.path)),
    )
    raise(UnknownPathEncountered(url.path))
  }
  <SchoolRouter__CourseContext.Provider
    value={(
      {
        selectedCourse: selectedCourse,
        setCourseId: findAndSetSelectedCourse(setSelectedCourse, courses),
      }: SchoolRouter__CourseContext.t
    )}>
    {switch component {
    | Some(page) =>
      <div className="antialiased flex h-screen overflow-hidden bg-gray-50 ">
        <div className="flex school-admin-navbar flex-shrink-0">
          {<SchoolRouter__Nav school courses selectedPage currentUser />}
        </div>
        <div className="flex flex-col flex-1">
          {breadcrumbs(url.path, courses, currentUser, selectedPage)}
          <div role="main" className="flex h-full">
            {secondaryNav(currentUser, selectedCourse, selectedPage)}
            <div className="overflow-y-scroll flex-1"> {page} </div>
          </div>
        </div>
      </div>

    | None =>
      <div className="antialiased flex h-screen overflow-hidden bg-gray-50 ">
        <div className="flex school-admin-navbar flex-shrink-0">
          {<SchoolRouter__Nav school courses selectedPage currentUser />}
        </div>
        <div className="flex flex-col flex-1">
          {breadcrumbs(url.path, courses, currentUser, selectedPage)}
          <div role="main" className="flex h-full">
            {secondaryNav(currentUser, selectedCourse, selectedPage)}
            <div id="schoolrouter-innerpage" className="overflow-y-scroll flex-1" />
          </div>
        </div>
      </div>
    }}
  </SchoolRouter__CourseContext.Provider>
}
