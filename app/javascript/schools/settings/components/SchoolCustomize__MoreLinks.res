let str = React.string

let t = I18n.t(~scope="components.SchoolCustomize__MoreLinks")

type state = bool

let toggleState = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send()
}

let additionalLinks = (linksVisible, links) =>
  if linksVisible {
    <div className="border-2 border-gray-50 rounded-lg absolute w-48 bg-white mt-2">
      {links
      |> List.map(((id, title, _)) =>
        <div key=id className="p-2 cursor-default"> <span> {title |> str} </span> </div>
      )
      |> Array.of_list
      |> React.array}
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
  | list{} => React.null
  | moreLinks =>
    <button
      title={t("show_more_links")}
      className="ml-6 font-semibold text-sm cursor-pointer relative z-40"
      onClick={toggleState(send)}
      key="more-links">
      <span> {t("more") |> str} </span>
      <i className="fas fa-angle-down ml-1" />
      {additionalLinks(state, moreLinks)}
    </button>
  }
}
