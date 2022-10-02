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

let link = (href, includeSearch) => {
  let search = Webapi.Dom.window->Webapi.Dom.Window.location->Webapi.Dom.Location.search
  includeSearch ? `${href}${search}` : href
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
  ~includeSearch=false,
  ~disabled=false,
  ~props=?,
) => {
  let switchProps = Belt.Option.getWithDefault(props, Js.Obj.empty())
  <Spread props={switchProps}>
    <a
      href={link(href, includeSearch)}
      ?ariaLabel
      ?className
      ?id
      ?title
      onClick={handleOnClick(link(href, includeSearch), confirm, onClick)}
      disabled>
      children
    </a>
  </Spread>
}
