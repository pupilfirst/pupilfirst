type emojiEvent = {
  id: string,
  native: string,
  unifield: string,
  shortcodes: string,
}

type args = {
  title: string,
  ref: React.ref<Js.Nullable.t<Dom.element>>,
  theme: string,
  onEmojiSelect: emojiEvent => unit,
  data: Js.Json.t,
}

type t
@module("emoji-mart") @new external picker: args => t = "Picker"

type data
@module external data: Js.Json.t = "@emoji-mart/data"

let emojiDivClassName = isOpen => {
  switch isOpen {
  | true => "absolute top-11 sm:top-full sm:left-full z-10 shadow left-1/2 -translate-x-1/2 sm:translate-x-0"
  | false => "hidden"
  }
}

@react.component
let make = (~className, ~title, ~onChange) => {
  let ref = React.useRef(Js.Nullable.null)
  let wrapperRef = React.useRef(Js.Nullable.null)
  let (isOpen, setIsOpen) = React.useState(_ => false)

  React.useEffect0(() => {
    let _ = picker({
      title: "",
      ref: ref,
      theme: "light",
      data: data,
      onEmojiSelect: event => {
        onChange(event)
        setIsOpen(_ => false)
      },
    })

    let handleClickOutside: Dom.mouseEvent => unit = event => {
      switch wrapperRef.current->Js.Nullable.toOption {
      | Some(wrapper) =>
        if (
          !(
            wrapper |> Webapi.Dom.Element.contains(
              event |> Webapi.Dom.MouseEvent.target |> Webapi.Dom.EventTarget.unsafeAsElement,
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
      let key = e |> Webapi.Dom.KeyboardEvent.key
      if key == "Escape" || key == "Esc" {
        setIsOpen(_ => false)
      }
      ()
    }

    Webapi.Dom.document |> Webapi.Dom.Document.addKeyUpEventListener(handleEscKey)
    Webapi.Dom.document |> Webapi.Dom.Document.addClickEventListener(handleClickOutside)

    Some(
      () => {
        Webapi.Dom.document |> Webapi.Dom.Document.removeKeyUpEventListener(handleEscKey)
        Webapi.Dom.document |> Webapi.Dom.Document.removeClickEventListener(handleClickOutside)
      },
    )
  })

  <div className="sm:relative inline-block" ref={ReactDOM.Ref.domRef(wrapperRef)}>
    <button
      ariaLabel={title} title={title} onClick={_ => setIsOpen(prev => !prev)} className={className}>
      <i className="fas fa-smile" />
    </button>
    <div className={"transition-all " ++ emojiDivClassName(isOpen)}>
      <div ref={ReactDOM.Ref.domRef(ref)} />
    </div>
  </div>
}
