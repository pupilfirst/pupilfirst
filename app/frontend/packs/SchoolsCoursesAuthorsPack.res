open CourseAuthors__Types

let decodeProps = json => {
  open Json.Decode
  (json |> field("courseId", string), json |> field("authors", array(Author.decode)))
}

Psj.matchPaths(
  [
    "school/courses/:course_id/authors",
    "school/courses/:course_id/authors/:author_id",
    "school/courses/:course_id/authors/new",
  ],
  () => {
    switch ReactDOM.querySelector("#schoolrouter-innerpage") {
    | Some(root) => {
        let (courseId, authors) =
          DomUtils.parseJSONTag(~id="schools-courses-authors__props", ()) |> decodeProps
        ReactDOM.render(<CourseAuthors__Root courseId authors />, root)
      }
    | None => ()
    }
  },
)
