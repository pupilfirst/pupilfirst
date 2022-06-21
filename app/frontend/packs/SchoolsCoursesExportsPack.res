open CourseExports__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("course", Course.decode),
    json |> field("exports", array(CourseExport.decode)),
    json |> field("tags", array(Tag.decode)),
  )
}

Psj.match("schools/courses#exports", () => {
  switch ReactDOM.querySelector("#schools-courses-exports__root") {
  | Some(root) => {
      let (course, exports, tags) =
        DomUtils.parseJSONTag(~id="schools-courses-exports__props", ()) |> decodeProps
      ReactDOM.render(<CourseExports__Root course exports tags />, root)
    }
  | None => ()
  }
})
