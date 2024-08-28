%%raw(`import "./SchoolRouter__Nav.css"`)

let t = I18n.t(~scope="components.SchoolAdminNavbar__Root")

open SchoolRouter__Types

open ThemeSwitch

let str = React.string

let containerClasses = shrunk => {
  let defaultClasses = "bg-white school-admin-navbar__primary-nav border-e border-gray-200 flex flex-col justify-between py-3 "

  defaultClasses ++ (
    shrunk ? "school-admin-navbar__primary-nav--shrunk px-1" : "overflow-y-auto px-3 "
  )
}

let headerclasses = shrunk => {
  let defaultClasses = "school-admin-navbar__header "
  defaultClasses ++ (shrunk ? "mx-auto" : "px-3 pt-2 pb-4 relative z-20 bg-white")
}

let imageContainerClasses = shrunk => {
  let defaultClasses = "school-admin-navbar__school-logo-container object-contain mx-auto  "
  defaultClasses ++ (shrunk ? "justify-center w-16 h-16" : "bg-white rounded")
}

let topNavButtonContents = page => {
  [
    <PfIcon key="icon" className={"if i-" ++ Page.icon(page) ++ "-light if-fw text-lg"} />,
    <span key="content" className="ms-2"> {Page.primaryNavName(page)->str} </span>,
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

  let title = Page.shrunk(selectedPage) ? Some(Page.primaryNavName(page)) : None

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

  <div key={Page.secondaryNavName(page)}>
    {showLink(selectedPage, selectedCourse, page, classes, None, Page.secondaryNavName(page)->str)}
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
      className="bg-white school-admin-navbar__secondary-nav border-e border-gray-200 pb-6 overflow-y-auto">
      <div className="p-4">
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Customization))}
        {secondaryNavOption(selectedPage, selectedCourse, Page.Settings(Admins))}
      </div>
    </div>
  | SelectedCourse(_courseSelection) =>
    <div
      key="secondary-nav"
      className="bg-white school-admin-navbar__secondary-nav border-e border-gray-200 pb-6 overflow-y-auto">
      <div>
        <div className="border-t px-4">
          {secondaryNavLinks(selectedPage, selectedCourse, currentUser)->React.array}
        </div>
      </div>
    </div>
  | _ => React.null
  }

let renderIcon = school => {
  getTheme() == "light"
    ? <img src={School.iconOnLightBgUrl(school)} alt={"Icon of " ++ School.name(school)} />
    : <img src={School.iconOnDarkBgUrl(school)} alt={"Icon of " ++ School.name(school)} />
}

@react.component
let make = (~school, ~courses, ~selectedPage, ~currentUser) => {
  let selectedCourse = React.useContext(SchoolRouter__CourseContext.context).selectedCourse
  [
    <div key="main-nav" className={containerClasses(Page.shrunk(selectedPage))}>
      <div>
        <div className={headerclasses(Page.shrunk(selectedPage))}>
          <div className={imageContainerClasses(Page.shrunk(selectedPage))}>
            {Page.shrunk(selectedPage)
              ? <div className="bg-white flex items-center justify-center px-3 py-1 rounded">
                  {User.isAuthor(currentUser)
                    ? renderIcon(school)
                    : <a className="text-xs" href="/school"> {renderIcon(school)} </a>}
                </div>
              : {
                  switch getTheme() == "light"
                    ? School.logoOnLightBgUrl(school)
                    : School.logoOnDarkBgUrl(school) {
                  | Some(url) =>
                    <img
                      className="h-10 object-contain text-sm"
                      src=url
                      alt={"Logo of " ++ School.name(school)}
                    />
                  | None =>
                    <div
                      className="p-2 rounded-lg bg-white text-gray-900 hover:bg-gray-100 hover:text-primary-600">
                      <span className="text-xl font-bold leading-tight">
                        {School.name(school)->str}
                      </span>
                    </div>
                  }
                }}
          </div>
        </div>
        {ReactUtils.nullIf(
          <ul>
            {[Page.Courses, Users, SchoolCoaches, Communities, Settings(Customization)]
            ->Js.Array2.map(page =>
              <li key={Page.primaryNavName(page)}>
                {topLink(selectedPage, selectedCourse, page)}
              </li>
            )
            ->React.array}
            <li>
              {ReactUtils.nullIf(
                <ul>
                  <div
                    className="px-2 pt-3 pb-1 text-xs font-semibold text-gray-400 border-t-2 border-gray-100">
                    {"Courses"->str}
                  </div>
                  {Js.Array.map(course =>
                    <li key={Course.id(course)}>
                      <a
                        ariaLabel={Course.name(course)}
                        href={"/school/courses/" ++ Course.id(course) ++ "/students"}
                        className="text-gray-800 py-3 px-2 rounded font-medium text-xs flex gap-2 items-center hover:bg-gray-50 hover:text-primary-500">
                        <Avatar name={Course.name(course)} className="w-5 h-5 shrink-0" />
                        <span className="inline-block"> {str(Course.name(course))} </span>
                      </a>
                    </li>
                  , Js.Array.filter(course => !Course.ended(course), courses))->React.array}
                </ul>,
                Page.shrunk(selectedPage),
              )}
            </li>
          </ul>,
          User.isAuthor(currentUser),
        )}
      </div>
    </div>,
  ]->React.array
}
