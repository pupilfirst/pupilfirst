@module("./iconFirst")
external transformIcons: unit => unit = "transformIcons"

@react.component
let make = (~className) => {
  React.useEffect1(() => {
    transformIcons()
    None
  }, [className])
  <span key=className> <i className /> </span>
}
