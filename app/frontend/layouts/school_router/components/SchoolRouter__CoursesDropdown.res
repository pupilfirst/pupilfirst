let str = React.string

open SchoolRouter__Types

let selected = currentCourse =>
  <button
    title={Course.name(currentCourse)}
    className="rounded w-full appearance-none flex items-center justify-between hover:bg-primary-50 hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-semibold relative px-2 py-3">
    <span className="w-5/6 flex items-center">
      <i className="fas fa-book" />
      <span className="truncate ml-2 text-left"> {Course.name(currentCourse)->str} </span>
    </span>
    <span className="w-1/6 text-right"> <i className="fas fa-chevron-down text-sm" /> </span>
  </button>

let contents = (courses, currentCourse) =>
  Js.Array.map(
    course =>
      <a
        className="block px-4 py-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 focus:outline-none focus:text-primary-500 focus:bg-gray-200 w-40 truncate"
        key={course->Course.id}
        href={"/school/courses/" ++ (course->Course.id ++ "/curriculum")}>
        {Course.name(course)->str}
      </a>,
    Js.Array.filter(
      course => Course.id(course) != Course.id(currentCourse) && !Course.ended(course),
      courses,
    ),
  )

@react.component
let make = (~courses, ~currentCourseId) => {
  let currentCourse = ArrayUtils.unsafeFind(
    course => Course.id(course) == currentCourseId,
    "Could not find currentCourse with ID " ++ currentCourseId,
    courses,
  )

  <Dropdown
    className="w-full md:text-base"
    selected={selected(currentCourse)}
    contents={contents(courses, currentCourse)}
  />
}
