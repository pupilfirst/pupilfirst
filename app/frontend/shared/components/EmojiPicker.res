open Webapi.Dom

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

@module("emoji-mart") @new external picker: args => unit = "Picker"

@module("@emoji-mart/data") external data: Js.Json.t = "default"

let emojiDivClassName = isOpen => {
  switch isOpen {
  | true => "absolute top-full -start-32 md:-translate-x-0 z-10 shadow "
  | false => "hidden"
  }
}

@react.component
let make = (~className, ~title, ~onChange) => {
  let ref = React.useRef(Js.Nullable.null)
  let wrapperRef = React.useRef(Js.Nullable.null)
  let (isOpen, setIsOpen) = React.useState(_ => false)

  React.useEffect1(() => {
    picker({
      title: title,
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
          !(wrapper |> Element.contains(event |> MouseEvent.target |> EventTarget.unsafeAsElement))
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

    document |> Document.addKeyUpEventListener(handleEscKey)
    document |> Document.addClickEventListener(handleClickOutside)

    Some(
      () => {
        document |> Document.removeKeyUpEventListener(handleEscKey)
        document |> Document.removeClickEventListener(handleClickOutside)
      },
    )
  }, [onChange])

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
      <div ref={ReactDOM.Ref.domRef(ref)} />
    </div>
  </div>
}
