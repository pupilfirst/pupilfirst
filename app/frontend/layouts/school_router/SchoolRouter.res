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

let breadcrumbs = (path, courses, currentUser) => {
  <div className="flex justify-between p-4 bg-white border-b">
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
  | list{"school", "courses", courseId, ...tail} => {
      let (coursePage: Page.coursePages, courseComponent) = switch tail {
      | list{"cohorts"} => (Cohorts, Some(<CohortsIndex__Root courseId search={url.search} />))
      | list{"cohorts", "new"} => (Cohorts, Some(<CohortsCreator__Root courseId />))
      | list{"cohorts", cohortId, "details"} => (
          Cohorts,
          Some(<CohortsDetails__Root courseId cohortId />),
        )
      | list{"cohorts", cohortId, "actions"} => (
          Cohorts,
          Some(<CohortsActions__Root courseId cohortId />),
        )
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
          {breadcrumbs(url.path, courses, currentUser)}
          <div role="main" className="overflow-y-scroll flex-1 flex flex-col"> {page} </div>
        </div>
      </div>

    | None =>
      [
        <SchoolRouter__Nav school courses selectedPage currentUser key="nav-bar" />,
        <div key="breadcrumbs" className=""> {breadcrumbs(url.path, courses, currentUser)} </div>,
      ]->React.array
    }}
  </SchoolRouter__CourseContext.Provider>
}
