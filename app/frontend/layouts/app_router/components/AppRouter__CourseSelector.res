let str = React.string

open AppRouter__Types

let selected = currentCourse =>
  <button
    title={Course.name(currentCourse)}
    className="text-white md:text-gray-900 bg-gray-900 md:bg-gray-100 appearance-none flex items-center justify-between hover:bg-gray-800 md:hover:bg-gray-50 hover:text-gray-50 focus:bg-gray-50 md:hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-semibold relative px-3 py-2 rounded-md w-full focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 ">
    <span className="w-5/6 flex items-center">
      <i className="fas fa-book" />
      <span className="truncate ml-2 text-left"> {Course.name(currentCourse)->str} </span>
    </span>
    <span className="w-1/6 text-right"> <i className="fas fa-chevron-down text-sm" /> </span>
  </button>

let contents = (courses, currentCourse, coursePage, selectedPage) => {
  Js.Array.map(course => {
    let nextPage = Page.canAccessPage(coursePage, course) ? coursePage : Page.Curriculum
    let href = Page.coursePath(Course.id(course), nextPage)

    let classes = "block px-4 py-3 text-xs font-semibold text-gray-900 bg-white hover:text-primary-500 hover:bg-gray-50 whitespace-normal focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
    Page.useSPA(selectedPage, Page.SelectedCourse(Course.id(course), nextPage))
      ? <Link key={Course.id(course)} href className=classes> {Course.name(course)->str} </Link>
      : <a key={Course.id(course)} href className=classes> {Course.name(course)->str} </a>
  }, Js.Array.filter(
    course => Course.id(course) != Course.id(currentCourse) && !Course.ended(course),
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
