let str = React.string

type state = ReadyToCopy | Copied

let performCopy = (_copy, setState, _event) => {
  // Do more things.
  %raw(`navigator.clipboard.writeText(_copy)`)->ignore
  setState(_ => Copied)
}

let refresh = (setState, _event) => setState(_ => ReadyToCopy)

@react.component
let make = (~copy, ~tooltipPosition=#Top, ~className="", ~tooltipClassName=?, ~children) => {
  let (state, setState) = React.useState(() => ReadyToCopy)

  let tip = switch state {
  | ReadyToCopy => "Copy to clipboard"
  | Copied => "Copied!"
  }->str

  <div
    className={"cursor-pointer " ++ className}
    onClick={performCopy(copy, setState)}
    onMouseLeave={refresh(setState)}>
    <Tooltip className=?tooltipClassName position=tooltipPosition tip> {children} </Tooltip>
  </div>
}
