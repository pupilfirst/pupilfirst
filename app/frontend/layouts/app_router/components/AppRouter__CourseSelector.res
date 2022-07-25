let str = React.string

open AppRouter__Types

let selected = currentCourse =>
  <button
    title={Course.name(currentCourse)}
    className="text-white md:text-gray-900 bg-gray-900 md:bg-gray-50 appearance-none flex items-center justify-between hover:bg-gray-50 focus:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-semibold relative px-3 py-2 rounded-md w-full focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 ">
    <span className="w-5/6 flex items-center">
      <i className="fas fa-book" />
      <span className="truncate ml-2 text-left"> {Course.name(currentCourse)->str} </span>
    </span>
    <span className="w-1/6 text-right"> <i className="fas fa-chevron-down text-sm" /> </span>
  </button>

let contents = (courses, currentCourse, selectedPage) => {
  Js.Array.map(
    course =>
      <a
        className="block px-4 py-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 whitespace-normal focus:ring-2 focus:ring-inset focus:ring-focusColor-500 "
        key={course->Course.id}
        href={Page.canAccessPage(selectedPage, course)
          ? Page.path(Page.changeId(selectedPage, Course.id(course)))
          : Page.path(Page.Student__Curriculum(Course.id(course)))}>
        {Course.name(course)->str}
      </a>,
    Js.Array.filter(
      course => Course.id(course) != Course.id(currentCourse) && !Course.accessEnded(course),
      courses,
    ),
  )
}

@react.component
let make = (~courses, ~selectedPage, ~currentCourseId) => {
  let currentCourse = ArrayUtils.unsafeFind(
    course => Course.id(course) == currentCourseId,
    "Could not find currentCourse with ID " ++ currentCourseId,
    courses,
  )

  <Dropdown
    className="w-full md:text-base"
    selected={selected(currentCourse)}
    contents={contents(courses, currentCourse, selectedPage)}
  />
}
