exception UnknownPathEncountered(list<string>)

open AppRouter__Types

let str = React.string

let classNames = (default, trueClasses, falseClasses, bool) => {
  default ++ " " ++ (bool ? trueClasses : falseClasses)
}

@react.component
let make = (~courses, ~currentUser) => {
  let url = RescriptReactRouter.useUrl()

  let (component, selectedPage: Page.t) = switch url.path {
  | list{"courses", courseId, "review"} => (
      <CoursesReviewV2__Root courseId />,
      Student__Review(courseId),
    )
  | list{"submissions", submissionId, "review"} => (
      <CoursesReviewV2__SubmissionsRoot submissionId currentUser />,
      Student__SubmissionShow(submissionId),
    )
  | _ =>
    Rollbar.critical(
      "Unknown path encountered by app router: " ++ Js.Array.joinWith("/", Array.of_list(url.path)),
    )
    raise(UnknownPathEncountered(url.path))
  }
  <div className="md:h-screen md:flex bg-gray-100">
    {ReactUtils.nullUnless(<AppRouter__Nav courses selectedPage />, Page.showSideNav(selectedPage))}
    {component}
  </div>
}
