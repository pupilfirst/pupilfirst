let str = React.string

let t = I18n.t(~scope="components.AppRouter__Dropdown")

open AppRouter__Types

let handleToggle = (setLinksVisible, _) => setLinksVisible(linksVisible => !linksVisible)

@react.component
let make = (~links) => {
  let (linksVisible, setLinksVisible) = React.useState(() => false)
  switch links {
  | [] => React.null
  | moreLinks =>
    <div
      title={t("show_more_links")}
      className="ml-2 font-semibold text-sm p-4 md:px-3 md:py-2 cursor-pointer relative rounded-lg text-gray-900 hover:bg-gray-200 hover:text-primary-500"
      onClick={handleToggle(setLinksVisible)}
      key="more-links">
      <span> {t("more")->str} </span>
      <i className="fas fa-caret-down ml-2" />
      {ReactUtils.nullUnless(
        <div
          className="dropdown__list dropdown__list-right bg-white shadow-lg rounded mt-3 border absolute w-40 z-50">
          {moreLinks
          ->Js.Array2.mapi((link, index) =>
            <div key={index->string_of_int} className="">
              <a
                className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200"
                href={link->School.linkUrl}
                target="_blank"
                rel="noopener">
                {School.linkTitle(link)->str}
              </a>
            </div>
          )
          ->React.array}
        </div>,
        linksVisible,
      )}
    </div>
  }
}
