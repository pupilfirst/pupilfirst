Psj.matchPaths(
  [
    "school/courses",
    "school/courses/new",
    "school/courses/:id/details",
    "school/courses/:id/images",
    "school/courses/:id/actions",
  ],
  () => {
    switch ReactDOM.querySelector("#course-editor") {
    | Some(element) => ReactDOM.render(<CourseEditor />, element)
    | None => ()
    }
  },
)
