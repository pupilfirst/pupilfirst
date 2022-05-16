open Webapi.Dom

let onWindowClick = (showDropdown, setShowDropdown, _event) =>
  if showDropdown {
    setShowDropdown(_ => false)
  } else {
    ()
  }

let toggleDropdown = (setShowDropdown, event) => {
  event |> ReactEvent.Mouse.stopPropagation
  setShowDropdown(showDropdown => !showDropdown)
}

let containerClasses = className => {
  "dropdown inline-block relative text-sm " ++ className
}

@react.component
let make = (
  ~selected,
  ~contents,
  ~right=false,
  ~className="w-full md:w-auto",
  ~childClasses="",
  ~width="min-w-full md:w-auto",
) => {
  let (showDropdown, setShowDropdown) = React.useState(() => false)

  React.useEffect1(() => {
    let curriedFunction = onWindowClick(showDropdown, setShowDropdown)

    let removeEventListener = () => Window.removeEventListener("click", curriedFunction, window)

    if showDropdown {
      Window.addEventListener("click", curriedFunction, window)
      Some(removeEventListener)
    } else {
      removeEventListener()
      None
    }
  }, [showDropdown])

  <div className={containerClasses(className)} onClick={toggleDropdown(setShowDropdown)}>
    selected
    {showDropdown
      ? <div
          className={"dropdown__list-2 bg-white shadow-lg rounded mt-1 border border-gray-300 absolute overflow-x-hidden z-30
 " ++
          width ++
          ((right ? " right-0 " : " left-0 ") ++
          childClasses)}>
          {Js.Array.mapi((content, index) =>
            <div
              key={"dropdown-" ++ index->string_of_int}
              className="cursor-pointer block text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 md:whitespace-nowrap
">
              content
            </div>
          , contents)->React.array}
        </div>
      : React.null}
  </div>
}
