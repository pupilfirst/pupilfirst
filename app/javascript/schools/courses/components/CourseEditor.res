open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor")

%bs.raw(`require("courses/shared/background_patterns.css")`)

let str = React.string

type status = [#Active | #Ended | #Archived]

module CoursesQuery = %graphql(
  `
  query CoursesQuery($search: String, $after: String, $status: CourseStatus) {
    courses(status: $status, search: $search, first: 10, after: $after){
      nodes {
        ...Course.Fragments.AllFields
      }
      pageInfo{
        endCursor,hasNextPage
      }
      totalCount
    }
  }
  `
)

module Item = {
  type t = Course.t
}

module Pagination = Pagination.Make(Item)

type filter = {
  status: option<status>,
  name: option<string>,
}

type editorAction =
  | Hidden
  | ShowForm(option<Course.t>)

type state = {
  loading: Loading.t,
  editorAction: editorAction,
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
  | UpdateEditorAction(editorAction)
  | UpdateCourse(Course.t)
  | LoadCourses(option<string>, bool, array<Course.t>, int)

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
      editorAction: Hidden,
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
  | UpdateEditorAction(editorAction) => {...state, editorAction: editorAction}
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
  | UpdateCourse(course) =>
    let newCourses = Pagination.update(state.courses, Course.updateList(course))
    {...state, courses: newCourses, editorAction: Hidden}
  }

let hideEditorAction = (send, ()) => send(UpdateEditorAction(Hidden))

let updateCourse = (send, course) => send(UpdateCourse(course))

let courseLink = (href, title, icon) =>
  <a
    key=href
    href
    className="px-2 py-1 mr-2 mt-2 rounded text-sm bg-gray-100 text-gray-800 hover:bg-gray-200 hover:text-primary-500">
    <i className=icon /> <span className="font-semibold ml-2"> {str(title)} </span>
  </a>

let courseLinks = course => {
  let baseUrl = "/school/courses/" ++ Course.id(course)
  let defaultLinks = [
    {courseLink(baseUrl ++ "/curriculum", "Edit curriculum", "fas fa-check-square")},
    {courseLink(baseUrl ++ "/students", "Manage students", "fas fa-users")},
    {courseLink(baseUrl ++ "/coaches", "Manage coaches", "fas fa-user")},
    {courseLink(baseUrl ++ "/exports", "Download reports", "fas fa-file")},
  ]

  Belt.Option.isSome(Course.archivedAt(course))
    ? defaultLinks
    : Js.Array.concat(
        defaultLinks,
        [
          courseLink(
            "/courses/" ++ Course.id(course) ++ "/curriculum",
            "View as student",
            "fas fa-eye",
          ),
        ],
      )
}

let loadCourses = (state, cursor, send) => {
  CoursesQuery.make(~status=?state.filter.status, ~after=?cursor, ~search=?state.filter.name, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let courses = Js.Array.map(
      rawCourse => Course.makeFromJs(rawCourse),
      response["courses"]["nodes"],
    )
    send(
      LoadCourses(
        response["courses"]["pageInfo"]["endCursor"],
        response["courses"]["pageInfo"]["hasNextPage"],
        courses,
        response["courses"]["totalCount"],
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
  <div className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
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

let dropdownSelected =
  <button className="px-6 py-2 bg-gray-200 text-primary-500 rounded-lg text-sm">
    {str("...")}
  </button>

let showCourse = (course, send) => {
  <div
    key={Course.id(course)}
    ariaLabel={Course.name(course)}
    className="w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
    <div className="flex shadow bg-white rounded-lg flex flex-col justify-between h-full">
      <div>
        <div className="relative">
          <div className="relative pb-1/2 bg-gray-800">
            {switch Course.thumbnail(course) {
            | Some(image) =>
              <img className="absolute h-full w-full object-cover" src={Course.imageUrl(image)} />
            | None =>
              <div
                className="user-dashboard-course__cover absolute h-full w-full svg-bg-pattern-1"
              />
            }}
          </div>
          <div
            className="user-dashboard-course__title-container absolute w-full flex h-16 bottom-0 z-50"
            key={Course.id(course)}>
            <h4
              className="user-dashboard-course__title text-white font-semibold leading-tight pl-6 pr-4 text-lg md:text-xl">
              {str(Course.name(course))}
            </h4>
          </div>
        </div>
        {ReactUtils.nullIf(
          <div className="px-6 pt-4">
            <i className="fas fa-external-link-square-alt" />
            <a
              href={"/courses/" ++ Course.id(course)}
              target="_blank"
              className="text-sm font-semibold cursor-pointer ml-2 text-gray-800">
              {"View public page"->str}
            </a>
          </div>,
          Belt.Option.isSome(Course.archivedAt(course)),
        )}
        <div
          className="user-dashboard-course__description text-sm px-6 pt-4 w-full leading-relaxed">
          {str(Course.description(course))}
        </div>
      </div>
      <div className="flex justify-between items-center m-4">
        <a
          title={"Edit " ++ Course.name(course)}
          className="px-6 py-2 bg-gray-200 text-primary-500 rounded-lg text-sm cursor-pointer"
          onClick={_ => send(UpdateEditorAction(ShowForm(Some(course))))}>
          <div>
            <FaIcon classes="fas fa-pencil-alt mr-2" />
            <span className="text-black font-semibold"> {str("Edit Course Details")} </span>
          </div>
        </a>
        <Dropdown selected={dropdownSelected} contents={courseLinks(course)} />
      </div>
    </div>
  </div>
}

let showCourses = (courses, state, send) => {
  <div className="w-full">
    {ArrayUtils.isEmpty(courses)
      ? <div
          className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center">
          <FaIcon classes="fas fa-comments text-5xl text-gray-400" />
          <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
            {t("empty_courses")->str}
          </h4>
        </div>
      : <div className="flex flex-wrap">
          {Js.Array.map(course => showCourse(course, send), courses)->React.array}
        </div>}
    {entriesLoadedData(state.totalEntriesCount, Array.length(courses))}
  </div>
}

let relaodCoursesCB = (send, ()) => {
  send(ReloadCourses)
}

@react.component
let make = () => {
  let (state, send) = React.useReducer(
    reducer,
    {
      editorAction: Hidden,
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

  <div className="flex flex-1 h-full bg-gray-200 overflow-y-scroll">
    {switch state.editorAction {
    | Hidden => React.null
    | ShowForm(course) =>
      <SchoolAdmin__EditorDrawer2 closeDrawerCB={hideEditorAction(send)}>
        <CourseEditor__Form
          course updateCourseCB={updateCourse(send)} relaodCoursesCB={relaodCoursesCB(send)}
        />
      </SchoolAdmin__EditorDrawer2>
    }}
    <div className="flex-1 flex flex-col">
      <div className="items-center justify-between max-w-3xl mx-auto mt-8 w-full px-10">
        <button
          className="w-full flex items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-md focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg cursor-pointer"
          onClick={_ => send(UpdateEditorAction(ShowForm(None)))}>
          <i className="fas fa-plus-circle text-lg" />
          <span className="font-semibold ml-2"> {str("Add New Course")} </span>
        </button>
      </div>
      <div className="max-w-3xl mx-auto w-full">
        <div className="w-full sticky top-0 z-30 mt-4 px-10">
          <label
            htmlFor="search_courses"
            className="block text-tiny font-semibold uppercase pl-px text-left">
            {t("filter.input_label")->str}
          </label>
          <Multiselect
            id="search_courses"
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
        </div>
      </div>
      <div id="courses" className="px-6 pb-4 mx-auto max-w-3xl w-full">
        {switch state.courses {
        | Unloaded =>
          <div className="px-2 lg:px-8">
            {SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())}
          </div>
        | PartiallyLoaded(courses, cursor) =>
          <div>
            {showCourses(courses, state, send)}
            {switch state.loading {
            | LoadingMore =>
              <div className="px-2 lg:px-8">
                {SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())}
              </div>
            | NotLoading =>
              <div className="px-4 lg:px-8 pb-6">
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
        | FullyLoaded(courses) => <div> {showCourses(courses, state, send)} </div>
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
