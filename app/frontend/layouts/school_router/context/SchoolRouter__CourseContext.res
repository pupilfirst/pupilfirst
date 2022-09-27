type t = {
  selectedCourse: option<AppRouter__Course.t>,
  setCourseId: string => unit,
}

let context = React.createContext({
  selectedCourse: None,
  setCourseId: _ => (),
})

module Provider = {
  let provider = React.Context.provider(context)

  @react.component
  let make = (~value, ~children) => {
    React.createElement(provider, {"value": value, "children": children})
  }
}
