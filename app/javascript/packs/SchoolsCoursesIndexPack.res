switch ReactDOM.querySelector("#course-editor") {
| Some(element) => ReactDOM.render(<CourseEditor />, element)
| None => ()
}
