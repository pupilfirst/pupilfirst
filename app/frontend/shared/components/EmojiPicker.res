open Webapi.Dom

type emojiEvent = {
  id: string,
  native: string,
  unifield: string,
  shortcodes: string,
}

@module("@emoji-mart/data") external data: Js.Json.t = "default"

module Picker = {
  @module("@emoji-mart/react") @react.component
  external make: (
    ~title: string,
    ~theme: [#light],
    ~onEmojiSelect: emojiEvent => unit,
    ~data: Js.Json.t,
  ) => React.element = "default"
}

let emojiDivClassName = isOpen => {
  switch isOpen {
  | true => "absolute top-full -start-32 md:-translate-x-0 z-10 shadow "
  | false => "hidden"
  }
}

@react.component
let make = (~className, ~title, ~onChange) => {
  let wrapperRef = React.useRef(Js.Nullable.null)
  let (isOpen, setIsOpen) = React.useState(_ => false)

  React.useEffect0(() => {
    let handleClickOutside: Dom.mouseEvent => unit = event => {
      switch wrapperRef.current->Js.Nullable.toOption {
      | Some(wrapper) =>
        if (
          !(
            wrapper->Element.contains(
              ~child=event |> MouseEvent.target |> EventTarget.unsafeAsElement,
            )
          )
        ) {
          setIsOpen(_ => false)
        }
      | None => ()
      }

      ()
    }

    let handleEscKey: Dom.keyboardEvent => unit = e => {
      let key = e |> KeyboardEvent.key
      if key == "Escape" || key == "Esc" {
        setIsOpen(_ => false)
      }
      ()
    }

    document->Document.addKeyUpEventListener(handleEscKey)
    document->Document.addClickEventListener(handleClickOutside)

    Some(
      () => {
        document->Document.removeKeyUpEventListener(handleEscKey)
        document->Document.removeClickEventListener(handleClickOutside)
      },
    )
  })

  <div className="sm:relative inline-block" ref={ReactDOM.Ref.domRef(wrapperRef)}>
    <button
      type_="button"
      ariaLabel={title}
      title={title}
      onClick={_ => setIsOpen(prev => !prev)}
      className={className}>
      <i className="fas fa-smile" />
    </button>
    <div className={"transition-all " ++ emojiDivClassName(isOpen)}>
      <Picker
        title
        data
        onEmojiSelect={event => {
          onChange(event)
          setIsOpen(_ => false)
        }}
        theme={#light}
      />
    </div>
  </div>
}
