%%raw(`import "./SchoolRouter.css"`)
exception UnknownPathEncountered(list<string>)

open SchoolRouter__Types

let str = React.string

let findSelectedCourse = (courses, currentCourseId) => {
  courses->Js.Array2.find(c => Course.id(c) == currentCourseId)
}

let findAndSetSelectedCourse = (setSelectedCourse, courses, currentCourseId) => {
  setSelectedCourse(_ => findSelectedCourse(courses, currentCourseId))
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
  | list{"school", "users"} => (Users, None)
  | list{"school", "users", _userId} => (Users, None)
  | list{"school", "users", _userId, "edit"} => (Users, None)
  | list{"school", "coaches"} => (SchoolCoaches, None)
  | list{"school", "customize"} => (Settings(Customization), None)
  | list{"school", "communities"} => (Communities, None)
  | list{"school", "admins"} => (Settings(Admins), None)
  | list{"school", "standing"} => (Settings(Standing), None)
  | list{"school", "code_of_conduct"} => (Settings(Standing), None)
  | list{"school", "standings", ..._tail} => (Settings(Standing), None)
  | list{"school", "discord_configuration"} => (Settings(Discord), None)
  | list{"school", "discord_server_roles"} => (Settings(Discord), None)
  | list{"school", "discord_sync_roles"} => (Settings(Discord), None)
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
  | list{"school", "students", studentId, "standing"} => (
      SelectedCourse(Students),
      Some(<StudentStanding__Root studentId />),
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
  | list{"school", "courses", courseId, ...tail} =>
    switch findSelectedCourse(courses, courseId) {
    | Some(_course) => {
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
        | list{"students", studentId, "standing"} => (
            Students,
            Some(<StudentStanding__Root studentId />),
          )
        | list{"teams"} => (Teams, Some(<TeamsIndex__Root courseId search={url.search} />))
        | list{"teams", "new"} => (Teams, Some(<TeamsCreator__Root courseId />))
        | list{"inactive_students"} => (Students, None)
        | list{"coaches"} => (CourseCoaches, None)
        | list{"curriculum"} => (Curriculum, None)
        | list{"calendars", ..._tail} => (Calendars, None)
        | list{"calendar_events", ..._tail} => (Calendars, None)
        | list{"targets", _targetId, "content" | "versions" | "details"} => (Curriculum, None)
        | list{"exports"} => (CourseExports, None)
        | list{"applicants"} => (Applicants, None)
        | list{"applicants", _applicantId, "details" | "actions"} => (Applicants, None)
        | list{"authors"} => (Authors, None)
        | list{"authors", _authorId} => (Authors, None)
        | list{"certificates"} => (Certificates, None)
        | list{"evaluation_criteria"} => (EvaluationCriteria, None)
        | list{"assignments"} => (Assignments, None)
        | _ =>
          Rollbar.critical(
            "Unknown path encountered by school router: " ++
            Js.Array.joinWith("/", Array.of_list(url.path)),
          )
          raise(UnknownPathEncountered(url.path))
        }
        (SelectedCourse(coursePage), courseComponent)
      }
    // Render error if the course doesn't exisit
    | None => (SelectedCourse(Students), Some(<ErrorState />))
    }
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
        selectedCourse,
        setCourseId: findAndSetSelectedCourse(setSelectedCourse, courses),
      }: SchoolRouter__CourseContext.t
    )}>
    <div className="antialiased flex h-screen overflow-hidden ">
      <div className="flex school-admin-navbar flex-shrink-0">
        {<SchoolRouter__LeftNav school courses selectedPage currentUser />}
      </div>
      <div className="flex flex-col flex-1">
        <SchoolRouter__TopNav courses currentUser />
        <div role="main" className="flex h-full overflow-y-auto">
          <SchoolRouter__LeftSecondaryNav currentUser selectedCourse selectedPage />
          <div id="schoolrouter-innerpage" className="flex-1 overflow-y-scroll bg-white">
            {switch component {
            | Some(page) => page
            | None => React.null
            }}
          </div>
        </div>
      </div>
    </div>
  </SchoolRouter__CourseContext.Provider>
}
