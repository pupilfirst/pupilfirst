open AppRouter__Types

let decodeProps = json => {
  open Json.Decode
  (
    field("courses", array(Course.decode), json),
    field("currentUser", optional(User.decode), json),
    field("school", School.decode, json),
  )
}

Psj.matchPaths(["courses/:id/review", "submissions/:id/review"], () => {
  let (courses, currentUser, school) = DomUtils.parseJSONTag(~id="app-router-data", ())->decodeProps

  switch ReactDOM.querySelector("#app-router") {
  | Some(root) => ReactDOM.render(<AppRouter school courses currentUser />, root)
  | None => ()
  }
})
