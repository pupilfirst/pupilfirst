%%raw(`import "./CourseEditor__Root.css"`)

@module("../../shared/images/add-new-course.svg")
external addNewCourseSVG: string = "default"

exception UnsafeFindFailed(string)

open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor__Root")
let ts = I18n.ts

let str = React.string

type status = [#Active | #Ended | #Archived]

module CourseFragment = Course.Fragment

module CoursesQuery = %graphql(`
  query CoursesQuery($search: String, $after: String, $courseId: ID!, $status: CourseStatus, $skipCourseLoad: Boolean!, $skipSchoolStatsLoad: Boolean!) {
    courses(status: $status, search: $search, first: 10, after: $after){
      nodes {
        ...CourseFragment
      }
      pageInfo{
        endCursor,hasNextPage
      }
      totalCount
    }
    schoolStats @skip(if: $skipSchoolStatsLoad) {
      studentsCount
      coachesCount
    }
    course(id: $courseId) @skip(if: $skipCourseLoad) {
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

type schoolStats =
  | Unloaded
  | Loaded({studentsCount: int, coachesCount: int})

type state = {
  loading: LoadingV2.t,
  courses: Pagination.t,
  filterString: string,
  filter: filter,
  totalEntriesCount: int,
  reloadCourses: bool,
  selectedCourse: option<Course.t>,
  schoolStats: schoolStats,
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
  | LoadCourses(option<string>, bool, array<Course.t>, int, option<schoolStats>)
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
      loading: LoadingV2.setReloading(state.loading),
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
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  | UpdateFilterString(filterString) => {...state, filterString: filterString}
  | LoadCourses(endCursor, hasNextPage, newCourses, totalEntriesCount, schoolSummary) =>
    let courses = switch state.loading {
    | LoadingMore => Js.Array.concat(newCourses, Pagination.toArray(state.courses))
    | Reloading(_) => newCourses
    }

    {
      ...state,
      courses: Pagination.make(courses, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount: totalEntriesCount,
      schoolStats: Belt.Option.getWithDefault(schoolSummary, state.schoolStats),
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
    <i className=icon /> <span className="font-semibold ms-2"> {title->str} </span>
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

let loadCourses = (courseId, state, cursor, ~skipSchoolStatsLoad=true, send) => {
  let variables = CoursesQuery.makeVariables(
    ~status=?state.filter.status,
    ~after=?cursor,
    ~search=?state.filter.name,
    ~courseId=Belt.Option.getWithDefault(courseId, ""),
    ~skipCourseLoad=Belt.Option.isNone(courseId),
    ~skipSchoolStatsLoad,
    (),
  )
  CoursesQuery.fetch(variables)
  |> Js.Promise.then_((response: CoursesQuery.t) => {
    let courses =
      response.courses.nodes->Js.Array2.map(rawCourse => Course.makeFromFragment(rawCourse))
    let course = response.course->Belt.Option.map(Course.makeFromFragment)
    switch course {
    | None => send(UpdateSelectedCourse(None))
    | Some(course) =>
      switch courses->Js.Array2.find(c => {c.id == course.id}) {
      | None => send(UpdateSelectedCourse(Some(course)))
      | Some(_) => send(UpdateSelectedCourse(None))
      }
    }

    let schoolStats = Belt.Option.map(response.schoolStats, s => Loaded({
      studentsCount: s.studentsCount,
      coachesCount: s.coachesCount,
    }))
    send(
      LoadCourses(
        response.courses.pageInfo.endCursor,
        response.courses.pageInfo.hasNextPage,
        courses,
        response.courses.totalCount,
        schoolStats,
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
    className="text-white md:text-gray-900 bg-gray-900 md:bg-gray-100 appearance-none flex items-center justify-between hover:bg-gray-800 md:hover:bg-gray-50 hover:text-gray-50 focus:bg-gray-50 md:hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-semibold relative px-3 py-2 rounded-md w-full focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 ">
    <span> {str(t("quick_links"))} </span>
    <i className="fas fa-chevron-down text-xs ms-3 font-semibold" />
  </button>

let showCourse = course => {
  <Spread key={Course.id(course)} props={"data-t": Course.name(course)}>
    <div className="w-full relative">
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
                className="course-editor-course__title text-white font-semibold leading-tight pe-4 text-lg md:text-xl">
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
                <Icon className="if i-external-link-solid me-2 rtl:-rotate-90" />
                <span> {t("view_public_page")->str} </span>
              </a>
            </div>,
            Belt.Option.isSome(Course.archivedAt(course)),
          )}
          <p className="text-sm px-4 py-2 text-gray-600"> {str(Course.description(course))} </p>
        </div>
        <div className="grid grid-cols-3 py-4 divide-x rtl:divide-x-reverse divide-gray-300">
          <Spread props={"data-t": `${Course.name(course)} cohorts count`}>
            <div className="flex-1 px-4">
              <p className="text-sm text-gray-500 font-medium"> {ts("cohorts")->str} </p>
              <p className="mt-1 text-lg font-semibold">
                {Course.cohortsCount(course)->string_of_int->str}
              </p>
            </div>
          </Spread>
          <Spread props={"data-t": `${Course.name(course)} coaches count`}>
            <div className="flex-1 px-4">
              <p className="text-sm text-gray-500 font-medium"> {ts("coaches")->str} </p>
              <p className="mt-1 text-lg font-semibold">
                {Course.coachesCount(course)->string_of_int->str}
              </p>
            </div>
          </Spread>
          <Spread props={"data-t": `${Course.name(course)} levels count`}>
            <div className="flex-1 px-4">
              <p className="pe-6 text-sm text-gray-500 font-medium"> {ts("levels")->str} </p>
              <p className="mt-1 text-lg font-semibold">
                {Course.levelsCount(course)->string_of_int->str}
              </p>
            </div>
          </Spread>
        </div>
        {ReactUtils.nullIf(
          <div className="px-4">
            <Dropdown
              className="col-span-2 w-full"
              selected={dropdownSelected}
              contents={courseLinks(course)}
            />
          </div>,
          Belt.Option.isSome(Course.archivedAt(course)),
        )}
        <div className="grid grid-cols-6 gap-4 p-4">
          <a
            title={"View Course"}
            className="col-span-3 btn btn-primary px-4 py-2 bg-primary-50 rounded text-sm cursor-pointer"
            href={"/school/courses/" ++ Course.id(course) ++ "/curriculum"}>
            <div>
              <FaIcon classes="far fa-edit me-3" />
              <span className="font-semibold"> {str(t("course_links.edit_curriculum"))} </span>
            </div>
          </a>
          <button
            title={ts("edit") ++ " " ++ Course.name(course)}
            className="col-span-3 btn btn-default px-4 py-2 bg-primary-50 text-primary-500 rounded text-sm cursor-pointer"
            onClick={_ =>
              RescriptReactRouter.push("/school/courses/" ++ Course.id(course) ++ "/details")}>
            <div>
              <FaIcon classes="far fa-edit me-3" />
              <span className="font-semibold"> {str(t("edit_course_details"))} </span>
            </div>
          </button>
        </div>
      </div>
    </div>
  </Spread>
}

let showCourses = (courses, state) => {
  <div className="w-full">
    <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mt-8">
      <div
        className="bg-gray-100 border-2 border-gray-300 border-dashed rounded-lg p-4 text-center grid place-items-center">
        <EmptyState
          title={t("add_new_course")}
          description={t("create_description")}
          primaryAction={<button
            className="btn btn-primary btn-lg"
            onClick={_ => {
              RescriptReactRouter.push("/school/courses/new")
            }}>
            <PfIcon className="if i-plus-circle-regular if-fw" />
            <span className="font-semibold ms-1"> {str(t("add_new_course"))} </span>
          </button>}
          image={<img src={addNewCourseSVG} />}
        />
      </div>
      {courses->Js.Array2.map(showCourse)->React.array}
    </div>
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
let make = (~school) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      courses: Pagination.Unloaded,
      totalEntriesCount: 0,
      loading: LoadingV2.empty(),
      filterString: "",
      filter: {
        name: None,
        status: Some(#Active),
      },
      reloadCourses: false,
      selectedCourse: None,
      schoolStats: Unloaded,
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
    | list{"school"} | list{"school", "courses", "new", ..._} =>
      loadCourses(None, state, None, send, ~skipSchoolStatsLoad=false)
    | list{"school", "courses", courseId, ..._} =>
      loadCourses(Some(courseId), state, None, send, ~skipSchoolStatsLoad=false)
    | _ => loadCourses(None, state, None, send)
    }
    None
  }, (state.filter, state.reloadCourses))

  <div className="flex min-h-full bg-gray-50">
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
      <div className="w-full">
        <div className="max-w-full mx-auto relative overflow-hidden">
          <div className="bg-gradient-to-r from-secondary-500 to-secondary-600 bg-cover h-40">
            {switch School.coverImageUrl(school) {
            | Some(image) =>
              <img
                className="absolute h-full w-full object-cover"
                src={image}
                alt={School.name(school)}
              />
            | None =>
              <div className="school-customize__cover-default h-full w-full svg-bg-pattern-6" />
            }}
          </div>
          <div className="w-full bg-white p-6">
            <div className="flex items-center max-w-4xl 2xl:max-w-5xl mx-auto justify-between">
              <div className="flex gap-6 px-6">
                <div
                  className="school-overview__logo-container flex items-center bg-white p-3 border-4 border-white shadow-md ring-1 ring-gray-100 rounded-full -mt-16 overflow-hidden">
                  {switch School.logoUrl(school) {
                  | Some(url) =>
                    <img
                      className="h-9 md:h-12 object-contain flex text-sm items-center"
                      src=url
                      alt={"Logo of " ++ School.name(school)}
                    />
                  | None =>
                    <div
                      className="p-2 rounded-lg bg-white text-gray-900 hover:bg-gray-50 hover:text-primary-600">
                      <span className="text-xl font-bold leading-tight">
                        {School.name(school)->str}
                      </span>
                    </div>
                  }}
                </div>
                <div className="school-overview__school-name">
                  <p className="text-sm text-gray-500"> {ts("school")->str} </p>
                  <h2 className="text-xl font-bold"> {School.name(school)->str} </h2>
                </div>
              </div>
              {switch state.schoolStats {
              | Unloaded => React.null
              | Loaded(stats) =>
                <div className="flex gap-6">
                  <div className="border-e pe-6">
                    <Spread props={"data-t": "school students"}>
                      <div>
                        <p className="text-sm text-gray-500"> {ts("students")->str} </p>
                        <p className="text-xl font-bold">
                          {stats.studentsCount->string_of_int->str}
                        </p>
                      </div>
                    </Spread>
                  </div>
                  <div className="">
                    <Spread props={"data-t": "school coaches"}>
                      <div>
                        <p className="text-sm text-gray-500"> {ts("coaches")->str} </p>
                        <p className="text-xl font-bold">
                          {stats.coachesCount->string_of_int->str}
                        </p>
                      </div>
                    </Spread>
                  </div>
                </div>
              }}
            </div>
          </div>
        </div>
      </div>
      <div className="max-w-4xl mx-auto w-full">
        <div className="w-full sticky top-0 z-30 mt-4 px-6">
          <label
            htmlFor="search_courses"
            className="block text-tiny font-semibold uppercase ps-px rtl:text-right">
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
            | Reloading(times) =>
              ReactUtils.nullUnless(
                <div className="px-5 pb-6">
                  <button
                    className="btn btn-primary-ghost cursor-pointer w-full"
                    onClick={_ => {
                      send(BeginLoadingMore)
                      loadCourses(None, state, Some(cursor), send)
                    }}>
                    {t("button_load_more")->str}
                  </button>
                </div>,
                ArrayUtils.isEmpty(times),
              )
            }}
          </div>
        | FullyLoaded(courses) => <div> {showCourses(courses, state)} </div>
        }}
      </div>
      {Pagination.showLoading(state.courses, state.loading)}
    </div>
  </div>
}
