exception UnsafeFindFailed(string)

let t = I18n.t(~scope="components.CourseSelect")

let str = React.string

type status = [#Active | #Ended | #Archived]

type course = {
  id: string,
  name: string,
}

module CoursesInfoQuery = %graphql(`
  query CoursesQuery($search: String, $after: String, $status: CourseStatus) {
    courses(status: $status, search: $search, first: 10, after: $after){
      nodes {
        id
        name
      }
      pageInfo{
        endCursor,hasNextPage
      }
      totalCount
    }
  }
  `)

module Item = {
  type t = course
}

module Pagination = Pagination.Make(Item)

type filter = {
  status: option<status>,
  name: option<string>,
}

type editorAction =
  | Hidden
  | ShowForm(option<string>)

type state = {
  loading: Loading.t,
  courses: Pagination.t,
  filterString: string,
  filter: filter,
  totalEntriesCount: int,
  relaodCourses: bool,
}

type action =
  | SetSearchString(string)
  | UnsetSearchString
  | ReloadCourses
  | UpdateFilterString(string)
  | BeginLoadingMore
  | BeginReloading
  | SetFilterArchived
  | SetFilterActive
  | SetFilterEnded
  | ClearArchivedFilter
  | LoadCourses(option<string>, bool, array<course>, int)

let reducer = (state, action) =>
  switch action {
  | SetSearchString(string) => {
      ...state,
      filter: {
        ...state.filter,
        name: Some(string),
      },
      filterString: "",
    }
  | ReloadCourses => {
      ...state,
      loading: Reloading,
      relaodCourses: !state.relaodCourses,
    }
  | UnsetSearchString => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        name: None,
      },
    }
  | SetFilterArchived => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        status: Some(#Archived),
      },
    }
  | SetFilterEnded => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        status: Some(#Ended),
      },
    }
  | SetFilterActive => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        status: Some(#Active),
      },
    }
  | ClearArchivedFilter => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        status: None,
      },
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | UpdateFilterString(filterString) => {...state, filterString: filterString}
  | LoadCourses(endCursor, hasNextPage, newCourses, totalEntriesCount) =>
    let courses = switch state.loading {
    | LoadingMore => Js.Array.concat(newCourses, Pagination.toArray(state.courses))
    | Reloading => newCourses
    | NotLoading => newCourses
    }

    {
      ...state,
      courses: Pagination.make(courses, hasNextPage, endCursor),
      loading: NotLoading,
      totalEntriesCount: totalEntriesCount,
    }
  }

let loadCourses = (state, cursor, send) => {
  let variables = CoursesInfoQuery.makeVariables(
    ~status=?state.filter.status,
    ~after=?cursor,
    ~search=?state.filter.name,
    (),
  )
  CoursesInfoQuery.fetch(variables)
  |> Js.Promise.then_((response: CoursesInfoQuery.t) => {
    let courses = response.courses.nodes->Js.Array2.map(c => {id: c.id, name: c.name})
    send(
      LoadCourses(
        response.courses.pageInfo.endCursor,
        response.courses.pageInfo.hasNextPage,
        courses,
        response.courses.totalCount,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

module Selectable = {
  type t =
    | Status(status)
    | Name(string)

  let label = s =>
    switch s {
    | Status(_) => Some(t("filter.label.status"))
    | Name(_) => Some(t("filter.label.name"))
    }

  let value = s =>
    switch s {
    | Status(status) =>
      let key = switch status {
      | #Active => "active"
      | #Ended => "ended"
      | #Archived => "archived"
      }

      t("filter.status." ++ key)
    | Name(search) => search
    }

  let searchString = s => value(s)

  let color = t =>
    switch t {
    | Status(status) =>
      switch status {
      | #Active => "green"
      | #Ended => "orange"
      | #Archived => "gray"
      }
    | Name(_) => "blue"
    }

  let name = search => Name(search)
  let status = status => Status(status)
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unselected = state => {
  let trimmedFilterString = state.filterString->String.trim
  let name = trimmedFilterString == "" ? [] : [Selectable.name(trimmedFilterString)]
  let status = Js.Array.map(
    s => Selectable.status(s),
    Belt.Option.mapWithDefault(state.filter.status, [#Active, #Ended, #Archived], u =>
      switch u {
      | #Active => [#Ended, #Archived]
      | #Ended => [#Active, #Archived]
      | #Archived => [#Ended, #Active]
      }
    ),
  )

  Js.Array.concat(status, name)
}

let defaultOptions = () => Js.Array.map(s => Selectable.status(s), [#Active, #Ended, #Archived])

let selected = state => {
  let status = state.filter.status->Belt.Option.mapWithDefault([], u => [Selectable.status(u)])

  let selectedSearchString = OptionUtils.mapWithDefault(
    name => [Selectable.name(name)],
    [],
    state.filter.name,
  )

  Js.Array.concat(status, selectedSearchString)
}

let onSelectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.Status(s) =>
    switch s {
    | #Active => send(SetFilterActive)
    | #Ended => send(SetFilterEnded)
    | #Archived => send(SetFilterArchived)
    }
  | Name(n) => send(SetSearchString(n))
  }

let onDeselectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.Status(_) => send(ClearArchivedFilter)
  | Name(_title) => send(UnsetSearchString)
  }

let entriesLoadedData = (totoalNotificationsCount, loadedNotificaionsCount) =>
  <div className="pt-8 pb-4 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {(
      totoalNotificationsCount == loadedNotificaionsCount
        ? t(
            ~variables=[("total_courses", string_of_int(totoalNotificationsCount))],
            "courses_fully_loaded_text",
          )
        : t(
            ~variables=[
              ("total_courses", string_of_int(totoalNotificationsCount)),
              ("loaded_courses_count", string_of_int(loadedNotificaionsCount)),
            ],
            "courses_partially_loaded_text",
          )
    )->str}
  </div>

let showCourse = (course: course, selected, onChangeCB) => {
  let selectedClass = selected ? " bg-primary-100" : ""
  <Spread key={course.id} props={"data-course-id": course.name}>
    <div
      className={"w-full flex cursor-pointer hover:bg-gray-300" ++ selectedClass}
      onClick={_ => onChangeCB(course.id)}
      key={course.id}>
      <span className="p-1 pe-4  text-gray-900"> {str(course.name)} </span>
    </div>
  </Spread>
}

let showCourses = (courses, state, value, onChangeCB) => {
  <div className="w-full">
    {ArrayUtils.isEmpty(courses)
      ? <div className="flex flex-col mx-auto rounded-md border p-6 justify-center items-center">
          <FaIcon classes="fas fa-comments text-5xl text-gray-400" />
          <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
            {t("empty_courses")->str}
          </h4>
        </div>
      : <div className="flex flex-wrap">
          {Js.Array.map(
            course => showCourse(course, course.id == value, onChangeCB),
            courses,
          )->React.array}
        </div>}
    {entriesLoadedData(state.totalEntriesCount, Array.length(courses))}
  </div>
}

let reloadCoursesCB = (send, ()) => {
  send(ReloadCourses)
}

@react.component
let make = (~id, ~value, ~onChange) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      courses: Pagination.Unloaded,
      totalEntriesCount: 0,
      loading: NotLoading,
      filterString: "",
      filter: {
        name: None,
        status: Some(#Active),
      },
      relaodCourses: false,
    },
  )

  React.useEffect2(() => {
    loadCourses(state, None, send)
    None
  }, (state.filter, state.relaodCourses))

  <div className="flex flex-1 h-full">
    <div className="flex-1 flex flex-col">
      <Multiselect
        id={id}
        unselected={unselected(state)}
        selected={selected(state)}
        onSelect={onSelectFilter(send)}
        onDeselect={onDeselectFilter(send)}
        value=state.filterString
        onChange={filterString => send(UpdateFilterString(filterString))}
        placeholder={t("filter.input_placeholder")}
        hint={t("filter.input_hint")}
        defaultOptions={defaultOptions()}
      />
      <div id="courses" className="mx-auto max-w-4xl w-full">
        {switch state.courses {
        | Unloaded =>
          <div className="px-2 lg:px-5 mt-8">
            <div className="grid grid-cols-2 gap-x-10 gap-y-8">
              {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
            </div>
          </div>
        | PartiallyLoaded(courses, cursor) =>
          <div>
            {showCourses(courses, state, value, onChange)}
            {switch state.loading {
            | LoadingMore =>
              <div className="px-2 lg:px-5">
                <div className="grid grid-cols-2 gap-x-10">
                  {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
                </div>
              </div>
            | NotLoading =>
              <div className="px-5 pb-6">
                <button
                  className="btn btn-primary-ghost cursor-pointer w-full"
                  onClick={_ => {
                    send(BeginLoadingMore)
                    loadCourses(state, Some(cursor), send)
                  }}>
                  {t("button_load_more")->str}
                </button>
              </div>
            | Reloading => React.null
            }}
          </div>
        | FullyLoaded(courses) => <div> {showCourses(courses, state, value, onChange)} </div>
        }}
      </div>
      {switch state.courses {
      | Unloaded => React.null
      | _ =>
        let loading = switch state.loading {
        | NotLoading => false
        | Reloading => true
        | LoadingMore => false
        }
        <LoadingSpinner loading />
      }}
    </div>
  </div>
}
