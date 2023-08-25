open AppRouter__Types

let decodeProps = json => {
  open Json.Decode
  (field("courses", array(Course.decode), json), field("currentUser", optional(User.decode), json))
}

Psj.matchPaths(["courses/:id/review", "submissions/:id/review", "students/:id/report"], () => {
  let (courses, currentUser) = DomUtils.parseJSONTag(~id="app-router-data", ())->decodeProps

  switch ReactDOM.querySelector("#app-router") {
  | Some(root) => ReactDOM.render(<AppRouter courses currentUser />, root)
  | None => ()
  }
})
