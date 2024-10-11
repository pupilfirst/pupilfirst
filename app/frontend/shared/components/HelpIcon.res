let str = React.string

let t = I18n.t(~scope="components.HelpIcon", ...)

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
    let mobileClass = alignmentClass(mobileAlignment)

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
    let onClick = event => onWindowClick(helpVisible, setHelpVisible, event)
    let window = Webapi.Dom.window

    let removeEventListener = () => Webapi.Dom.Window.removeEventListener(window, "click", onClick)

    if helpVisible {
      Webapi.Dom.Window.addEventListener(window, "click", onClick)
      Some(removeEventListener)
    } else {
      removeEventListener()
      None
    }
  }, [helpVisible])

  <div
    className={"inline-block relative " ++ className}
    onClick={event => toggleHelp(setHelpVisible, event)}>
    <FaIcon classes="fas fa-question-circle rtl:scale-x-[-1] hover:text-gray-600 cursor-pointer" />
    {helpVisible
      ? <div
          onClick={event => ReactEvent.Mouse.stopPropagation(event)}
          className={"help-icon__help-container overflow-y-auto mt-1 border border-gray-900 absolute z-50 px-4 py-3 shadow-lg leading-snug rounded-lg bg-gray-900 text-white max-w-xs" ++
          responsiveAlignmentClass(responsiveAlignment)}>
          children
          {OptionUtils.default(React.null, OptionUtils.map(link =>
              <a href=link target="_blank" className="block mt-1 text-blue-300 hover:text-blue:200">
                <FaIcon classes="fas fa-external-link-square-alt rtl:-rotate-90" />
                <span className="ms-1"> {str(t("read_more"))} </span>
              </a>
            , link))}
        </div>
      : React.null}
  </div>
}

module Decode = {
  open Json.Decode

  let props = object(field => {
    let responsiveAlignment =
      field.optional("responsiveAlignment", option(string))
      ->OptionUtils.flat
      ->Option.map(responsiveAlignment =>
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

    (
      field.optional("className", option(string))->OptionUtils.flat,
      field.optional("link", option(string))->OptionUtils.flat,
      responsiveAlignment,
      field.required("children", string),
    )
  })
}

let makeFromJson = json => {
  let (className, link, responsiveAlignment, children) =
    json->Json.decode(Decode.props)->Result.getExn

  make({
    ?className,
    ?link,
    ?responsiveAlignment,
    children: <div dangerouslySetInnerHTML={{"__html": children}} />,
  })
}
