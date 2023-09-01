open CourseExports__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("course", Course.decode),
    json |> field("exports", array(CourseExport.decode)),
    json |> field("tags", array(Tag.decode)),
    json |> field("cohorts", array(Cohort.decode)),
  )
}

Psj.match("schools/courses#exports", () => {
  switch ReactDOM.querySelector("#schoolrouter-innerpage") {
  | Some(root) => {
      let (course, exports, tags, cohorts) =
        DomUtils.parseJSONTag(~id="schools-courses-exports__props", ()) |> decodeProps
      ReactDOM.render(<CourseExports__Root course exports tags cohorts />, root)
    }
  | None => ()
  }
})
