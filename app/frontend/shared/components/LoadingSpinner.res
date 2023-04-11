%%raw(`import "./LoadingSpinner.css"`)

let str = React.string
let ts = I18n.t(~scope="shared")

let onAnimationEnd = (loading, setRender) =>
  if !loading {
    setRender(_ => false)
  }

let animationClass = loading =>
  loading ? "loading-spinner__slide-up" : "loading-spinner__slide-down"

@react.component
let make = (~loading, ~message=ts("loading")) => {
  let (shouldRender, setRender) = React.useState(() => loading)
  let initialRender = React.useRef(true)
  React.useEffect1(() => {
    if initialRender.current {
      initialRender.current = false
    } else if loading {
      setRender(_ => true)
    }
    None
  }, [loading])
  shouldRender
    ? <div className="fixed bottom-0 z-50 w-full start-0 end-0 flex justify-center w-full">
        <div
          className={"loading-spinner__container " ++ animationClass(loading)}
          onAnimationEnd={_ => onAnimationEnd(loading, setRender)}>
          <div className="loading-spinner__xs">
            <svg className="loading-spinner__svg" viewBox="0 0 50 50">
              <circle
                className="loading-spinner__svg-path"
                cx="25"
                cy="25"
                r="20"
                fill="none"
                strokeWidth="5"
              />
            </svg>
          </div>
          <span className="inline-block ms-2 text-xs text-white font-semibold tracking-wide">
            {message |> str}
          </span>
        </div>
      </div>
    : React.null
}
