type link = {
  name: string,
  url: string,
}

let str = React.string

let contents = links => {
  links->Js.Array2.mapi((link, index) =>
    <div key={index->string_of_int} className="">
      <a
        className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
        href={link.url}
        rel="noopener">
        {link.name->str}
      </a>
    </div>
  )
}

let showSelected = (placeholder, selected) => {
  <button
    className="mt-1 flex gap-2 items-center justify-between appearance-none w-full bg-white border border-gray-300 rounded py-2.5 px-3 text-sm focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
    key="selected">
    <span>
      {switch selected {
      | Some(s) => s.name
      | None => placeholder
      }->React.string}
    </span>
    <Icon className="if i-chevron-down-regular if-fw" />
  </button>
}

@react.component
let make = (~links, ~selectedLink=?, ~placeholder="Select") => {
  switch links {
  | [] => React.null
  | moreLinks =>
    <Dropdown2
      className="w-full md:text-base"
      selected={showSelected(placeholder, selectedLink)}
      contents={contents(moreLinks)}
      right=true
      key="links-dropdown"
    />
  }
}

let decodeLink = json => {
  open Json.Decode

  {
    name: field("name", string, json),
    url: field("url", string, json),
  }
}

let makeFromJson = json => {
  open Json.Decode

  make({
    "selectedLink": optional(field("selectedLink", decodeLink), json),
    "placeholder": optional(field("placeholder", string), json),
    "links": field("links", array(decodeLink), json),
  })
}
