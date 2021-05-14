open Webapi.Dom

let str = React.string

let t = I18n.t(~scope="components.StudentTopNav__CommunityActions")

let showLink = (icon, title, description, href) =>
  <a key=href className="" href=href rel="nofollow">
    <div className="p-4 border-t border-gray-300 first:no-border bg-white hover:bg-gray-200">
      <span role="img" ariaLabel=icon className="emoji text-md"> {icon->str} </span>
      <b className="pl-3 text-gray-900"> {title->str} </b>
      <p className="mt-2 text-sm text-gray-700"> {description->str} </p>
    </div>
  </a>

let links = (communityHost) => {
  [
    showLink(`📄`, "Post", "Quickly share what's on your mind with everyone", communityHost ++ "/home/posts"),
    showLink(`❓`, "Question", "Perfect when you want definitive answers on a topic", communityHost ++ "/home/questions"),
    showLink(`💬`, "Discussion", "Great for ongoing dialogue with others in the community", communityHost ++ "/home/discussions"),
  ]
}

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

@react.component
let make = (~communityHost) => {
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

  <div className="my-0 mx-2 cursor-pointer inline-block relative align-left">
    <button className="p-3 bg-preciseBlue text-gray-100 leading-3 rounded" onClick={toggleDropdown(setShowDropdown)}>
      <FaIcon classes="fas fa-plus text-base" />
    </button>
    {showDropdown
      ? <div className="w-64 bg-white shadow-lg rounded mt-1 border border-gray-400 absolute overflow-x-hidden z-30 right-0">
          {links(communityHost) |> React.array}
        </div>
      : React.null}
  </div>
}
