let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__MoreLinks", ...)

type state = bool

let toggleState = (send, event) => {
  ReactEvent.Mouse.preventDefault(event)
  send()
}

let additionalLinks = (linksVisible, links) =>
  if linksVisible {
    <div className="border-2 border-gray-50 rounded-lg absolute w-48 bg-white mt-2">
      {links
      ->Js.Array2.map(((id, title, _, _)) =>
        <div key=id className="p-2 cursor-default">
          <span> {str(title)} </span>
        </div>
      )
      ->React.array}
    </div>
  } else {
    React.null
  }

let initialState = () => false
let reducer = (linksVisible, _action) => !linksVisible

@react.component
let make = (~links) => {
  let (state, send) = React.useReducer(reducer, initialState())
  switch links {
  | [] => React.null
  | moreLinks =>
    <button
      title={t("show_more_links")}
      className="ms-6 font-semibold text-sm cursor-pointer relative z-40"
      onClick={toggleState(send)}
      key="more-links">
      <span> {str(t("more"))} </span>
      <i className="fas fa-angle-down ms-1" />
      {additionalLinks(state, moreLinks)}
    </button>
  }
}
