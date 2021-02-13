open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor")

%bs.raw(`require("courses/shared/background_patterns.css")`)

let str = React.string

module CoursesQuery = %graphql(
  `
  query CoursesQuery($search: String, $after: String, $archived: Boolean) {
    courses(archived: $archived, search: $search, first: 10, after: $after){
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
  archived: option<bool>,
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
  | SetFilterLive
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
        archived: Some(true),
      },
    }
  | SetFilterLive => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        archived: Some(false),
      },
    }
  | ClearArchivedFilter => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        archived: None,
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
    className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 whitespace-no-wrap">
    <i className=icon /> <span className="font-semibold ml-2"> {title |> str} </span>
  </a>

let courseLinks = course => {
  let baseUrl = "/school/courses/" ++ Course.id(course)
  [
    {courseLink(baseUrl ++ "/curriculum", "Edit Curriculum", "fas fa-fw fa-check-square")},
    {courseLink(baseUrl ++ "/students", "Manage Students", "fas fa-fw fa-users fa-fw")},
    {courseLink(baseUrl ++ "/coaches", "Manage Coaches", "fas fa-fw fa-user fa-fw")},
    {courseLink(baseUrl ++ "/exports", "Download Reports", "fas fa-fw fa-file fa-fw")},
  ]
}

let loadCourses = (state, cursor, send) => {
  CoursesQuery.make(
    ~archived=?state.filter.archived,
    ~after=?cursor,
    ~search=?state.filter.name,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let courses =
      response["courses"]["nodes"] |> Js.Array.map(rawCourse => Course.makeFromJs(rawCourse))
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
    | Archived
    | Live
    | Name(string)

  let label = s =>
    switch s {
    | Archived => Some(t("filter.label.archived"))
    | Live => Some(t("filter.label.live"))
    | Name(_) => Some(t("filter.label.name"))
    }

  let value = s =>
    switch s {
    | Archived => t("filter.archived")
    | Live => t("filter.live")
    | Name(search) => search
    }

  let searchString = s =>
    switch s {
    | Archived => t("filter.archived")
    | Live => t("filter.live")
    | Name(search) => search
    }

  let color = t =>
    switch t {
    | Live => "blue"
    | Name(_search) => "gray"
    | Archived => "orange"
    }

  let name = search => Name(search)
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unselected = state => {
  let trimmedFilterString = state.filterString |> String.trim
  let name = trimmedFilterString == "" ? [] : [Selectable.name(trimmedFilterString)]

  Js.Array.concat([Selectable.Archived, Selectable.Live], name)
}

let defaultOptions = () => [Selectable.Archived, Selectable.Live]

let selected = state => {
  let selectedStatusFilters = state.filter.archived->Belt.Option.mapWithDefault([], a => {
    [a ? Selectable.Archived : Selectable.Live]
  })

  let selectedSearchString =
    state.filter.name |> OptionUtils.mapWithDefault(name => [Selectable.name(name)], [])

  Js.Array.concat(selectedStatusFilters, selectedSearchString)
}

let onSelectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.Archived => send(SetFilterArchived)
  | Live => send(SetFilterLive)
  | Name(n) => send(SetSearchString(n))
  }

let onDeselectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.Archived
  | Live =>
    send(ClearArchivedFilter)
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
    ) |> str}
  </div>

let dropdownSelected =
  <button
    className="dropdown__btn appearance-none flex bg-white border hover:bg-primary-100 hover:text-primary-500 items-center relative justify-between focus:outline-none font-semibold text-sm px-3 py-2 rounded w-full">
    <span> {str("Quick Links")} </span>
    <i className="fas fa-chevron-down text-xs ml-3 font-semibold" />
  </button>

let showCourse = (course, send) => {
  <div
    key={Course.id(course)}
    ariaLabel={Course.name(course)}
    className="w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
    <div className="flex shadow bg-white rounded-lg flex-col justify-between h-full">
      <div>
        <div className="relative">
          <div className="relative pb-1/2 bg-gray-800 rounded-t-lg">
            {switch Course.thumbnail(course) {
            | Some(image) =>
              <img
                className="absolute h-full w-full object-cover rounded-t-lg"
                src={Course.imageUrl(image)}
              />
            | None =>
              <div
                className="user-dashboard-course__cover rounded-t-lg absolute h-full w-full svg-bg-pattern-1"
              />
            }}
          </div>
          <div
            className="user-dashboard-course__title-container absolute w-full flex inset-x-0 bottom-0 p-4 z-50"
            key={Course.id(course)}>
            <h4
              className="user-dashboard-course__title text-white font-semibold leading-tight pr-4 text-lg md:text-xl">
              {str(Course.name(course))}
            </h4>
          </div>
        </div>
        {ReactUtils.nullIf(
          <div className="px-4 pt-4">
            <i className="fas fa-external-link-square-alt" />
            <a
              href={"/courses/" ++ (course |> Course.id)}
              target="_blank"
              className="text-sm font-semibold cursor-pointer ml-2 text-gray-800">
              {"View public page" |> str}
            </a>
          </div>,
          Belt.Option.isSome(Course.archivedAt(course)),
        )}
        <div
          className="user-dashboard-course__description text-sm px-4 pt-4 w-full leading-relaxed">
          {str(Course.description(course))}
        </div>
      </div>
      <div className="grid grid-cols-5 gap-4 p-4">
        <a
          title={"Edit " ++ Course.name(course)}
          className="col-span-3 btn btn-default px-4 py-2 bg-gray-200 text-primary-500 rounded-lg text-sm cursor-pointer"
          onClick={_ => send(UpdateEditorAction(ShowForm(Some(course))))}>
          <div>
            <FaIcon classes="far fa-edit mr-3" />
            <span className="text-black font-semibold"> {str("Edit Course Details")} </span>
          </div>
        </a>
        <Dropdown
          className="col-span-2" selected={dropdownSelected} contents={courseLinks(course)}
        />
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
          {Js.Array.map(course => showCourse(course, send), courses) |> React.array}
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
        archived: Some(false),
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
      <div className="items-center justify-between max-w-4xl mx-auto mt-8 w-full px-10">
        <button
          className="w-full flex items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-md focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg cursor-pointer"
          onClick={_ => send(UpdateEditorAction(ShowForm(None)))}>
          <i className="fas fa-plus-circle text-lg" />
          <span className="font-semibold ml-2"> {"Add New Course" |> str} </span>
        </button>
      </div>
      <div className="max-w-4xl mx-auto w-full">
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
      <div id="courses" className="px-6 pb-4 mx-auto max-w-4xl w-full">
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
                  {t("button_load_more") |> str}
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
