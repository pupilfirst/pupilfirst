open Webapi.Dom

let onWindowClick = (showDropdown, setShowDropdown, _event) =>
  if showDropdown {
    setShowDropdown(_ => false)
  } else {
    ()
  }

let toggleDropdown = (setShowDropdown, event) => {
  ReactEvent.Mouse.stopPropagation(event)
  setShowDropdown(showDropdown => !showDropdown)
}

let containerClasses = className => {
  "dropdown inline-block relative text-sm " ++ className
}

@react.component
let make = (~selected, ~contents, ~right=false, ~className="w-full md:w-auto") => {
  let (showDropdown, setShowDropdown) = React.useState(() => false)

  React.useEffect1(() => {
    let onClick = event => onWindowClick(showDropdown, setShowDropdown, event)

    let removeEventListener = () => Window.removeEventListener(window, "click", onClick)

    if showDropdown {
      Window.addEventListener(window, "click", onClick)
      Some(removeEventListener)
    } else {
      removeEventListener()
      None
    }
  }, [showDropdown])

  <div
    className={containerClasses(className)}
    onClick={event => toggleDropdown(setShowDropdown, event)}>
    selected
    {showDropdown
      ? <div
          className={"dropdown__list bg-white shadow-lg rounded mt-1 border border-gray-300 divide-y divide-gray-50 absolute overflow-x-hidden z-30 " ++ (
            right ? "end-0" : "start-0"
          )}>
          {contents
          ->Array.mapWithIndex((content, index) =>
            <div
              key={"dropdown-" ++ string_of_int(index)}
              className="cursor-pointer block text-sm font-medium text-gray-900 bg-white hover:text-primary-500 hover:bg-gray-50 focus-within:outline-none focus-within:bg-gray-50 focus-within:text-primary-500">
              content
            </div>
          )
          ->React.array}
        </div>
      : React.null}
  </div>
}
