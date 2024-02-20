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

    let removeEventListener = () => Window.removeEventListener(window, "click", curriedFunction)

    if showDropdown {
      Window.addEventListener(window, "click", curriedFunction)
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
          className={"dropdown__list-2 max-h-[16rem] min-w-full bg-white shadow-lg rounded mt-1 border border-gray-300 divide-y divide-gray-200 absolute overflow-x-hidden z-30
 " ++
          width ++
          ((right ? " end-0 " : " start-0 ") ++
          childClasses)}>
          {Js.Array.mapi(
            (content, index) =>
              <div
                key={"dropdown-" ++ index->string_of_int}
                className="cursor-pointer block text-sm font-semibold bg-white hover:text-primary-500 hover:bg-gray-50">
                content
              </div>,
            contents,
          )->React.array}
        </div>
      : React.null}
  </div>
}
