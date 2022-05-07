module JsComponent = {
  @module("./EmojiPicker") @react.component
  external make: (~className: string=?, ~title: string=?) => React.element = "default"
}

@react.component
let make = (~className, ~title) => <JsComponent className title />
