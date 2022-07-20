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
    <span className="w-1/6 text-right">
      <i className="fas fa-chevron-down text-sm" />
    </span>
  </button>

let showLink = (id, selectedPage, coursePage, classes, contents) => {
  Page.useSPA(selectedPage, Page.SelectedCourse(id, coursePage))
    ? <Link href={Page.coursePath(id, coursePage)} className=classes> {contents} </Link>
    : <a href={Page.coursePath(id, coursePage)} className=classes> {contents} </a>
}

let contents = (courses, currentCourse, coursePage, selectedPage) => {
  Js.Array.map(course => {
    let href = {
      Page.canAccessPage(coursePage, course)
        ? Page.coursePath(Course.id(course), coursePage)
        : Page.coursePath(Course.id(course), Page.Curriculum)
    }
    let classes = "block px-4 py-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 whitespace-normal focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
    Page.useSPA(selectedPage, Page.SelectedCourse(Course.id(course), coursePage))
      ? <Link href className=classes> {Course.name(course)->str} </Link>
      : <a href className=classes> {Course.name(course)->str} </a>
  }, Js.Array.filter(
    course => Course.id(course) != Course.id(currentCourse) && !Course.accessEnded(course),
    courses,
  ))
}

@react.component
let make = (~courses, ~selectedPage, ~coursePage, ~currentCourse) => {
  <Dropdown
    className="w-full md:text-base"
    selected={selected(currentCourse)}
    contents={contents(courses, currentCourse, coursePage, selectedPage)}
  />
}
