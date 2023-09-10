let str = React.string

let t = I18n.t(~scope="components.StudentTopNav__DropDown")

open StudentTopNav__Types

let handleToggle = (setLinksVisible, _) => setLinksVisible(linksVisible => !linksVisible)

let additionalLinks = (linksVisible, links) =>
  linksVisible
    ? <div
        className="dropdown__list dropdown__list-right bg-white shadow-lg rounded mt-3 border absolute max-w-min z-50">
        {links
        |> Js.Array.mapi((link, index) =>
          <div key={index |> string_of_int} className="">
            <a
              className="cursor-pointer block p-3 text-xs  font-medium text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
              href={link |> NavLink.url}
              target="_blank"
              rel="noopener">
              {link |> NavLink.title |> str}
            </a>
          </div>
        )
        |> React.array}
      </div>
    : React.null

@react.component
let make = (~links) => {
  let (linksVisible, setLinksVisible) = React.useState(() => false)
  switch links {
  | [] => React.null
  | moreLinks =>
    <button
      title={t("show_links")}
      className="whitespace-nowrap ms-2 font-medium text-sm p-4 md:px-3 md:py-2 cursor-pointer relative rounded-lg text-gray-900 hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500"
      onClick={handleToggle(setLinksVisible)}
      key="more-links">
      <span> {t("more") |> str} </span>
      <i className="fas fa-caret-down ms-2" />
      {additionalLinks(linksVisible, moreLinks)}
    </button>
  }
}
