open CourseExports__Types

let str = React.string
let t = I18n.t(~scope="components.CourseExport__Root")
let ts = I18n.ts

type state = {
  drawerOpen: bool,
  selectedTags: array<Tag.t>,
  saving: bool,
  reviewedOnly: bool,
  includeInactiveStudents: bool,
  tagSearch: string,
  courseExports: array<CourseExport.t>,
  exportType: CourseExport.exportType,
  selectedCohorts: array<Cohort.t>,
  cohortSearch: string,
  includeUserStandings: bool,
}

let computeInitialState = exports => {
  drawerOpen: false,
  selectedTags: [],
  saving: false,
  reviewedOnly: false,
  includeInactiveStudents: false,
  tagSearch: "",
  courseExports: exports,
  exportType: CourseExport.Students,
  selectedCohorts: [],
  cohortSearch: "",
  includeUserStandings: false,
}

type action =
  | OpenDrawer
  | CloseDrawer
  | BeginSaving
  | FinishSaving(CourseExport.t)
  | FailSaving
  | SetReviewedOnly(bool)
  | SetIncludeInactiveStudents(bool)
  | SelectTag(Tag.t)
  | DeselectTag(Tag.t)
  | SelectExportType(CourseExport.exportType)
  | UpdateTagSearch(string)
  | SelectChort(Cohort.t)
  | DeselectCohort(Cohort.t)
  | UpdateCohortSearch(string)
  | SetIncludeUserStandings(bool)

let reducer = (state, action) =>
  switch action {
  | OpenDrawer => {...state, drawerOpen: true}
  | CloseDrawer => {...state, drawerOpen: false}
  | BeginSaving => {...state, saving: true}
  | FinishSaving(courseExport) => {
      ...state,
      saving: false,
      courseExports: state.courseExports->Js.Array2.concat([courseExport]),
      drawerOpen: false,
    }
  | FailSaving => {...state, saving: false}
  | SetReviewedOnly(reviewedOnly) => {...state, reviewedOnly}
  | SetIncludeInactiveStudents(includeInactiveStudents) => {
      ...state,
      includeInactiveStudents,
    }
  | SelectTag(tag) => {
      ...state,
      selectedTags: state.selectedTags->Js.Array2.concat([tag]),
    }
  | DeselectTag(tag) => {
      ...state,
      selectedTags: state.selectedTags->Js.Array2.filter(t => t->Tag.id != Tag.id(tag)),
    }
  | SelectExportType(exportType) => {...state, exportType}
  | UpdateTagSearch(tagSearch) => {...state, tagSearch}
  | SelectChort(cohort) => {
      ...state,
      selectedCohorts: state.selectedCohorts->Js.Array2.concat([cohort]),
    }
  | DeselectCohort(cohort) => {
      ...state,
      selectedCohorts: state.selectedCohorts->Js.Array2.filter(t =>
        t->Cohort.id != Cohort.id(cohort)
      ),
    }
  | UpdateCohortSearch(cohortSearch) => {
      ...state,
      cohortSearch,
    }
  | SetIncludeUserStandings(includeUserStandings) => {
      ...state,
      includeUserStandings,
    }
  }

let readinessString = courseExport =>
  switch courseExport->CourseExport.file {
  | None =>
    let timeDistance =
      courseExport->CourseExport.createdAt->DateFns.formatDistanceToNow(~addSuffix=true, ())

    t("requested") ++ " " ++ timeDistance
  | Some(file) =>
    let timeDistance =
      file->CourseExport.fileCreatedAt->DateFns.formatDistanceToNow(~addSuffix=true, ())
    t("prepared") ++ " " ++ timeDistance
  }

module TagSelectable = {
  type t = Tag.t
  let value = t => t->Tag.name
  let searchString = t => t->Tag.name
}

module CohortSelectable = {
  type t = Cohort.t
  let value = t => t->Cohort.name
  let searchString = t => t->Cohort.name
}

module CohortSelector = MultiselectInline.Make(CohortSelectable)

module TagsSelector = MultiselectInline.Make(TagSelectable)

let unselected = (allTags, selectedTags) => {
  let selectedTagIds = selectedTags->Js.Array2.map(Tag.id)
  allTags->Js.Array2.filter(t => !(selectedTagIds->Js.Array2.includes(t->Tag.id)))
}

let unselectedCohort = (allCohorts, selectedCohorts) => {
  let selectedCohortIds = selectedCohorts->Js.Array2.map(Cohort.id)
  allCohorts->Js.Array2.filter(t => !(selectedCohortIds->Js.Array2.includes(t->Cohort.id)))
}

module CreateCourseExportQuery = %graphql(`
 mutation CreateCourseExportMutation ($courseId: ID!, $tagIds: [ID!]!, $reviewedOnly: Boolean!, $includeInactiveStudents: Boolean!, $exportType: Export!, $cohortIds: [ID!]!, $includeUserStandings: Boolean!) {
  createCourseExport(courseId: $courseId, tagIds: $tagIds, reviewedOnly: $reviewedOnly, includeInactiveStudents: $includeInactiveStudents, exportType: $exportType, cohortIds: $cohortIds, includeUserStandings: $includeUserStandings){
    courseExport {
      id
      createdAt
      tags
      reviewedOnly
      includeInactiveStudents
      cohorts {
        id
      }
      includeUserStandings
    }
   }
 }
`)

let createCourseExport = (state, send, course, event) => {
  event->ReactEvent.Mouse.preventDefault
  send(BeginSaving)

  let tagIds = state.selectedTags->Js.Array2.map(Tag.id)
  let cohortIds = state.selectedCohorts->Js.Array2.map(Cohort.id)

  let exportType = switch state.exportType {
  | CourseExport.Students => #Students
  | Teams => #Teams
  }

  let variables = CreateCourseExportQuery.makeVariables(
    ~courseId=course->Course.id,
    ~tagIds,
    ~reviewedOnly=state.reviewedOnly,
    ~includeInactiveStudents=state.includeInactiveStudents,
    ~exportType,
    ~cohortIds,
    ~includeUserStandings=state.includeUserStandings,
    (),
  )

  CreateCourseExportQuery.make(variables)
  |> Js.Promise.then_(response => {
    switch response["createCourseExport"]["courseExport"] {
    | Some(export) =>
      /* Add the new course export to the list of exports known by this component. */
      let courseExport = CourseExport.make(
        ~id=export["id"],
        ~exportType=state.exportType,
        ~createdAt=export["createdAt"]->DateFns.decodeISO,
        ~tags=export["tags"],
        ~reviewedOnly=export["reviewedOnly"],
        ~includeInactiveStudents=export["includeInactiveStudents"],
        ~cohortIds=export["cohorts"]->Js.Array2.map(c => c["id"]),
        ~includeUserStandings=state.includeUserStandings,
      )

      send(FinishSaving(courseExport))
    | None => send(FailSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(e => {
    Js.log(e)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let toggleChoiceClasses = value => {
  let defaultClasses = "relative flex flex-col items-center bg-white border border-gray-300 hover:bg-gray-50 text-sm font-semibold focus:outline-none focus:outline-none focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 rounded p-4 w-full"
  value
    ? defaultClasses ++ " bg-gray-50 text-primary-500 border-primary-500"
    : defaultClasses ++ " opacity-75 text-gray-900"
}

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button"
  classes ++ (bool ? " toggle-button__button--active" : "")
}

@react.component
let make = (~course, ~exports, ~tags, ~cohorts) => {
  let (state, send) = React.useReducerWithMapState(reducer, exports, computeInitialState)

  <div className="bg-gray-50 min-h-full" key="School admin coaches course index">
    {state.drawerOpen
      ? <SchoolAdmin__EditorDrawer
          closeDrawerCB={() => send(CloseDrawer)} closeButtonTitle={t("close_export_form")}>
          <div className="mx-auto bg-white">
            <div className="max-w-2xl pt-6 px-6 mx-auto">
              <h5 className="uppercase text-center border-b border-gray-300 pb-2">
                {t("create_action_button")->str}
              </h5>
              <div className="mt-4">
                <label className="block tracking-wide text-xs font-semibold me-6 mb-2">
                  {t("export_type_label")->str}
                </label>
                <div className="flex -mx-2">
                  <div className="w-1/2 px-2">
                    <button
                      onClick={_ => send(SelectExportType(CourseExport.Students))}
                      className={toggleChoiceClasses(state.exportType == CourseExport.Students)}>
                      <i className="fas fa-user" />
                      <div className="mt-1"> {t("students_label")->str} </div>
                    </button>
                  </div>
                  <div className="w-1/2 px-2">
                    <button
                      onClick={_ => send(SelectExportType(CourseExport.Teams))}
                      className={toggleChoiceClasses(state.exportType == CourseExport.Teams)}>
                      <i className="fas fa-user-friends" />
                      <div className="mt-1"> {t("teams_label")->str} </div>
                    </button>
                  </div>
                </div>
              </div>
              <div className="mt-4">
                <label className="block tracking-wide text-xs font-semibold mb-2">
                  {t("export_tags_label")->str}
                </label>
                <TagsSelector
                  placeholder={t("search_tag_placeholder")}
                  emptySelectionMessage={t("search_tags_empty")}
                  selected=state.selectedTags
                  unselected={unselected(tags, state.selectedTags)}
                  onChange={tagSearch => send(UpdateTagSearch(tagSearch))}
                  value=state.tagSearch
                  onSelect={tag => send(SelectTag(tag))}
                  onDeselect={tag => send(DeselectTag(tag))}
                />
              </div>
              <div className="mt-4">
                <label className="block tracking-wide text-xs font-semibold mb-2">
                  {t("export_cohorts_label")->str}
                </label>
                <CohortSelector
                  placeholder={t("search_cohort_placeholder")}
                  emptySelectionMessage={t("search_cohorts_empty")}
                  selected=state.selectedCohorts
                  unselected={unselectedCohort(cohorts, state.selectedCohorts)}
                  onChange={cohortSearch => send(UpdateCohortSearch(cohortSearch))}
                  value=state.cohortSearch
                  onSelect={cohort => send(SelectChort(cohort))}
                  onDeselect={cohort => send(DeselectCohort(cohort))}
                />
              </div>
              <div className="mt-5">
                <label
                  className="block tracking-wide text-xs font-semibold me-6 mb-2"
                  htmlFor="targets_filter">
                  {t("export_targets_label")->str}
                </label>
                <div id="targets_filter" className="flex -mx-2">
                  <div className="w-1/2 px-2">
                    <button
                      onClick={_ => send(SetReviewedOnly(false))}
                      className={toggleChoiceClasses(!state.reviewedOnly)}>
                      <i className="fas fa-list" />
                      <div className="mt-1"> {t("all_targets_label")->str} </div>
                    </button>
                  </div>
                  <div className="w-1/2 px-2">
                    <button
                      onClick={_event => send(SetReviewedOnly(true))}
                      className={toggleChoiceClasses(state.reviewedOnly)}>
                      <i className="fas fa-tasks" />
                      <div className="mt-1"> {t("reviewed_only_targets_label")->str} </div>
                    </button>
                  </div>
                </div>
              </div>
              <div className="mt-5">
                <label
                  className="block tracking-wide text-xs font-semibold me-6 mb-2"
                  htmlFor="inactive_students_filter">
                  {t("students_to_include_label")->str}
                </label>
                <div id="inactive_students_filter" className="flex -mx-2">
                  <div className="w-1/2 px-2">
                    <button
                      onClick={_ => send(SetIncludeInactiveStudents(false))}
                      className={toggleChoiceClasses(!state.includeInactiveStudents)}>
                      <i className="fas fa-list" />
                      <div className="mt-1"> {t("active_students_label")->str} </div>
                    </button>
                  </div>
                  <div className="w-1/2 px-2">
                    <button
                      onClick={_event => send(SetIncludeInactiveStudents(true))}
                      className={toggleChoiceClasses(state.includeInactiveStudents)}>
                      <i className="fas fa-tasks" />
                      <div className="mt-1"> {t("all_students_label")->str} </div>
                    </button>
                  </div>
                </div>
              </div>
              {state.exportType == CourseExport.Students
                ? <div className="mt-5 flex justify-start items-center space-x-2">
                    <span className="tracking-wide text-xs font-semibold">
                      {t("include_user_standings_label")->str}
                    </span>
                    <HelpIcon
                      className="ms-1 text-xs"
                      link="https://docs.pupilfirst.com/users/students#student-standing">
                      {t("include_user_standings_help")->str}
                    </HelpIcon>
                    <div className="flex toggle-button__group shrink-0 rounded-lg">
                      <button
                        className={booleanButtonClasses(state.includeUserStandings)}
                        onClick={_ => send(SetIncludeUserStandings(true))}>
                        {ts("_yes")->str}
                      </button>
                      <button
                        className={booleanButtonClasses(!state.includeUserStandings)}
                        onClick={_ => send(SetIncludeUserStandings(false))}>
                        {ts("_no")->str}
                      </button>
                    </div>
                  </div>
                : React.null}
              <div className="flex max-w-2xl w-full mt-5 pb-5 mx-auto">
                <button
                  disabled=state.saving
                  className="w-full btn btn-primary btn-large"
                  onClick={createCourseExport(state, send, course)}>
                  {if state.saving {
                    <span>
                      <FaIcon classes="fas fa-spinner fa-pulse" />
                      <span className="ms-2"> {t("create_button_active_label")->str} </span>
                    </span>
                  } else {
                    {t("create_button_text")->str}
                  }}
                </button>
              </div>
            </div>
          </div>
        </SchoolAdmin__EditorDrawer>
      : React.null}
    <div className="flex-1 flex flex-col">
      <div className="flex px-6 py-2 items-center justify-between">
        <button
          onClick={_ => send(OpenDrawer)}
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-primary-300 border-dashed hover:border-primary-300 focus:border-primary-300 focus:bg-gray-50 focus:text-primary-600 focus:shadow-lg p-6 rounded-lg mt-8 cursor-pointer">
          <i className="fas fa-file-export text-lg" />
          <h5 className="font-semibold ms-2"> {t("create_action")->str} </h5>
        </button>
      </div>
      {state.courseExports->ArrayUtils.isEmpty
        ? <div className="flex justify-center border rounded p-3 italic mx-auto max-w-2xl w-full">
            {t("no_exports_notice")->str}
          </div>
        : <div className="px-6 pb-4 mt-5 flex flex-1">
            <div className="max-w-2xl w-full mx-auto relative pb-20">
              <h4 className="mt-5 w-full"> {t("heading")->str} </h4>
              <div className="flex mt-4 -mx-3 items-start flex-wrap">
                {ArrayUtils.copyAndSort(
                  (x, y) =>
                    DateFns.differenceInSeconds(
                      y->CourseExport.createdAt,
                      x->CourseExport.createdAt,
                    ),
                  state.courseExports,
                )
                ->Js.Array2.map(courseExport =>
                  <div
                    key={courseExport->CourseExport.id}
                    ariaLabel={t("export") ++ " " ++ courseExport->CourseExport.id}
                    className="flex w-1/2 items-center mb-4 px-3">
                    <div
                      className="course-faculty__list-item shadow bg-white overflow-hidden rounded-lg flex flex-col w-full">
                      <div className="flex flex-1 justify-between">
                        <div className="pt-4 pb-3 px-4">
                          <div className="text-sm">
                            <p className="text-black font-semibold">
                              {courseExport->CourseExport.exportTypeToString->str}
                            </p>
                            <p className="text-gray-600 text-xs mt-px">
                              {courseExport->readinessString->str}
                            </p>
                          </div>
                          <div className="flex flex-wrap text-gray-600 font-semibold text-xs mt-1">
                            {courseExport->CourseExport.reviewedOnly
                              ? <span
                                  className="px-2 py-1 border rounded bg-orange-100 text-orange-600 mt-1 me-1">
                                  {t("reviewed_only_tag")->str}
                                </span>
                              : React.null}
                            {courseExport->CourseExport.includeInactiveStudents
                              ? <span
                                  className="px-2 py-1 border rounded bg-orange-100 text-orange-600 mt-1 me-1">
                                  {t("include_inactive_students_tag")->str}
                                </span>
                              : React.null}
                            {courseExport->CourseExport.includeUserStandings
                              ? <span
                                  className="px-2 py-1 border rounded bg-orange-100 text-orange-600 mt-1 me-1">
                                  {t("includes_user_standings")->str}
                                </span>
                              : React.null}
                            {cohorts
                            ->Js.Array2.filter(cohort =>
                              CourseExport.cohortIds(courseExport)->Js.Array2.includes(
                                Cohort.id(cohort),
                              )
                            )
                            ->Js.Array2.map(cohort =>
                              <span
                                key={Cohort.name(cohort)}
                                className="px-2 py-1 border rounded bg-red-100 text-primary-600 mt-1 me-1">
                                {Cohort.name(cohort)->str}
                              </span>
                            )
                            ->React.array}
                            {courseExport
                            ->CourseExport.tags
                            ->Js.Array2.map(tag =>
                              <span
                                key=tag
                                className="px-2 py-1 border rounded bg-primary-100 text-primary-600 mt-1 me-1">
                                {tag->str}
                              </span>
                            )
                            ->React.array}
                          </div>
                        </div>
                        {switch courseExport->CourseExport.file {
                        | None => React.null
                        | Some(file) =>
                          <a
                            ariaLabel={t("download_course_export") ++
                            " " ++
                            courseExport->CourseExport.id}
                            className="pe-6 ps-4 w-10 text-xs course-faculty__list-item-remove text-gray-600 cursor-pointer flex items-center justify-center hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500"
                            href={file->CourseExport.filePath}>
                            <FaIcon classes="fas fa-file-download" />
                          </a>
                        }}
                      </div>
                    </div>
                  </div>
                )
                ->React.array}
              </div>
            </div>
          </div>}
    </div>
  </div>
}
