exception UnknownPathEncountered(list<string>)

open AppRouter__Types

let str = React.string

let classNames = (default, trueClasses, falseClasses, bool) => {
  default ++ " " ++ (bool ? trueClasses : falseClasses)
}

@react.component
let make = (~school, ~courses, ~currentUser) => {
  let url = RescriptReactRouter.useUrl()

  let (component, selectedPage: Page.t) = switch url.path {
  | list{"courses", courseId, "review"} => (
      <CoursesReview__Root
        courseId
        currentCoachId={Belt.Option.getWithDefault(User.coachId(User.defaultUser(currentUser)), "")}
        courses
      />,
      Student__Review(courseId),
    )
  | list{"submissions", submissionId, "review"} => (
      <CoursesReview__SubmissionsRoot submissionId currentUser={User.defaultUser(currentUser)} />,
      Student__SubmissionShow(submissionId),
    )
  | _ =>
    Rollbar.critical(
      "Unknown path encountered by app router: " ++ Js.Array.joinWith("/", Array.of_list(url.path)),
    )
    raise(UnknownPathEncountered(url.path))
  }
  <div className="md:h-screen md:flex bg-gray-50">
    {ReactUtils.nullUnless(
      <AppRouter__Nav school courses selectedPage currentUser />,
      Page.showSideNav(selectedPage),
    )}
    {component}
  </div>
}
