let str = React.string

let t = I18n.t(~scope="components.HelpIcon")

%%raw(`import "./HelpIcon.css"`)

let onWindowClick = (helpVisible, setHelpVisible, _event) =>
  if helpVisible {
    setHelpVisible(_ => false)
  } else {
    ()
  }

let toggleHelp = (setHelpVisible, _event) => setHelpVisible(helpVisible => !helpVisible)

type rec responsiveAlignment =
  | NonResponsive(alignment)
  | Responsive(alignment, alignment)
and alignment =
  | AlignLeft
  | AlignRight
  | AlignCenter

let alignmentClass = alignment =>
  switch alignment {
  | AlignLeft => " start-0"
  | AlignRight => " end-0"
  | AlignCenter => " help-icon__help-container--center"
  }

let responsiveAlignmentClass = responsiveAlignment =>
  switch responsiveAlignment {
  | NonResponsive(alignment) => alignmentClass(alignment)
  | Responsive(mobileAlignment, desktopAlignment) =>
    let mobileClass = mobileAlignment |> alignmentClass

    let desktopClass = switch desktopAlignment {
    | AlignLeft => " md:right-auto md:start-0"
    | AlignRight => " md:left-auto md:end-0"
    | AlignCenter => " help-icon__help-container--md-center"
    }

    mobileClass ++ (" " ++ desktopClass)
  }

@react.component
let make = (~className="", ~link=?, ~responsiveAlignment=NonResponsive(AlignCenter), ~children) => {
  let (helpVisible, setHelpVisible) = React.useState(() => false)

  React.useEffect1(() => {
    let curriedFunction = onWindowClick(helpVisible, setHelpVisible)
    let window = Webapi.Dom.window

    let removeEventListener = () =>
      Webapi.Dom.Window.removeEventListener(window, "click", curriedFunction)

    if helpVisible {
      Webapi.Dom.Window.addEventListener(window, "click", curriedFunction)
      Some(removeEventListener)
    } else {
      removeEventListener()
      None
    }
  }, [helpVisible])

  <div className={"inline-block relative " ++ className} onClick={toggleHelp(setHelpVisible)}>
    <FaIcon classes="fas fa-question-circle rtl:scale-x-[-1] hover:text-gray-600 cursor-pointer" />
    {helpVisible
      ? <div
          onClick={event => event |> ReactEvent.Mouse.stopPropagation}
          className={"help-icon__help-container overflow-y-auto mt-1 border border-gray-900 absolute z-50 px-4 py-3 shadow-lg leading-snug rounded-lg bg-gray-900 text-white max-w-xs" ++
          (responsiveAlignment |> responsiveAlignmentClass)}>
          children
          {link
          |> OptionUtils.map(link =>
            <a href=link target="_blank" className="block mt-1 text-blue-300 hover:text-blue:200">
              <FaIcon classes="fas fa-external-link-square-alt rtl:-rotate-90" />
              <span className="ms-1"> {t("read_more") |> str} </span>
            </a>
          )
          |> OptionUtils.default(React.null)}
        </div>
      : React.null}
  </div>
}

let makeFromJson = json => {
  open Json.Decode

  let responsiveAlignment = optional(
    field("responsiveAlignment", string),
    json,
  )->Belt.Option.map(responsiveAlignment =>
    switch responsiveAlignment {
    | "nrl" => NonResponsive(AlignLeft)
    | "nrc" => NonResponsive(AlignCenter)
    | "nrr" => NonResponsive(AlignRight)
    | "rlr" => Responsive(AlignLeft, AlignRight)
    | "rrl" => Responsive(AlignRight, AlignLeft)
    | "rlc" => Responsive(AlignLeft, AlignCenter)
    | "rcl" => Responsive(AlignCenter, AlignLeft)
    | "rrc" => Responsive(AlignRight, AlignCenter)
    | "rcr" => Responsive(AlignCenter, AlignRight)
    | _ => NonResponsive(AlignCenter)
    }
  )

  make({
    "className": optional(field("className", string), json),
    "link": optional(field("link", string), json),
    "responsiveAlignment": responsiveAlignment,
    "children": <div dangerouslySetInnerHTML={{"__html": field("children", string, json)}} />,
  })
}
