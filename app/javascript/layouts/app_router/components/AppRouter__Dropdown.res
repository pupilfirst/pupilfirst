let str = React.string

let t = I18n.t(~scope="components.AppRouter__Dropdown")

open AppRouter__Types

let handleToggle = (setLinksVisible, _) => setLinksVisible(linksVisible => !linksVisible)

let contents = moreLinks => {
  moreLinks->Js.Array2.mapi((link, index) =>
    <div key={index->string_of_int} className="">
      <a
        className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
        href={link->School.linkUrl}
        target="_blank"
        rel="noopener">
        {School.linkTitle(link)->str}
      </a>
    </div>
  )
}

let selected = () => {
  <div
    title={t("show_more_links")}
    className="ml-2 font-semibold text-sm p-4 md:px-3 md:py-2 cursor-pointer relative rounded-lg text-gray-900 hover:bg-gray-50 hover:text-primary-500"
    key="more-links">
    <span> {t("more")->str} </span> <i className="fas fa-caret-down ml-2" />
  </div>
}

@react.component
let make = (~links) => {
  switch links {
  | [] => React.null
  | moreLinks =>
    <Dropdown2
      selected={selected()} contents={contents(moreLinks)} right=true key="links-dropdown"
    />
  }
}
