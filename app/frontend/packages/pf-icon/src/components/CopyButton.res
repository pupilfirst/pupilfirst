@val @scope(("window", "navigator", "clipboard"))
external writeText: string => unit = "writeText"

let str = React.string

@react.component
let make = (~textToCopy, ~label) => {
  let (copied, setCopied) = React.useState(() => false)

  let _ = React.useEffect(() => {
    let timer = Js.Global.setTimeout(() => setCopied(_ => false), 1000)
    Some(() => Js.Global.clearTimeout(timer))
  })

  let handleClick = _ => {
    writeText(textToCopy)
    setCopied(_ => true)
  }

  switch copied {
  | true =>
    <span className=" text-sm text-green-600 text-left font-semibold"> {str("Copied!")} </span>
  | false =>
    <button
      onClick={handleClick}
      className="text-sm text-left text-gray-700 hover:text-blue-500 focus:outline-none">
      {str(label)}
    </button>
  }
}
