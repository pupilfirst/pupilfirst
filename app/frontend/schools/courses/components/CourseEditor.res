%%raw(`import "./CourseEditor.css"`)

exception UnsafeFindFailed(string)

open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor")
let ts = I18n.ts

let str = React.string

type status = [#Active | #Ended | #Archived]

module CourseFragment = Course.Fragments

module CoursesQuery = %graphql(`
  query CoursesQuery($search: String, $after: String,$courseId: ID, $status: CourseStatus) {
    courses(status: $status, search: $search, first: 10, after: $after){
      nodes {
        ...CourseFragment
      }
      pageInfo{
        endCursor,hasNextPage
      }
      totalCount
    }
    course(id: $courseId){
        ...CourseFragment
    }
  }
  `)

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
  | ShowForm(option<string>)

type state = {
  loading: Loading.t,
  courses: Pagination.t,
  filterString: string,
  filter: filter,
  totalEntriesCount: int,
  reloadCourses: bool,
  selectedCourse: option<Course.t>,
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
  | UpdateCourse(Course.t)
  | LoadCourses(option<string>, bool, array<Course.t>, int)
  | UpdateSelectedCourse(option<Course.t>)

let reducer = (state, action) =>
  switch action {
  | UpdateSelectedCourse(selectedCourse) => {
      ...state,
      selectedCourse: selectedCourse,
    }
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
      reloadCourses: !state.reloadCourses,
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
  | UpdateCourse(course) =>
    let newCourses = Pagination.update(state.courses, Course.updateList(course))
    {...state, courses: newCourses}
  }

let updateCourse = (send, course) => {
  RescriptReactRouter.push("/school/courses/")
  send(UpdateCourse(course))
}

let courseLink = (href, title, icon) =>
  <a
    key=href
    href
    className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
    <i className=icon /> <span className="font-semibold ml-2"> {title->str} </span>
  </a>

let courseLinks = course => {
  let baseUrl = "/school/courses/" ++ Course.id(course)
  [
    courseLink(
      "/courses/" ++ Course.id(course) ++ "/curriculum",
      t("course_links.view_as_student"),
      "fas fa-eye",
    ),
    courseLink(
      baseUrl ++ "/curriculum",
      t("course_links.edit_curriculum"),
      "fas fa-fw fa-check-square",
    ),
    courseLink(
      baseUrl ++ "/students",
      t("course_links.manage_students"),
      "fas fa-fw fa-users fa-fw",
    ),
    courseLink(baseUrl ++ "/coaches", t("course_links.manage_coaches"), "fas fa-fw fa-user fa-fw"),
    courseLink(
      baseUrl ++ "/exports",
      t("course_links.download_reports"),
      "fas fa-fw fa-file fa-fw",
    ),
  ]
}

let loadCourses = (courseId, state, cursor, send) => {
  let variables = CoursesQuery.makeVariables(
    ~status=?state.filter.status,
    ~after=?cursor,
    ~search=?state.filter.name,
    ~courseId?,
    (),
  )
  CoursesQuery.make(variables)
  |> Js.Promise.then_(response => {
    let courses = Js.Array.map(
      rawCourse => Course.makeFromJs(rawCourse),
      response["courses"]["nodes"],
    )
    let course = response["course"]->Belt.Option.map(Course.makeFromJs)
    switch course {
    | None => send(UpdateSelectedCourse(None))
    | Some(course) =>
      switch courses->Js.Array2.find(c => {c.id == course.id}) {
      | None => send(UpdateSelectedCourse(Some(course)))
      | Some(_) => send(UpdateSelectedCourse(None))
      }
    }
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

let dropdownSelected =
  <button
    className="dropdown__btn appearance-none flex bg-white border hover:bg-primary-100 hover:text-primary-500 items-center relative justify-between focus:outline-none focus:bg-primary-100 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500 font-semibold text-sm px-3 py-2 rounded w-full">
    <span> {str(t("quick_links"))} </span>
    <i className="fas fa-chevron-down text-xs ml-3 font-semibold" />
  </button>

let showCourse = course => {
  <Spread key={Course.id(course)} props={"data-submission-id": Course.name(course)}>
    <div className="w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
      <div className="flex shadow bg-white rounded-lg flex-col justify-between h-full">
        <div>
          <div className="relative">
            <div className="relative pb-1/2 bg-gray-800 rounded-t-lg z-0">
              {switch Course.thumbnail(course) {
              | Some(image) =>
                <img
                  className="absolute h-full w-full object-cover rounded-t-lg"
                  src={Course.imageUrl(image)}
                />
              | None =>
                <div
                  className="course-editor-course__cover rounded-t-lg absolute h-full w-full svg-bg-pattern-1"
                />
              }}
            </div>
            <div
              className="course-editor-course__title-container absolute w-full flex inset-x-0 bottom-0 p-4 z-10"
              key={Course.id(course)}>
              <h4
                className="course-editor-course__title text-white font-semibold leading-tight pr-4 text-lg md:text-xl">
                {str(Course.name(course))}
              </h4>
            </div>
          </div>
          {ReactUtils.nullIf(
            <div className="px-4 pt-4">
              <a
                ariaLabel={t("view_public_page") ++ " " ++ Course.name(course)}
                href={"/courses/" ++ Course.id(course)}
                target="_blank"
                className="inline-flex items-center underline rounded p-1 text-sm font-semibold cursor-pointer text-gray-800 hover:text-primary-500 focus:outline-none focus:text-primary-500 focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
                <Icon className="if i-external-link-solid mr-2" />
                <span> {t("view_public_page")->str} </span>
              </a>
            </div>,
            Belt.Option.isSome(Course.archivedAt(course)),
          )}
          <div
            className="course-editor-course__description text-sm px-4 pt-2 w-full leading-relaxed">
            {str(Course.description(course))}
          </div>
        </div>
        <div className="grid grid-cols-5 gap-4 p-4">
          <button
            title={ts("edit") ++ " " ++ Course.name(course)}
            className="col-span-3 btn btn-default px-4 py-2 bg-primary-50 text-primary-500 rounded text-sm cursor-pointer"
            onClick={_ =>
              RescriptReactRouter.push("/school/courses/" ++ Course.id(course) ++ "/details")}>
            <div>
              <FaIcon classes="far fa-edit mr-3" />
              <span className="font-semibold"> {str(t("edit_course_details"))} </span>
            </div>
          </button>
          {ReactUtils.nullIf(
            <Dropdown
              className="col-span-2" selected={dropdownSelected} contents={courseLinks(course)}
            />,
            Belt.Option.isSome(Course.archivedAt(course)),
          )}
        </div>
      </div>
    </div>
  </Spread>
}

let showCourses = (courses, state) => {
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
          {Js.Array.map(course => showCourse(course), courses)->React.array}
        </div>}
    {entriesLoadedData(state.totalEntriesCount, Array.length(courses))}
  </div>
}

let reloadCoursesCB = (send, ()) => {
  RescriptReactRouter.push("/school/courses/")
  send(ReloadCourses)
}

let decodeTabString = tab => {
  switch tab {
  | "details" => CourseEditor__Form.DetailsTab
  | "images" => CourseEditor__Form.ImagesTab
  | "actions" => CourseEditor__Form.ActionsTab
  | _ => CourseEditor__Form.DetailsTab
  }
}

let raiseUnsafeFindError = id => {
  let message = "Unable to be find course with id: " ++ id ++ " in CourseEditor"
  Rollbar.error(message)
  Notification.error(t("notification_error_head"), t("notification_error_body"))
  raise(UnsafeFindFailed(message))
}

@react.component
let make = () => {
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
      reloadCourses: false,
      selectedCourse: None,
    },
  )

  let url = RescriptReactRouter.useUrl()

  let (editorAction, selectedTab) = switch url.path {
  | list{"school", "courses", "new", ..._} => (ShowForm(None), CourseEditor__Form.DetailsTab)
  | list{"school", "courses", courseId, tab, ..._} => (
      ShowForm(courseId->StringUtils.paramToId),
      decodeTabString(tab),
    )
  | _ => (Hidden, CourseEditor__Form.DetailsTab)
  }

  React.useEffect2(() => {
    switch url.path {
    | list{"school", "courses", courseId, ..._} => loadCourses(Some(courseId), state, None, send)
    | _ => loadCourses(None, state, None, send)
    }
    None
  }, (state.filter, state.reloadCourses))

  <div className="flex flex-1 h-full bg-gray-50 overflow-y-scroll">
    {switch (state.courses, editorAction) {
    | (Unloaded, _)
    | (_, Hidden) => React.null
    | (_, ShowForm(id)) => {
        let course = switch state.selectedCourse {
        | Some(c) if Some(c.id) == id => Some(c)
        | _ =>
          Belt.Option.flatMap(id, id => {
            Some(
              ArrayUtils.unsafeFind(
                c => Course.id(c) == id,
                "Unable to find course with ID: " ++ id ++ " in Courses Index",
                Pagination.toArray(state.courses),
              ),
            )
          })
        }

        <SchoolAdmin__EditorDrawer2
          closeDrawerCB={_ => RescriptReactRouter.push("/school/courses/")}>
          <CourseEditor__Form
            course
            updateCourseCB={updateCourse(send)}
            reloadCoursesCB={reloadCoursesCB(send)}
            selectedTab
          />
        </SchoolAdmin__EditorDrawer2>
      }
    }}
    <div className="flex-1 flex flex-col">
      <div className="items-center justify-between max-w-4xl mx-auto mt-8 w-full px-10">
        <button
          className="w-full flex items-center justify-center relative bg-white border-dashed text-primary-500 border-2 border-primary-300  hover:text-primary-600 hover:shadow-md hover:border-primary-300 focus:outline-none focus:bg-gray-50 focus:text-primary-600 focus:shadow-md focus:border-primary-300 p-6 rounded-lg cursor-pointer"
          onClick={_ => RescriptReactRouter.push("/school/courses/new")}>
          <i className="fas fa-plus-circle text-lg" />
          <span className="font-semibold ml-2"> {str(t("add_new_course"))} </span>
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
          <div className="px-2 lg:px-5 mt-8">
            <div className="grid grid-cols-2 gap-x-10 gap-y-8">
              {SkeletonLoading.multiple(~count=4, ~element=SkeletonLoading.imageCard())}
            </div>
          </div>
        | PartiallyLoaded(courses, cursor) =>
          <div>
            {showCourses(courses, state)}
            {switch state.loading {
            | LoadingMore =>
              <div className="px-2 lg:px-5">
                <div className="grid grid-cols-2 gap-x-10">
                  {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.imageCard())}
                </div>
              </div>
            | NotLoading =>
              <div className="px-5 pb-6">
                <button
                  className="btn btn-primary-ghost cursor-pointer w-full"
                  onClick={_ => {
                    send(BeginLoadingMore)
                    loadCourses(None, state, Some(cursor), send)
                  }}>
                  {t("button_load_more")->str}
                </button>
              </div>
            | Reloading => React.null
            }}
          </div>
        | FullyLoaded(courses) => <div> {showCourses(courses, state)} </div>
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
