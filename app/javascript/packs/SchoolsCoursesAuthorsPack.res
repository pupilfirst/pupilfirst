open CourseAuthors__Types

let decodeProps = json => {
  open Json.Decode
  (json |> field("courseId", string), json |> field("authors", array(Author.decode)))
}

let (courseId, authors) =
  DomUtils.parseJSONTag(~id="schools-courses-authors__props", ()) |> decodeProps

switch ReactDOM.querySelector("#schools-courses-authors__root") {
| Some(root) => ReactDOM.render(<CourseAuthors__Root courseId authors />, root)
| None => ()
}
