let str = React.string

let t = I18n.t(~scope="components.CourseResourcesFilter")

type resource = [#Cohort | #StudentTag | #UserTag | #Coach]

type filterType =
  | DataLoad(resource)
  | Search
  | Custom(string)
  | CustomArray(array<string>)

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
  resource: resource,
  values: array<string>,
}

type state = {
  filterInput: string,
  filterLoading: bool,
  filterData: array<filterItem>,
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | SetLoading
  | SetFilterData(array<filterItem>)

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput}
  | SetLoading => {...state, filterLoading: true}
  | SetFilterData(filterData) => {...state, filterData, filterLoading: false}
  }

module CourseResourceInfoInfoQuery = %graphql(`
    query CourseResourceInfoInfoQuery($courseId: ID!, $resources: [CourseResource!]!) {
      courseResourceInfo(courseId: $courseId, resources: $resources) {
        resource
        values
      }
    }
  `)

let getCourseResources = (send, courseId, filters: array<filter>) => {
  let resources =
    filters
    ->Js.Array2.map(config =>
      switch config.filterType {
      | DataLoad(resource) => [resource]
      | _ => []
      }
    )
    ->ArrayUtils.flattenV2

  if Js.Array2.length(resources) > 0 {
    send(SetLoading)
    CourseResourceInfoInfoQuery.make(
      CourseResourceInfoInfoQuery.makeVariables(~courseId, ~resources, ()),
    )
    |> Js.Promise.then_(response => {
      send(
        SetFilterData(
          response["courseResourceInfo"]->Js.Array2.map(obj => {
            resource: obj["resource"],
            values: obj["values"],
          }),
        ),
      )

      Js.Promise.resolve()
    })
    |> ignore
  }
}

let formatStringWithID = string => {
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
    displayValue: value->formatStringWithID,
    label,
    color,
  }
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let findResource = (resource, filterData, filter) => {
  filterData
  ->Js.Array2.find(filterItem => filterItem.resource == resource)
  ->Belt.Option.mapWithDefault([], filterItem =>
    filterItem.values->Js.Array2.map(value =>
      Selectable.make(filter.key, value, Some(filter.label), filter.color)
    )
  )
}
let unselected = (state, filters: array<filter>) => {
  filters
  ->Js.Array2.map(config => {
    switch config.filterType {
    | DataLoad(r) => findResource(r, state.filterData, config)
    | Search =>
      state.filterInput == ""
        ? []
        : [Selectable.make(config.key, state.filterInput, Some(config.label), config.color)]
    | Custom(value) => [Selectable.make(config.key, value, Some(config.label), config.color)]
    | CustomArray(values) =>
      values->Js.Array2.map(value =>
        Selectable.make(config.key, value, Some(config.label), config.color)
      )
    }
  })
  ->ArrayUtils.flattenV2
}

let computeInitialState = () => {
  filterInput: "",
  filterLoading: false,
  filterData: [],
}

let selectedFromQueryParams = (params, filters) => {
  filters
  ->Js.Array2.map(config => {
    let value = Webapi.Url.URLSearchParams.get(params, config.key)
    switch value {
    | Some(v) => [Selectable.make(config.key, v, Some(config.label), config.color)]
    | None => []
    }
  })
  ->ArrayUtils.flattenV2
}

let setParams = (key, value, params) => {
  Webapi.Url.URLSearchParams.set(params, key, value)
  RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(params))
}

let onSelect = (params, send, selectable) => {
  setParams(Selectable.key(selectable), Selectable.orginalValue(selectable), params)
  send(UnsetSearchString)
}

let onDeselect = (params, selectable) => {
  Webapi.Url.URLSearchParams.delete(params, Selectable.key(selectable))
  RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(params))
}

let selected = (sorter: sorter, params) => {
  let value =
    Webapi.Url.URLSearchParams.get(params, sorter.key)->Belt.Option.getWithDefault(sorter.default)
  <button
    title={"Order by" ++ " " ++ value}
    className="p-3 w-full sm:w-36 flex items-center justify-center text-sm font-medium ltr:space-x-2  truncate cursor-pointer bg-white border border-gray-300 text-gray-900 rounded-md hover:bg-primary-100 hover:text-primary-400 hover:border-primary-400 focus:outline-none focus:bg-primary-100 focus:text-primary-400 focus:border-primary-400">
    <Icon className="if i-sort-alpha-ascending-regular" />
    <span className="ms-2"> {value->str} </span>
  </button>
}

let contents = (sorter, params) => {
  sorter.options->Js.Array2.map(sort =>
    <button
      key=sort
      title={"Order by" ++ " " ++ sort}
      className="w-full cursor-pointer  block p-3 text-xs font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
      onClick={_e => setParams(sorter.key, sort, params)}>
      {sort->str}
    </button>
  )
}

@react.component
let make = (
  ~id="course-resource-filter",
  ~courseId,
  ~filters: array<filter>,
  ~search,
  ~placeholder=t("filter_resources"),
  ~sorter=?,
  ~hint="...or start typing to filter by cohorts using their name",
) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  let params = Webapi.Url.URLSearchParams.make(search)

  React.useEffect1(() => {
    getCourseResources(send, courseId, filters)
    None
  }, [courseId])

  <div className="flex flex-col sm:flex-row gap-3">
    <div className="flex-1">
      <p className="text-xs uppercase font-medium pb-2"> {I18n.t("shared.filter")->str} </p>
      <Multiselect
        id
        unselected={unselected(state, filters)}
        selected={selectedFromQueryParams(params, filters)}
        onSelect={onSelect(params, send)}
        onDeselect={onDeselect(params)}
        value=state.filterInput
        onChange={filterInput => send(UpdateFilterInput(filterInput))}
        placeholder
        loading={state.filterLoading}
        defaultOptions={unselected(state, filters)}
        hint
      />
    </div>
    {switch sorter {
    | Some(sorter) =>
      <div>
        <p className="text-xs uppercase font-medium pb-2"> {I18n.t("shared.sort_by")->str} </p>
        <Dropdown2
          selected={selected(sorter, params)} contents={contents(sorter, params)} right=true
        />
      </div>
    | None => React.null
    }}
  </div>
}
