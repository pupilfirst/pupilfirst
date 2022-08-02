type contextType = {
  selectedCourse: option<AppRouter__Course.t>,
  setSelectedCourseCB: string => unit,
}

let context = React.createContext({
  selectedCourse: None,
  setSelectedCourseCB: _ => (),
})

module Provider = {
  let provider = React.Context.provider(context)

  @react.component
  let make = (~value, ~children) => {
    React.createElement(provider, {"value": value, "children": children})
  }
}
