@react.component
let make = (~props, ~children) => React.cloneElement(children, props)
