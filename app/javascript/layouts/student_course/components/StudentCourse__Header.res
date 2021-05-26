let str = React.string
%bs.raw(`require("./StudentCourse__Header.css")`)
%bs.raw(`require("courses/shared/background_patterns.css")`)

let courseOptions = courses => Js.Array.map(course => {
    let courseId = CourseInfo.id(course)
    <a
      key={"course-" ++ courseId}
      href={"/courses/" ++ (courseId ++ "/curriculum")}
      className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 whitespace-no-wrap">
      <span> {CourseInfo.name(course)->str} </span>
    </a>
  }, Js.Array.filter(
    course => Belt.Option.mapWithDefault(CourseInfo.endsAt(course), true, DateFns.isFuture),
    courses,
  ))

let courseDropdown = (currentCourse, otherCourses) =>
  <div>
    {switch otherCourses {
    | [] =>
      <div
        className="flex max-w-xs md:max-w-xl mx-auto items-center relative justify-between font-semibold relative rounded w-full text-lg md:text-2xl leading-tight text-white">
        <span className="sm:truncate w-full text-left">
          {CourseInfo.name(currentCourse)->str}
        </span>
      </div>
    | otherCourses =>
      let selected =
        <button
          className="dropdown__btn max-w-xs md:max-w-lg mx-auto text-white appearance-none flex items-center relative justify-between focus:outline-none font-semibold w-full text-lg md:text-2xl leading-tight">
          <span className="sm:truncate w-full text-left">
            {CourseInfo.name(currentCourse)->str}
          </span>
          <div
            className="student-course__dropdown-btn ml-3 hover:bg-primary-100 hover:text-primary-500 flex items-center justify-between px-3 py-2 rounded">
            <i className="fas fa-chevron-down text-xs font-semibold" />
          </div>
        </button>

      <Dropdown
        selected
        contents={courseOptions(otherCourses)}
        className="student-course__dropdown relative mx-auto"
      />
    }}
  </div>

let courseNameContainerClasses = additionalLinks =>
  "student-course__name-container w-full absolute bottom-0 " ++ (
    additionalLinks->ArrayUtils.isEmpty ? "pt-2 pb-3 md:pt-4 md:pb-6" : "pt-2 pb-3 md:pt-4 md:pb-12"
  )

let renderCourseSelector = (currentCourseId, courses, coverImage, additionalLinks) => {
  let currentCourse = ArrayUtils.unsafeFind(
    c => CourseInfo.id(c) == currentCourseId,
    "Could not find current course with ID " ++ (currentCourseId ++ " in StudentCourse__Header"),
    courses,
  )
  let otherCourses = Js.Array.filter(c => CourseInfo.id(c) != currentCourseId, courses)
  <div className="relative bg-primary-900">
    <div className="relative pb-1/2 md:pb-1/4 2xl:pb-1/5">
      {switch coverImage {
      | Some(src) => <img className="absolute h-full w-full object-cover" src />
      | None =>
        <div className="student-course__cover-default absolute h-full w-full svg-bg-pattern-1" />
      }}
    </div>
    <div className={courseNameContainerClasses(additionalLinks)}>
      <div className="student-course__name relative px-4 lg:px-0 flex h-full mx-auto lg:max-w-3xl">
        {courseDropdown(currentCourse, otherCourses)}
      </div>
    </div>
  </div>
}

let tabClasses = (url: RescriptReactRouter.url, linkTitle) => {
  let defaultClasses = "student-course__nav-tab py-4 px-2 text-center flex-1 font-semibold text-sm "
  switch url.path {
  | list{"courses", _targetId, pageTitle, ..._} when pageTitle == linkTitle =>
    defaultClasses ++ "student-course__nav-tab--active"
  | _ => defaultClasses
  }
}

@react.component
let make = (~currentCourseId, ~courses, ~additionalLinks, ~coverImage) => {
  let url = RescriptReactRouter.useUrl()

  <div>
    {renderCourseSelector(currentCourseId, courses, coverImage, additionalLinks)}
    {switch additionalLinks {
    | [] => React.null
    | additionalLinks =>
      <div className="md:px-3">
        <div
          className="bg-white border-transparent flex justify-between overflow-x-auto md:overflow-hidden lg:max-w-3xl mx-auto shadow md:rounded-lg mt-0 md:-mt-7 z-10 relative">
          {Js.Array.map(l => {
            let (title, suffix) = switch l {
            | "curriculum" => ("Curriculum", "curriculum")
            | "calendar" => ("Calendar", "calendar")
            | "leaderboard" => ("Leaderboard", "leaderboard")
            | "review" => ("Review", "review")
            | "students" => ("Students", "students")
            | "report" => ("Report", "report")
            | _unknown => ("Unknown", "")
            }

            <a
              key=title
              href={"/courses/" ++ (currentCourseId ++ ("/" ++ suffix))}
              className={tabClasses(url, suffix)}>
              {title->str}
            </a>
          }, Js.Array.concat(additionalLinks, ["curriculum"]))->React.array}
        </div>
      </div>
    }}
  </div>
}
