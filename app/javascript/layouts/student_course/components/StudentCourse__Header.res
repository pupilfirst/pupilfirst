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


  let courseTitle = currentCourse =>
  <h1 className="text-white text-3xl md:text-6xl leading-tight max-w-lg">{CourseInfo.name(currentCourse)->str}</h1>

let courseNameContainerClasses = additionalLinks =>
  "student-course__name-container w-full " ++ (
    additionalLinks->ArrayUtils.isEmpty ? "pt-2 pb-3 md:pt-4 md:pb-6" : "pt-2 pb-3 md:pt-4 md:pb-12"
  )

let renderCourseSelector = (currentCourseId, courses, coverImage) => {
  let currentCourse = ArrayUtils.unsafeFind(
    c => CourseInfo.id(c) == currentCourseId,
    "Could not find current course with ID " ++ (currentCourseId ++ " in StudentCourse__Header"),
    courses,
  )
  <div className="relative bg-white">
    <div className="relative py-18">
      {switch coverImage {
      | Some(src) => <img className="absolute top-0 left-0 h-full w-full object-cover" src />
      | None =>
        <div className=" student-course__cover-default top-0 left-0 absolute h-full w-full svg-bg-pattern-1" />
      }}
      <div className="student-course__name   relative px-4 lg:px-0 py- flex h-full mx-auto lg:max-w-6xl">
        {courseTitle(currentCourse)}
      </div>
    </div>
  </div>
}

let tabClasses = (url: RescriptReactRouter.url, linkTitle) => {
  let defaultClasses = "text-current hover:text-siliconBlue-900 hover:bg-gray-200 transition duration-300 text-lg px-6 py-3 font-semibold block rounded-full"
  switch url.path {
  | list{"courses", _targetId, pageTitle, ..._} when pageTitle == linkTitle =>
    "text-lg px-6 py-3 font-semibold block rounded-full bg-siliconBlue-900 text-white  hover:bg-siliconBlue-800"
  | _ => defaultClasses
  }
}

@react.component
let make = (~currentCourseId, ~courses, ~additionalLinks, ~coverImage) => {
  let url = RescriptReactRouter.useUrl()

  <div className="bg-white overflow-hidden">
    {renderCourseSelector(currentCourseId, courses, coverImage)}
    {switch additionalLinks {
    | [] => React.null
    | additionalLinks =>
      <div className="lg:max-w-6xl mx-auto mt-8 md:mt-12 flex items-start justify-start overflow-hidden ">
        <div
          className="z-10 relative px-2 md:px-0 flex flex-col md:flex-row overflow-hidden text-washedBlue md:border border-gray-300 md:rounded-full">
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
