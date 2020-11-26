let str = React.string

@react.component
let make = (~message, ~active, ~warn=false) =>
  if active {
    let colors = warn ? "text-orange-600 bg-orange-100" : "text-red-600 bg-red-100"

    <div
      className={"mt-1 px-1 py-px rounded text-xs font-semibold inline-flex items-center " ++
      colors}>
      <span className="mr-2"> <i className="fas fa-exclamation-triangle" /> </span>
      <span> {message |> str} </span>
    </div>
  } else {
    ReasonReact.null
  }
