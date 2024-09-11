open SchoolRouter__Types

let str = React.string

let showLink = (selectedPage, selectedCourse, page, classes, title, contents) => {
  let courseId = selectedCourse->Belt.Option.map(Course.id)
  let disabled = courseId->Belt.Option.isNone

  Page.path(~courseId?, page) != "#"
    ? Page.useSPA(selectedPage, page)
        ? <Link disabled href={Page.path(~courseId?, page)} className=classes ?title>
            {contents}
          </Link>
        : <a disabled href={Page.path(~courseId?, page)} className=classes ?title> {contents} </a>
    : SkeletonLoading.secondaryLink()
}

let secondaryNavOption = (selectedPage, selectedCourse, page) => {
  let defaultClasses = "flex text-sm py-3 px-4 hover:bg-gray-50 hover:text-primary-500 focus:bg-gray-50 focus:text-primary-500 rounded items-center my-1"
  let classes =
    defaultClasses ++ (
      selectedPage == page
        ? " bg-primary-50 text-primary-500 font-semibold"
        : " font-medium text-gray-500"
    )

  <div key={Page.secondaryNavName(page)}>
    {showLink(selectedPage, selectedCourse, page, classes, None, Page.secondaryNavName(page)->str)}
  </div>
}

let secondaryNavLinks = (selectedPage, selectedCourse, currentUser) => {
  let navOptionsAdmin = [
    Page.Curriculum,
    Assignments,
    Cohorts,
    Students,
    Applicants,
    Teams,
    Authors,
    Certificates,
    CourseCoaches,
    EvaluationCriteria,
    CourseExports,
    Calendars,
  ]

  let navOptionsAuthor = [Page.Curriculum, EvaluationCriteria]

  (User.isAuthor(currentUser) ? navOptionsAuthor : navOptionsAdmin)->Js.Array2.map(page =>
    secondaryNavOption(selectedPage, selectedCourse, SelectedCourse(page))
  )
}

@react.component
let make = (~selectedPage, ~selectedCourse, ~currentUser) =>
  switch selectedPage {
  | Page.Settings(_settingsSelection) =>
    <div
      key="secondary-nav"
      className="bg-white school-admin-navbar__secondary-nav border-e border-gray-200 pb-6 overflow-y-auto">
      <div className="p-4">
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Customization))}
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Admins))}
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Standing))}
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Discord))}
      </div>
    </div>
  | SelectedCourse(_courseSelection) =>
    <div
      key="secondary-nav"
      className="bg-white school-admin-navbar__secondary-nav border-e border-gray-200 pb-6 overflow-y-auto">
      <div>
        <div className="px-4 pt-2 bg-white">
          {secondaryNavLinks(selectedPage, selectedCourse, currentUser)->React.array}
        </div>
      </div>
    </div>
  | _ => React.null
  }
