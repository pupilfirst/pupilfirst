let ctrlKey = Webapi.Dom.KeyboardEvent.ctrlKey
let metaKey = Webapi.Dom.KeyboardEvent.metaKey

external unsafeAsKeyboardEvent: ReactEvent.Mouse.t => Webapi.Dom.KeyboardEvent.t = "%identity"

let onConfirm = (href, onClick, event) => {
  ReactEvent.Mouse.preventDefault(event)
  Belt.Option.mapWithDefault(onClick, (), onClick => onClick(event))
  RescriptReactRouter.push(href)
}

let onCancel = event => event |> ReactEvent.Mouse.preventDefault

let handleOnClick = (href, confirm, onClick, event) => {
  let keyboardEvent = event |> unsafeAsKeyboardEvent
  let modifierPressed = keyboardEvent |> ctrlKey || keyboardEvent |> metaKey

  switch (modifierPressed, confirm) {
  | (true, _) => ()
  | (false, Some(confirmationText)) =>
    WindowUtils.confirm(
      ~onCancel=() => onCancel(event),
      confirmationText,
      () => onConfirm(href, onClick, event),
    )
  | (false, None) => onConfirm(href, onClick, event)
  }
}

@react.component
let make = (
  ~href,
  ~ariaLabel=?,
  ~className=?,
  ~confirm=?,
  ~id=?,
  ~onClick=?,
  ~title=?,
  ~children,
  ~props=?,
) => {
  let switchProps = Belt.Option.getWithDefault(props, Js.Obj.empty())
  <Spread props={switchProps}>
    <a href ?ariaLabel ?className ?id ?title onClick={handleOnClick(href, confirm, onClick)}>
      children
    </a>
  </Spread>
}
