%%raw(`import "./CourseEditor__Root.css"`)

open ThemeSwitch

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

module MoveCourseQuery = %graphql(`
  mutation MoveCourseMutation($id: ID!, $targetPositionCourseId: ID!) {
    moveCourse(id:$id, targetPositionCourseId: $targetPositionCourseId) {
      success
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
  | ReorderCourses(array<Course.t>, option<string>)

let reducer = (state, action) =>
  switch action {
  | UpdateSelectedCourse(selectedCourse) => {
      ...state,
      selectedCourse,
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
  | UpdateFilterString(filterString) => {...state, filterString}
  | LoadCourses(endCursor, hasNextPage, newCourses, totalEntriesCount, schoolSummary) =>
    let courses = switch state.loading {
    | LoadingMore => Js.Array2.concat(Pagination.toArray(state.courses), newCourses)
    | Reloading(_) => newCourses
    }

    {
      ...state,
      courses: Pagination.make(courses, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount,
      schoolStats: Belt.Option.getWithDefault(schoolSummary, state.schoolStats),
    }
  | UpdateCourse(course) =>
    let newCourses = Pagination.update(state.courses, Course.updateList(course))
    {...state, courses: newCourses}
  | ReorderCourses(newCourses, cursor) => {
      ...state,
      courses: Pagination.make(newCourses, true, cursor),
    }
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
  ->Js.Promise2.then((response: CoursesQuery.t) => {
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
  ->ignore
}

let handleMoveCourse = (
  ~course,
  ~direction: Course.direction,
  ~targetPositionCourseId,
  ~send,
  ~state,
) => {
  let id = Course.id(course)
  let cursor = Pagination.getCursor(state.courses)

  MoveCourseQuery.fetch(
    ~notify=false,
    {
      id,
      targetPositionCourseId,
    },
  )
  ->Js.Promise2.then(_ => {
    let index = Pagination.toArray(state.courses)->Js.Array2.indexOf(course)
    let newCourses =
      direction == Up
        ? ArrayUtils.swapUp(index, Pagination.toArray(state.courses))
        : ArrayUtils.swapDown(index, Pagination.toArray(state.courses))
    send(ReorderCourses(newCourses, cursor))
    Js.Promise.resolve()
  })
  ->ignore
}

let updateCourse = (send, course) => {
  RescriptReactRouter.push("/school/courses/")
  send(UpdateCourse(course))
}

let courseLink = (href, title, icon) =>
  <a
    key=href
    href
    title
    className="cursor-pointer w-10 h-10 flex items-center text-lg justify-center bg-gray-800 text-white border border-gray-500 rounded-full hover:text-primary-100 hover:bg-primary-950 focus:outline-none focus:text-primary-500 focus:bg-gray-50 transition">
    <PfIcon className=icon />
  </a>

let courseLinks = course => {
  let baseUrl = "/school/courses/" ++ Course.id(course)
  [
    courseLink(
      "/courses/" ++ Course.id(course) ++ "/curriculum",
      t("course_links.view_as_student"),
      "if i-eye-light if-fw",
    ),
    courseLink(baseUrl ++ "/students", t("course_links.manage_students"), "if i-users-light if-fw"),
    courseLink(
      baseUrl ++ "/calendar_events",
      t("course_links.view_calendar"),
      "if i-calendar-light if-fw",
    ),
  ]
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
  let status = Belt.Option.mapWithDefault(state.filter.status, [#Active, #Ended, #Archived], u =>
    switch u {
    | #Active => [#Ended, #Archived]
    | #Ended => [#Active, #Archived]
    | #Archived => [#Ended, #Active]
    }
  )->Js.Array2.map(Selectable.status)

  Js.Array2.concat(name, status)
}

let defaultOptions = () => [#Active, #Ended, #Archived]->Js.Array2.map(Selectable.status)

let selected = state => {
  let status = state.filter.status->Belt.Option.mapWithDefault([], u => [Selectable.status(u)])

  let selectedSearchString = OptionUtils.mapWithDefault(
    name => [Selectable.name(name)],
    [],
    state.filter.name,
  )

  Js.Array2.concat(selectedSearchString, status)
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

let showCourse = (course, index, state, send, courses) => {
  <Spread key={Course.id(course)} props={"data-t": Course.name(course)}>
    <div className="w-full relative mb-8">
      <div
        className="absolute top-5 -start-10 flex flex-col bg-gray-100 rounded-s-md overflow-hidden">
        <button
          ariaLabel={ts("move_up")}
          title={ts("move_up")}
          disabled={index == 0}
          onClick={e => {
            let courseIndex = courses->Js.Array2.indexOf(course)
            switch courses->Belt.Array.get(courseIndex - 1) {
            | Some(targetCourse) =>
              handleMoveCourse(
                ~course,
                ~direction=Up,
                ~send,
                ~state,
                ~targetPositionCourseId=Course.id(targetCourse),
              )
            | None => ()
            }
          }}
          className={"w-10 h-10 flex items-center justify-center hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500" ++ (
            index == 0 ? " hidden" : " "
          )}>
          <PfIcon className="if i-arrow-up-light if-fw" />
        </button>
        <button
          ariaLabel={ts("move_down")}
          title={ts("move_down")}
          onClick={e => {
            let courseIndex = courses->Js.Array2.indexOf(course)
            switch courses->Belt.Array.get(courseIndex + 1) {
            | Some(targetCourse) =>
              handleMoveCourse(
                ~course,
                ~direction=Down,
                ~send,
                ~state,
                ~targetPositionCourseId=Course.id(targetCourse),
              )
            | None => ()
            }
          }}
          disabled={index == state.totalEntriesCount - 1}
          className={"w-10 h-10 flex items-center justify-center hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500" ++ (
            index == Pagination.length(state.courses) - 1 ? " hidden" : " "
          )}>
          <PfIcon className="if i-arrow-down-light if-fw" />
        </button>
      </div>
      <div className="bg-white rounded-lg border border-gray-200 grid grid-cols-1 md:grid-cols-2">
        <div className="flex flex-col">
          <h4
            key={Course.id(course)}
            className="mt-5 md:mt-0 w-full text-gray-900 font-semibold leading-tight px-4 pt-5 text-lg md:text-xl">
            {str(Course.name(course))}
          </h4>
          <p className="text-sm px-4 mt-2 text-gray-600"> {str(Course.description(course))} </p>
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
          <div className="grid lg:grid-cols-2 grid-cols-1 gap-4 p-4">
            <a
              title={"View Course"}
              className="btn btn-primary px-4 py-2 bg-primary-50 rounded text-sm cursor-pointer"
              href={"/school/courses/" ++ Course.id(course) ++ "/curriculum"}>
              <div>
                <FaIcon classes="far fa-edit me-3" />
                <span className="font-semibold"> {str(t("course_links.edit_curriculum"))} </span>
              </div>
            </a>
            <button
              title={ts("edit") ++ " " ++ Course.name(course)}
              className="btn border border-primary-200 px-4 py-2 bg-primary-50 text-primary-500 rounded text-sm cursor-pointer"
              onClick={_ =>
                RescriptReactRouter.push("/school/courses/" ++ Course.id(course) ++ "/details")}>
              <div>
                <FaIcon classes="far fa-edit me-3" />
                <span className="font-semibold"> {str(t("edit_course_details"))} </span>
              </div>
            </button>
          </div>
        </div>
        <div className="row-start-1 md:row-start-auto w-full pt-1/2 relative self-center">
          {switch Course.thumbnail(course) {
          | Some(image) =>
            <img
              className="absolute top-0 md:-end-4 object-cover rounded-xl"
              src={Course.imageUrl(image)}
            />
          | None =>
            <div
              className="course-editor-course__cover md:ms-4 w-full absolute inset-0 rounded-xl object-cover svg-bg-pattern-1"
            />
          }}
          <div className="absolute start-1 md:start-5 -bottom-5">
            {ReactUtils.nullIf(
              <div className="flex gap-1 px-4 pt-4">
                {courseLinks(course)
                ->Js.Array2.mapi((content, index) =>
                  <div key={"links-" ++ string_of_int(index)}> content </div>
                )
                ->React.array}
                <a
                  ariaLabel={t("view_public_page") ++ " " ++ Course.name(course)}
                  href={"/courses/" ++ Course.id(course)}
                  target="_blank"
                  className="cursor-pointer px-3 h-10 flex items-center gap-2 text-lg justify-center bg-gray-800 text-white border border-gray-500 rounded-full hover:text-primary-100 hover:bg-primary-950 focus:outline-none focus:text-primary-500 focus:bg-gray-50 transition">
                  <PfIcon className="if i-external-link-light if-fw" />
                  <span className="text-xs"> {t("view_public_page")->str} </span>
                </a>
              </div>,
              Belt.Option.isSome(Course.archivedAt(course)),
            )}
          </div>
        </div>
      </div>
    </div>
  </Spread>
}

let showCourses = (courses, state, send) => {
  <div className="w-full">
    <div className="flex flex-col mt-8">
      <div
        className="bg-gray-100 flex flex-col md:flex-row p-5 items-center gap-3 border-2 border-gray-300 border-dashed rounded-lg mb-8 text-center">
        <img src={addNewCourseSVG} className="flex-1 h-28 md:h-50 object-contain" />
        <div className="flex-1 flex flex-col">
          <h2 className="text-lg font-semibold"> {t("add_new_course")->str} </h2>
          <p className="text-sm text-gray-600"> {t("create_description")->str} </p>
          <button
            className="btn btn-primary btn-lg mt-4"
            onClick={_ => {
              RescriptReactRouter.push("/school/courses/new")
            }}>
            <PfIcon className="if i-plus-circle-regular if-fw" />
            <span className="font-semibold ms-1"> {str(t("add_new_course"))} </span>
          </button>
        </div>
      </div>
      {courses
      ->Js.Array2.mapi((course, index) => showCourse(course, index, state, send, courses))
      ->React.array}
    </div>
    {entriesLoadedData(state.totalEntriesCount, Js.Array2.length(courses))}
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
  let initialState = {
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
  }

  let (state, send) = React.useReducer(reducer, initialState)

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
          <div
            className="bg-gradient-to-r from-secondary-500 to-secondary-600 bg-cover h-40 lg:h-56 2xl:h-64 relative">
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
          <div className="w-full bg-white relative p-6 z-10">
            <div className="flex items-center max-w-4xl 2xl:max-w-5xl mx-auto justify-between">
              <div className="flex gap-6 px-6">
                <div
                  className="school-overview__logo-container flex items-center bg-white p-3 border-4 border-white shadow-md ring-1 ring-gray-100 rounded-full -mt-16 overflow-hidden">
                  {switch getTheme() == "light"
                    ? School.logoOnLightBgUrl(school)
                    : School.logoOnDarkBgUrl(school) {
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
                <div className="flex gap-6 px-6">
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
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto w-full">
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
      <div id="courses" className="px-8 pb-4 mx-auto max-w-4xl 2xl:max-w-5xl w-full">
        {switch state.courses {
        | Unloaded =>
          <div className="px-2 lg:px-5 mt-8">
            <div> {SkeletonLoading.multiple(~count=4, ~element=SkeletonLoading.imageCard())} </div>
          </div>
        | PartiallyLoaded(courses, cursor) =>
          <div>
            {showCourses(courses, state, send)}
            {switch state.loading {
            | LoadingMore =>
              <div className="px-2 lg:px-5">
                <div>
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
        | FullyLoaded(courses) => <div> {showCourses(courses, state, send)} </div>
        }}
      </div>
      {Pagination.showLoading(state.courses, state.loading)}
    </div>
  </div>
}
