let context = React.createContext(([]: array<string>))

let enabled = key => {
  let toggles = React.useContext(context)
  Js.Array2.some(toggles, x => x == key)
}

module Provider = {
  type propsInner = {value: array<string>, children: React.element}

  let provider = React.Context.provider(context)

  @react.component
  let make = (~value, ~children) => {
    React.createElement(provider, {value, children})
  }
}
