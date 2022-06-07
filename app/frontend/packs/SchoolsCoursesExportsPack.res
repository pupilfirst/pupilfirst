open CourseExports__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("course", Course.decode),
    json |> field("exports", array(CourseExport.decode)),
    json |> field("tags", array(Tag.decode)),
  )
}

let (course, exports, tags) =
  DomUtils.parseJSONTag(~id="schools-courses-exports__props", ()) |> decodeProps

switch ReactDOM.querySelector("#schools-courses-exports__root") {
| Some(root) => ReactDOM.render(<CourseExports__Root course exports tags />, root)
| None => ()
}
