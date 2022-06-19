let str = React.string

let isPast = date => date->Belt.Option.mapWithDefault(false, DateFns.isPast)

let selected = currentCourse =>
  <button
    title={CourseInfo.name(currentCourse)}
    className="border-b border-gray-300 rounded w-full appearance-none flex items-center justify-between hover:bg-primary-100 hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-medium relative px-2 py-2">
    <span className="w-5/6 flex items-center">
      <i className="fas fa-book" />
      <span className="truncate ml-2 text-left"> {CourseInfo.name(currentCourse)->str} </span>
    </span>
    <span className="w-1/6 text-right"> <i className="fas fa-chevron-down text-sm" /> </span>
  </button>

let contents = (courses, currentCourse) =>
  Js.Array.map(
    course =>
      <a
        className="block px-4 py-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 w-40 truncate"
        key={course->CourseInfo.id}
        href={"/school/courses/" ++ (course->CourseInfo.id ++ "/curriculum")}>
        {CourseInfo.name(course)->str}
      </a>,
    Js.Array.filter(
      course =>
        CourseInfo.id(course) != CourseInfo.id(currentCourse) && !isPast(CourseInfo.endsAt(course)),
      courses,
    ),
  )

@react.component
let make = (~courses, ~currentCourseId) => {
  let currentCourse = ArrayUtils.unsafeFind(
    course => CourseInfo.id(course) == currentCourseId,
    "Could not find currentCourse with ID " ++ currentCourseId,
    courses,
  )

  <Dropdown
    className="w-full md:text-base"
    selected={selected(currentCourse)}
    contents={contents(courses, currentCourse)}
  />
}
