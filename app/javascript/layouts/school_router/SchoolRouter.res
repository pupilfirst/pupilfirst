exception UnknownPathEncountered(list<string>)

open SchoolRouter__Types

let str = React.string

let classNames = (default, trueClasses, falseClasses, bool) => {
  default ++ " " ++ (bool ? trueClasses : falseClasses)
}

@react.component
let make = (~school, ~courses, ~currentUser) => {
  let url = RescriptReactRouter.useUrl()

  let (selectedPage: Page.t, component) = switch url.path {
  | list{"school"} => (Overview, None)
  | list{"school", "coaches"} => (SchoolCoaches, None)
  | list{"school", "customize"} => (Settings(Customization), None)
  | list{"school", "courses"}
  | list{"school", "courses", "new"} => (Courses, Some(<CourseEditor />))
  | list{"school", "courses", _courseId} => (Courses, Some(<CourseEditor />))
  | list{"school", "courses", _courseId, "details" | "images" | "actions"} => (
      Courses,
      Some(<CourseEditor />),
    )
  | list{"school", "courses", courseId, "students"} => (
      SelectedCourse(courseId, Students),
      Some(<StudentsIndex__Root courseId search={url.search} />),
    )
  | list{"school", "courses", courseId, "inactive_students"} => (
      SelectedCourse(courseId, Students),
      None,
    )
  | list{"school", "courses", courseId, "coaches"} => (
      SelectedCourse(courseId, CourseCoaches),
      None,
    )
  | list{"school", "courses", courseId, "curriculum"} => (
      SelectedCourse(courseId, Curriculum),
      None,
    )
  | list{
      "school",
      "courses",
      courseId,
      "targets",
      _targetId,
      "content" | "versions" | "details",
    } => (SelectedCourse(courseId, Curriculum), None)
  | list{"school", "courses", courseId, "exports"} => (
      SelectedCourse(courseId, CourseExports),
      None,
    )
  | list{"school", "courses", courseId, "applicants"} => (
      SelectedCourse(courseId, Applicants),
      None,
    )
  | list{"school", "courses", courseId, "applicants", _applicantId, "details" | "actions"} => (
      SelectedCourse(courseId, Applicants),
      None,
    )
  | list{"school", "courses", courseId, "authors"} => (SelectedCourse(courseId, Authors), None)
  | list{"school", "courses", courseId, "authors", _authorId} => (
      SelectedCourse(courseId, Authors),
      None,
    )
  | list{"school", "courses", courseId, "certificates"} => (
      SelectedCourse(courseId, Certificates),
      None,
    )
  | list{"school", "courses", courseId, "evaluation_criteria"} => (
      SelectedCourse(courseId, EvaluationCriteria),
      None,
    )
  | list{"school", "communities"} => (Communities, None)
  | list{"school", "admins"} => (Settings(Admins), None)
  | _ =>
    Rollbar.critical(
      "Unknown path encountered by school router: " ++
      Js.Array.joinWith("/", Array.of_list(url.path)),
    )
    raise(UnknownPathEncountered(url.path))
  }
  switch component {
  | Some(page) =>
    <div className="antialiased flex h-screen overflow-hidden bg-gray-100">
      <div className="flex school-admin-navbar flex-shrink-0">
        {<SchoolRouter__Nav school courses selectedPage currentUser />}
      </div>
      {page}
    </div>
  | None => <SchoolRouter__Nav school courses selectedPage currentUser />
  }
}
