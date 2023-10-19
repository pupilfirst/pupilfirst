let str = React.string

type filterType =
  | Search
  | SingleSelect(string)
  | MultiSelect(array<string>)

type sorter = {
  key: string,
  options: array<string>,
  default: string,
}

type filter = {
  key: string,
  label: string,
  filterType: filterType,
  color: string,
}

let makeFilter = (key, label, filterType: filterType, color) => {
  {key, label, filterType, color}
}

let makeSorter = (key, options, default) => {
  {key, options, default}
}

type filterItem = {
  itemType: string,
  values: array<string>,
}

type state = {filterInput: string}

type action =
  | ClearFilterString
  | UpdateFilterInput(string)

let reducer = (_state, action) =>
  switch action {
  | ClearFilterString => {
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {filterInput: filterInput}
  }

let removeIdFromString = string => {
  string->Js.String2.replaceByRe(%re("/^\d+;/"), "")
}

module Selectable = {
  type t = {
    key: string,
    orginalValue: string,
    displayValue: string,
    label: option<string>,
    color: string,
  }

  let value = t => t.displayValue
  let label = t => t.label
  let key = t => t.key
  let color = t => t.color
  let orginalValue = t => t.orginalValue

  let searchString = t => Belt.Option.getWithDefault(t.label, t.key) ++ " " ++ t.displayValue

  let make = (key, value, label, color) => {
    key,
    orginalValue: value,
    displayValue: value->removeIdFromString,
    label,
    color,
  }
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unselected = (state, filters: array<filter>) => {
  filters
  ->Js.Array2.map(filter => {
    switch filter.filterType {
    | Search =>
      state.filterInput == ""
        ? []
        : [Selectable.make(filter.key, state.filterInput, Some(filter.label), filter.color)]
    | SingleSelect(value) => [Selectable.make(filter.key, value, Some(filter.label), filter.color)]
    | MultiSelect(values) =>
      values->Js.Array2.map(value =>
        Selectable.make(filter.key, value, Some(filter.label), filter.color)
      )
    }
  })
  ->ArrayUtils.flattenV2
}

let computeInitialState = () => {
  filterInput: "",
}

let selectedFromQueryParams = (params, filters) => {
  filters
  ->Js.Array2.map(filter => {
    let value = Webapi.Url.URLSearchParams.get(params, filter.key)

    switch value {
    | Some(v) => [Selectable.make(filter.key, v, Some(filter.label), filter.color)]
    | None => []
    }
  })
  ->ArrayUtils.flattenV2
}

let setParams = (key, value, params) => {
  Webapi.Url.URLSearchParams.set(params, key, value)
}

let navigateTo = params => {
  let currentPath = Webapi.Dom.location->Webapi.Dom.Location.pathname
  let searchString = Webapi.Url.URLSearchParams.toString(params)
  Webapi.Dom.window->Webapi.Dom.Window.setLocation(`${currentPath}?${searchString}`)
}

let onSelect = (params, send, selectable) => {
  setParams(Selectable.key(selectable), Selectable.orginalValue(selectable), params)
  send(ClearFilterString)
  navigateTo(params)
}

let onDeselect = (params, selectable) => {
  Webapi.Url.URLSearchParams.delete(params, Selectable.key(selectable))
  navigateTo(params)
}

let selectedSorter = (sorter: sorter, params) => {
  let value = switch Webapi.Url.URLSearchParams.get(params, sorter.key) {
  | Some(userSuppliedValue) =>
    sorter.options->Js.Array2.includes(userSuppliedValue) ? userSuppliedValue : sorter.default
  | None => sorter.default
  }

  <button
    title={"Order by" ++ " " ++ value}
    className="p-3 w-36 text-sm font-medium ltr:space-x-2  truncate cursor-pointer bg-white border border-gray-300 text-gray-900 rounded-md hover:bg-primary-100 hover:text-primary-400 hover:border-primary-400 focus:outline-none focus:bg-primary-100 focus:text-primary-400 focus:border-primary-400">
    <Icon className="if i-sort-alpha-ascending-regular" />
    <span className="me-2"> {value->str} </span>
  </button>
}

let sortOptions = (sorter, params) => {
  sorter.options->Js.Array2.map(sort =>
    <button
      key=sort
      title={"Order by" ++ " " ++ sort}
      className="w-full cursor-pointer  block p-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
      onClick={_e => {
        setParams(sorter.key, sort, params)
        navigateTo(params)
      }}>
      {sort->str}
    </button>
  )
}

@react.component
let make = (
  ~id,
  ~filters: array<filter>,
  ~placeholder="Search or filter...",
  ~sorter=?,
  ~hint="...or start typing to search.",
) => {
  let search = Webapi.Dom.location->Webapi.Dom.Location.search
  let (state, send) = React.useReducer(reducer, computeInitialState())
  let params = Webapi.Url.URLSearchParams.make(search)

  <div className="bg-gray-50 p-4 w-full flex flex-wrap gap-3 rounded-lg">
    <div className="flex-1">
      <label htmlFor=id className="text-xs uppercase font-medium pb-2">
        {I18n.t("shared.filter")->str}
      </label>
      <Multiselect
        id
        unselected={unselected(state, filters)}
        selected={selectedFromQueryParams(params, filters)}
        onSelect={onSelect(params, send)}
        onDeselect={onDeselect(params)}
        value=state.filterInput
        onChange={filterInput => send(UpdateFilterInput(filterInput))}
        placeholder
        defaultOptions={unselected(state, filters)}
        hint
      />
    </div>
    {switch sorter {
    | Some(sorter) =>
      <div>
        <p className="text-xs uppercase font-medium pb-2"> {I18n.t("shared.sort_by")->str} </p>
        <Dropdown2
          selected={selectedSorter(sorter, params)}
          contents={sortOptions(sorter, params)}
          right=true
        />
      </div>
    | None => React.null
    }}
  </div>
}

let decodeFilter = json => {
  open Json.Decode

  {
    key: field("key", string, json),
    label: field("label", string, json),
    filterType: switch field("filterType", string, json) {
    | "Search" => Search
    | "SingleSelect" => SingleSelect(field("value", string, json))
    | "MultiSelect" => MultiSelect(field("values", array(string), json))
    | unknownFilterType => failwith("Unknown filter type: " ++ unknownFilterType)
    },
    color: field("color", string, json),
  }
}

let decodeSorter = json => {
  open Json.Decode

  {
    key: field("key", string, json),
    default: field("default", string, json),
    options: field("options", array(string), json),
  }
}

let makeFromJson = json => {
  open Json.Decode

  make({
    "id": field("id", string, json),
    "filters": field("filters", array(decodeFilter), json),
    "placeholder": optional(field("placeholder", string), json),
    "sorter": optional(field("sorter", decodeSorter), json),
    "hint": optional(field("hint", string), json),
  })
}
