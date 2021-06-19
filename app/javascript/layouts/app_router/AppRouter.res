exception UnknownPathEncountered(list<string>)
let str = React.string

let classNames = (default, trueClasses, falseClasses, bool) => {
  default ++ " " ++ (bool ? trueClasses : falseClasses)
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  let (component, showNav) = switch url.path {
  | list{"courses", courseId, "review"} => (<CoursesReviewV2__Root courseId />, true)
  | list{"submissions", submissionId, "review_v2"} => (
      <CoursesReviewV2__SubmissionsRoot submissionId />,
      false,
    )
  | _ =>
    Rollbar.critical(
      "Unknown path encountered by app router: " ++ Js.Array.joinWith("/", Array.of_list(url.path)),
    )
    raise(UnknownPathEncountered(url.path))
  }

  <div className="h-screen flex overflow-hidden bg-gray-100">
    {ReactUtils.nullUnless(<AppRouter__Nav />, showNav)}
    <div className="flex flex-col w-0 flex-1 overflow-hidden">
      <main className="flex-1 relative z-0 overflow-y-auto focus:outline-none">
        <div className="py-6"> {component} </div>
      </main>
    </div>
  </div>
}
