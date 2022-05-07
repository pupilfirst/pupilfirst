type emojiEvent = {
  id: string,
  native: string,
  unifield: string,
  shortcodes: string,
}

module JsComponent = {
  @module("./EmojiPicker") @react.component
  external make: (
    ~className: string=?,
    ~title: string=?,
    ~onChange: emojiEvent => unit,
  ) => React.element = "default"
}

@react.component
let make = (~className, ~title, ~onChange) => <JsComponent className title onChange />
