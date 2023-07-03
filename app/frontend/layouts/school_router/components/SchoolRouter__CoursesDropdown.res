let str = React.string

let t = I18n.t(~scope="components.SchoolRouter__CoursesDropdown")

open SchoolRouter__Types

let selected = currentCourse => {
  let title = currentCourse->Belt.Option.mapWithDefault(t("select_course"), c => Course.name(c))
  <button
    title={title}
    className="bg-gray-50 rounded text-sm w-full appearance-none flex items-center justify-between hover:bg-primary-50 hover:text-primary-500 focus:outline-none focus:bg-gray-100 focus:text-primary-500 font-semibold relative px-2 py-2">
    <span className="w-5/6 flex items-center">
      <Icon className="if i-journal-text-light" />
      <span className="block whitespace-nowrap px-2 ">
        {title->str}
      </span>
    </span>
    <span className="w-1/6 ltr:text-right rtl:text-left pt-0.5">
      <Icon className="if i-chevron-down-light text-sm" />
    </span>
  </button>
}

let contents = (courses, currentCourse) =>
  Js.Array.map(
    course =>
      <a
        className="block px-4 py-3 text-xs font-semibold text-gray-900 bg-white hover:text-primary-500 hover:bg-gray-200 focus:outline-none focus:text-primary-500 focus:bg-gray-200 "
        key={course->Course.id}
        href={"/school/courses/" ++ (course->Course.id ++ "/curriculum")}>
        {Course.name(course)->str}
      </a>,
    Js.Array.filter(
      course =>
        currentCourse->Belt.Option.mapWithDefault(true, c => Course.id(course) != Course.id(c)) &&
          !Course.ended(course),
      courses,
    ),
  )

@react.component
let make = (~courses) => {
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)
  let currentCourse = courseContext.selectedCourse

  <Dropdown
    className="w-full md:text-base"
    selected={selected(currentCourse)}
    contents={contents(courses, currentCourse)}
  />
}
