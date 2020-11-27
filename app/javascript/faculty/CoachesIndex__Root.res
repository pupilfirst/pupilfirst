%bs.raw(`require("./CoachesIndex__Root.css")`)

let str = React.string

open CoachesIndex__Types

let tr = I18n.t(~scope="components.CoachesIndex__Root")

module Selectable = {
  type t =
    | Course(Course.t)
    | Search(string)

  let label = t => {
    let l = switch t {
    | Course(_) => tr("filter_label_teaches_course")
    | Search(_) => tr("filter_label_name_like")
    }

    Some(l)
  }

  let value = t =>
    switch t {
    | Course(course) => Course.name(course)
    | Search(input) => input
    }

  let searchString = t =>
    switch t {
    | Course(course) =>
      tr(~variables=[("name", Course.name(course))], "filter_search_string_course")
    | Search(input) => input
    }

  let color = _t => "gray"

  let makeCourse = course => Course(course)
  let makeSearch = input => Search(input)
}

module Multiselect = MultiselectDropdown.Make(Selectable)

type state = {
  filterInput: string,
  filterSearch: string,
  filterCourseIds: Belt.Set.String.t,
}

let computeInitialState = (courses, studentInCourseIds) => {
  let filterCourseIds =
    Js.Array.filter(
      course => studentInCourseIds |> Js.Array.includes(Course.id(course)),
      courses,
    ) |> Js.Array.map(Course.id)

  {
    filterInput: "",
    filterSearch: "",
    filterCourseIds: Belt.Set.String.fromArray(filterCourseIds),
  }
}

type action =
  | SelectFilter(Selectable.t)
  | DeselectFilter(Selectable.t)
  | UpdateFilterInput(string)

let reducer = (state, action) =>
  switch action {
  | SelectFilter(selectable) =>
    switch selectable {
    | Selectable.Search(input) => {
        ...state,
        filterInput: "",
        filterSearch: Js.String.trim(input),
      }
    | Course(course) => {
        ...state,
        filterInput: "",
        filterCourseIds: Belt.Set.String.add(state.filterCourseIds, Course.id(course)),
      }
    }
  | DeselectFilter(selectable) =>
    switch selectable {
    | Selectable.Search(_) => {...state, filterSearch: ""}
    | Course(course) => {
        ...state,
        filterCourseIds: Belt.Set.String.remove(state.filterCourseIds, Course.id(course)),
      }
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  }

let unselected = (input, filterCourseIds, courses) => {
  let unselectedCourses =
    Js.Array.filter(
      course => !(filterCourseIds->Belt.Set.String.has(Course.id(course))),
      courses,
    ) |> Js.Array.map(Selectable.makeCourse)

  let trimmedInput = Js.String.trim(input)
  let search = Js.String.length(trimmedInput) > 0 ? [Selectable.makeSearch(trimmedInput)] : []

  Js.Array.concat(search, unselectedCourses)
}

let connectLink = href =>
  <a
    href
    target="_blank"
    className="block flex-1 px-3 py-2 text-center text-sm font-semibold hover:bg-gray-200 hover:text-primary-500">
    {tr("button_connect")->str}
  </a>

let overlay = (coach, about) =>
  <div className="fixed z-30 inset-0 overflow-y-auto">
    <div
      className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div className="fixed inset-0">
        <div className="absolute inset-0 bg-gray-900 opacity-75" />
      </div>
      // This element centers the modal contents.
      <span className="hidden sm:inline-block sm:align-middle sm:h-screen" />
      <div
        className="inline-block relative bg-white rounded-lg shadow-lg align-bottom mt-16 sm:mb-8  sm:align-middle sm:max-w-lg sm:w-full"
        role="dialog"
        ariaModal=true
        ariaLabelledby="modal-headline">
        <div className="block absolute top-0 left-0 -mt-12">
          <Link
            href="/coaches"
            className="flex justify-center items-center bg-gray-900 rounded-full p-2 w-10 h-10 text-gray-400 hover:opacity-75 hover:text-gray-500 focus:outline-none focus:text-gray-500 transition ease-in-out duration-150"
            ariaLabel="Close">
            <PfIcon className="if i-times-regular if-fw text-2xl" />
          </Link>
        </div>
        <div className="pb-5">
          <div className="faculty-card__avatar-container bg-gray-200 px-2 py-10 rounded-t-lg">
            {switch Coach.avatarUrl(coach) {
            | Some(src) =>
              <img
                src
                className="mx-auto w-40 h-40 -mb-18 border-4 border-gray-400 rounded-full object-cover"
                alt={"Avatar of " ++ Coach.name(coach)}
              />
            | None =>
              <Avatar
                name={Coach.name(coach)}
                className="mx-auto w-40 h-40 -mb-18 border-4 border-gray-400 rounded-full object-cover"
              />
            }}
          </div>
          <div className="py-3 mt-8">
            <p className="text-sm text-center font-semibold"> {Coach.name(coach)->str} </p>
            <p className="text-center text-xs text-gray-800 pt-1">
              {Coach.fullTitle(coach)->str}
            </p>
          </div>
          <p className="text-center text-sm px-6"> {str(about)} </p>
          {switch Coach.connectLink(coach) {
          | Some(href) =>
            <div className="mt-3 text-center px-4 pb-4 sm:px-6 sm:pb-6">
              <div
                className="inline-flex overflow-hidden border rounded border-primary-500 text-primary-500">
                {connectLink(href)}
              </div>
            </div>
          | None => React.null
          }}
        </div>
      </div>
    </div>
  </div>

let card = coach =>
  <div
    ariaLabel={"Coach " ++ Coach.name(coach)}
    key={Coach.id(coach)}
    className="flex flex-col justify-between bg-white rounded-lg shadow-md pt-8">
    <div className="px-6">
      {switch Coach.avatarUrl(coach) {
      | Some(src) =>
        <img
          src
          className="mx-auto w-40 h-40 border-4 border-gray-200 rounded-full object-cover"
          alt="Coach's Avatar"
        />
      | None =>
        <Avatar
          name={Coach.name(coach)}
          className="mx-auto w-40 h-40 border-4 border-gray-200 rounded-full object-cover"
        />
      }}
      <div className="py-3">
        <p className="text-sm text-center font-semibold"> {Coach.name(coach)->str} </p>
        <p className="text-center text-xs text-gray-800 pt-1"> {Coach.fullTitle(coach)->str} </p>
      </div>
    </div>
    <div
      className="flex justify-between divide-x border-t divide-gray-400 border-gray-400 rounded-b-lg overflow-hidden">
      {switch Coach.about(coach) {
      | Some(_about) =>
        <div className="block flex-1">
          <Link
            href={"/coaches/" ++
            (Coach.id(coach) ++
            ("/" ++ Coach.name(coach)->StringUtils.parameterize))}
            className="block w-full px-3 py-2 text-center text-sm font-semibold hover:bg-gray-200 hover:text-primary-500">
            {tr("button_about")->str}
          </Link>
        </div>
      | None => React.null
      }}
      {switch Coach.connectLink(coach) {
      | Some(href) => <div className="flex-1"> {connectLink(href)} </div>
      | None => React.null
      }}
    </div>
  </div>

let applyFilter = (coaches, filterSearch, filterCourseIds) => {
  let coaches = Belt.Set.String.isEmpty(filterCourseIds)
    ? coaches
    : Js.Array.filter(
        coach =>
          !(
            Coach.courseIds(coach)
            ->Belt.Set.String.fromArray
            ->Belt.Set.String.intersect(filterCourseIds)
            ->Belt.Set.String.isEmpty
          ),
        coaches,
      )

  filterSearch == ""
    ? coaches
    : Js.Array.filter(coach => Coach.name(coach) |> StringUtils.includes(filterSearch), coaches)
}

let selected = (courses, filterSearch, filterCourseIds) => {
  let search = filterSearch == "" ? [] : [Selectable.makeSearch(filterSearch)]

  let selectedCourses =
    Js.Array.filter(
      course => filterCourseIds->Belt.Set.String.has(Course.id(course)),
      courses,
    ) |> Js.Array.map(Selectable.makeCourse)

  Js.Array.concat(selectedCourses, search)
}

@react.component
let make = (~subheading, ~coaches, ~courses, ~studentInCourseIds) => {
  let (state, send) = React.useReducerWithMapState(
    reducer,
    studentInCourseIds,
    computeInitialState(courses),
  )

  let url = ReasonReactRouter.useUrl()

  let selectedCoachOverlay = switch url.path {
  | list{"coaches", coachIdParam, ..._} =>
    coachIdParam
    ->StringUtils.paramToId
    ->Belt.Option.flatMap(coachId => coaches |> Js.Array.find(coach => Coach.id(coach) == coachId))
    ->Belt.Option.mapWithDefault(React.null, coach =>
      switch Coach.about(coach) {
      | Some(about) => overlay(coach, about)
      | None => React.null
      }
    )
  | _otherPaths => React.null
  }

  let filteredCoaches = applyFilter(coaches, state.filterSearch, state.filterCourseIds)

  let coachesToShow = ArrayUtils.isEmpty(filteredCoaches) ? coaches : filteredCoaches

  <div>
    selectedCoachOverlay
    <div className="max-w-5xl mx-auto px-4">
      <h1 className="text-4xl text-center mt-3"> {tr("heading")->str} </h1>
      {switch subheading {
      | Some(subheading) => <p className="text-center"> {str(subheading)} </p>
      | None => React.null
      }}
      <label htmlFor="filter" className="block text-xs font-semibold uppercase mt-4">
        {tr("filter_input_label")->str}
      </label>
      <Multiselect
        id="filter"
        unselected={unselected(state.filterInput, state.filterCourseIds, courses)}
        selected={selected(courses, state.filterSearch, state.filterCourseIds)}
        onSelect={selectable => send(SelectFilter(selectable))}
        onDeselect={selectable => send(DeselectFilter(selectable))}
        value=state.filterInput
        onChange={filterInput => send(UpdateFilterInput(filterInput))}
        placeholder={tr("filter_input_placeholder")}
      />
      {ArrayUtils.isEmpty(filteredCoaches)
        ? <div className="text-xs border rounded bg-blue-100 p-2 mt-2">
            {tr("filter_result_empty")->str}
          </div>
        : React.null}
      <div className="grid sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5 pt-6 pb-8">
        {coachesToShow |> Js.Array.map(card) |> React.array}
      </div>
    </div>
  </div>
}
