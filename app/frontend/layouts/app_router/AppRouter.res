exception UnknownPathEncountered(list<string>)
%%raw(`import "./components/AppRouter__Nav.css"`)

open AppRouter__Types

@react.component
let make = (~courses, ~currentUser) => {
  let url = RescriptReactRouter.useUrl()

  let component = switch url.path {
  | list{"courses", courseId, "review"} =>
    <CoursesReview__Root
      courseId
      currentCoachId={Belt.Option.getWithDefault(User.coachId(User.defaultUser(currentUser)), "")}
      courses
    />
  | list{"submissions", submissionId, "review"} =>
    <CoursesReview__SubmissionsRoot submissionId currentUser={User.defaultUser(currentUser)} />
  | list{"students", studentId, "report"} =>
    <CoursesStudents__StudentOverlay studentId userId={User.id(User.defaultUser(currentUser))} />
  | _ =>
    Rollbar.critical(
      "Unknown path encountered by app router: " ++ Js.Array.joinWith("/", Array.of_list(url.path)),
    )
    raise(UnknownPathEncountered(url.path))
  }
  <div className="md:h-screen md:flex bg-gray-50"> {component} </div>
}
