let str = React.string

type resource = [#Level | #Cohort | #StudentTag | #UserTag]

type filterType =
  | DataLoad(resource)
  | Search
  | Custom(string)
  | Sort(array<string>)

type filter = {
  key: string,
  label: string,
  filterType: filterType,
  color: string,
}

let makeFilter = (key, label, filterType: filterType, color) => {
  {key, label, filterType, color}
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
    | Sort(value) =>
      value->Js.Array2.map(v => Selectable.make(config.key, v, Some(config.label), config.color))
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
    let value = Webapi.Url.URLSearchParams.get(config.key, params)
    switch value {
    | Some(v) => [Selectable.make(config.key, v, Some(config.label), config.color)]
    | None => []
    }
  })
  ->ArrayUtils.flattenV2
}

let onSelect = (params, send, selectable) => {
  Webapi.Url.URLSearchParams.set(
    Selectable.key(selectable),
    Selectable.orginalValue(selectable),
    params,
  )
  RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(params))
  send(UnsetSearchString)
}

let onDeselect = (params, selectable) => {
  Webapi.Url.URLSearchParams.delete(Selectable.key(selectable), params)
  RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(params))
}

@react.component
let make = (
  ~courseId,
  ~filters: array<filter>,
  ~search,
  ~placeholder="Filter Resources",
  ~hint="...or start typing to filter by student using their name or email address",
) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  let params = Webapi.Url.URLSearchParams.make(search)

  React.useEffect1(() => {
    getCourseResources(send, courseId, filters)
    None
  }, [courseId])

  <Multiselect
    id="filter"
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
}
