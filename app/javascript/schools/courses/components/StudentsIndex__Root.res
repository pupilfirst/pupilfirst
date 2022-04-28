let str = React.string

open StudentsIndex__Types

module Item = {
  type t = StudentInfo.t
}

module PagedStudents = Pagination.Make(Item)

type state = {
  loading: LoadingV2.t,
  submissions: PagedStudents.t,
  levels: array<Level.t>,
  filterInput: string,
  totalEntriesCount: int,
  filterLoading: bool,
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | LoadSubmissions(
      option<string>,
      bool,
      array<StudentInfo.t>,
      int,
      option<Level.t>,
    )
  | LoadLevels(array<Level.t>)
  | BeginLoadingMore
  | BeginReloading
  | SetLevelLoading
  | SetTargetLoading
  | SetCoachLoading
  | ClearLoader


let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  | LoadSubmissions(endCursor, hasNextPage, students, totalEntriesCount, level) =>
    let updatedStudent = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedSubmission.toArray(state.students), students)
    | Reloading(_) => students
    }

    {
      ...state,
      submissions: PagedSubmission.make(updatedStudent, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount: totalEntriesCount,
      levels: ArrayUtils.isEmpty(state.levels)
        ? Belt.Option.mapWithDefault(level, [], t => [t])
        : state.levels,

    }
  | LoadLevels(levels) => {
      ...state,
      levels: levels,
      filterLoading: false,
      levelsLoaded: Loaded,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  | SetLevelLoading => {...state, filterLoading: true, levelsLoaded: Loading}
  | SetTargetLoading => {...state, filterLoading: true, targetsLoaded: Loading}
  | SetCoachLoading => {...state, filterLoading: true, coachesLoaded: Loading}
  }

let updateParams = filter => RescriptReactRouter.push("?" ++ Filter.toQueryString(filter))

module SubmissionsQuery = %graphql(`
    query SubmissionsQuery($courseId: ID!, $search: String, $targetId: ID, $status: SubmissionStatus, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $personalCoachId: ID, $assignedCoachId: ID, $reviewingCoachId: ID, $includeInactive: Boolean, $coachIds: [ID!] $after: String) {
      submissions(courseId: $courseId, search: $search, targetId: $targetId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, levelId: $levelId, personalCoachId: $personalCoachId, assignedCoachId: $assignedCoachId, reviewingCoachId: $reviewingCoachId,  includeInactive: $includeInactive, first: 20, after: $after) {
        nodes {
          id,
          title,
          userNames,
          evaluatedAt,
          passedAt,
          feedbackSent,
          createdAt,
          teamName,
          levelNumber
          reviewer {
            name,
            assignedAt,
          }
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
      level(levelId: $levelId, courseId: $courseId) {
        id
        name
        number
      }
      coaches(coachIds: $coachIds, courseId: $courseId) {
        ...UserProxy.Fragments.AllFields
      }
      targetInfo(targetId: $targetId, courseId: $courseId) {
        id
        title
      }
    }
  `)

module LevelsQuery = %graphql(`
    query LevelsQuery($courseId: ID!) {
      levels(courseId: $courseId) {
        id
        name
        number
      }
    }
  `)

let getSubmissions = (send, courseId, cursor, filter) => {
  let coachIds =
    [
      Filter.personalCoachId(filter),
      Filter.assignedCoachId(filter),
      Filter.reviewingCoachId(filter),
    ]
    ->Js.Array2.map(Belt.Option.mapWithDefault(_, [], t => [t]))
    ->ArrayUtils.flattenV2

  SubmissionsQuery.make(
    ~courseId,
    ~status=?Filter.tab(filter),
    ~sortDirection=Filter.sortDirection(filter),
    ~sortCriterion=Filter.sortCriterion(filter),
    ~levelId=?Filter.levelId(filter),
    ~personalCoachId=?Filter.personalCoachId(filter),
    ~assignedCoachId=?Filter.assignedCoachId(filter),
    ~reviewingCoachId=?Filter.reviewingCoachId(filter),
    ~targetId=?Filter.targetId(filter),
    ~search=?Filter.nameOrEmail(filter),
    ~includeInactive=Filter.includeInactive(filter),
    ~coachIds,
    ~after=?cursor,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let target = OptionUtils.map(TargetInfo.makeFromJs, response["targetInfo"])
    let coaches = Js.Array2.map(response["coaches"], Coach.makeFromJs)
    let level = OptionUtils.map(Level.makeFromJs, response["level"])
    send(
      LoadSubmissions(
        response["submissions"]["pageInfo"]["endCursor"],
        response["submissions"]["pageInfo"]["hasNextPage"],
        Js.Array.map(IndexSubmission.makeFromJS, response["submissions"]["nodes"]),
        response["submissions"]["totalCount"],
        target,
        level,
        coaches,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let getLevels = (send, courseId, state) => {
  if state.levelsLoaded == Unloaded {
    send(SetLevelLoading)

    LevelsQuery.make(~courseId, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response => {
      send(LoadLevels(Js.Array.map(Level.makeFromJs, response["levels"])))
      Js.Promise.resolve()
    })
    |> ignore
  }
}

let getCoaches = (send, courseId, state) => {
  if state.coachesLoaded == Unloaded {
    send(SetCoachLoading)

    CoachesQuery.make(~courseId, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response => {
      send(LoadCoaches(Js.Array.map(Coach.makeFromJs, response["coaches"])))
      Js.Promise.resolve()
    })
    |> ignore
  }
}

let getTargets = (send, courseId, state) => {
  if state.targetsLoaded == Unloaded {
    send(SetTargetLoading)

    ReviewedTargetsInfoQuery.make(~courseId, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response => {
      send(LoadTargets(Js.Array.map(TargetInfo.makeFromJs, response["reviewedTargetsInfo"])))
      Js.Promise.resolve()
    })
    |> ignore
  }
}

module Sortable = {
  type t = [#EvaluatedAt | #SubmittedAt]

  let criterion = t =>
    switch t {
    | #SubmittedAt => tc("submitted_at")
    | #EvaluatedAt => tc("reviewed_at")
    }
  let criterionType = _t => #Number
}

module SubmissionsSorter = Sorter.Make(Sortable)

let submissionsSorter = filter => {
  let criteria = switch Filter.tab(filter) {
  | Some(c) =>
    switch c {
    | #Pending => [#SubmittedAt]
    | #Reviewed => [#SubmittedAt, #EvaluatedAt]
    }
  | None => [#SubmittedAt]
  }

  <div ariaLabel="Change submissions sorting" className="flex-shrink-0 md:ml-2">
    <label className="hidden md:block text-tiny font-semibold uppercase pb-1">
      {tc("sort_by")->str}
    </label>
    <SubmissionsSorter
      criteria
      selectedCriterion={filter.sortCriterion}
      direction={filter.sortDirection}
      onDirectionChange={sortDirection => updateParams({...filter, sortDirection: sortDirection})}
      onCriterionChange={sortCriterion => updateParams({...filter, sortCriterion: sortCriterion})}
    />
  </div>
}

let reloadSubmissions = (courseId, filter, send) => {
  send(BeginReloading)
  getSubmissions(send, courseId, None, filter)
}

let submissionsLoadedData = (totalSubmissionsCount, loadedSubmissionsCount) =>
  <p tabIndex=0 className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {str(
      totalSubmissionsCount == loadedSubmissionsCount
        ? tc(~count=loadedSubmissionsCount, "submissions_fully_loaded_text")
        : tc(
            ~count=loadedSubmissionsCount,
            ~variables=[
              ("total_submissions", string_of_int(totalSubmissionsCount)),
              ("loaded_submissions_count", string_of_int(loadedSubmissionsCount)),
            ],
            "submissions_partially_loaded_text",
          ),
    )}
  </p>

let submissionsList = (submissions, state, filter) =>
  <div>
    <CoursesReview__SubmissionCard
      submissions selectedTab={Filter.tab(filter)} filterString={Filter.toQueryString(filter)}
    />
    {ReactUtils.nullIf(
      <div className="text-center pb-4">
        {submissionsLoadedData(state.totalEntriesCount, Array.length(submissions))}
      </div>,
      ArrayUtils.isEmpty(submissions),
    )}
  </div>

let filterPlaceholder = filter =>
  switch (Filter.levelId(filter), Filter.assignedCoachId(filter)) {
  | (None, Some(_)) => tc("filter_by_level")
  | (None, None) => tc("filter_by_level_or_submissions_assigned")
  | (Some(_), Some(_)) => tc("filter_by_another_level")
  | (Some(_), None) => tc("filter_by_another_level_or_submissions_assigned")
  }

let loadFilters = (send, courseId, state) => {
  if StringUtils.isPresent(state.filterInput) {
    let input = String.lowercase_ascii(state.filterInput)
    if StringUtils.test(tc("search.level"), input) {
      getLevels(send, courseId, state)
    }
    if (
      StringUtils.test(tc("search.assigned_to"), input) ||
      StringUtils.test(tc("search.personal_coach"), input) ||
      StringUtils.test(tc("search.reviewed_by"), input)
    ) {
      getCoaches(send, courseId, state)
    }
    if StringUtils.test(tc("search.target"), input) {
      getTargets(send, courseId, state)
    }
  }
}

let shortCutClasses = selected =>
  "cursor-pointer flex justify-center md:flex-auto rounded-md p-1.5 md:border-b-3 md:rounded-b-none md:border-transparent md:px-4 md:hover:bg-gray-200 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-200 focus:outline-none focus:ring-inset focus:ring-2 focus:bg-gray-200 focus:ring-indigo-500 md:focus:border-b-none md:focus:rounded-t-md " ++ (
    selected
      ? "bg-white shadow md:shadow-none rounded-md md:rounded-none md:bg-transparent md:border-b-3 hover:bg-white md:hover:bg-transparent text-primary-500 md:border-primary-500"
      : ""
  )

let computeInitialState = () => {
  loading: LoadingV2.empty(),
  submissions: Unloaded,
  levels: [],
  coaches: [],
  targets: [],
  filterLoading: false,
  filterInput: "",
  targetsLoaded: Unloaded,
  levelsLoaded: Unloaded,
  coachesLoaded: Unloaded,
  totalEntriesCount: 0,
}

let pageTitle = (courses, courseId) => {
  let currentCourse = ArrayUtils.unsafeFind(
    course => AppRouter__Course.id(course) == courseId,
    "Could not find currentCourse with ID " ++ courseId ++ " in CoursesReview__Root",
    courses,
  )

  `${tc("review")} | ${AppRouter__Course.name(currentCourse)}`
}

@react.component
let make = (~courseId, ~currentCoachId, ~courses) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  let url = RescriptReactRouter.useUrl()
  let filter = Filter.makeFromQueryParams(url.search)

  React.useEffect1(() => {
    reloadSubmissions(courseId, filter, send)
    None
  }, [url])

  React.useEffect1(() => {
    loadFilters(send, courseId, state)
    None
  }, [state.filterInput])

  <>
    <Helmet> <title> {str(pageTitle(courses, courseId))} </title> </Helmet>
    <div role="main" ariaLabel="Review" className="flex-1 flex flex-col">
      <div className="hidden md:block h-16" />
      <div className="course-review-root__submissions-list-container">
        <div className="bg-gray-100">
          <div className="max-w-4xl 2xl:max-w-5xl mx-auto">
            <div
              className="flex items-center justify-between bg-white md:bg-transparent px-4 py-2 md:pt-4 border-b md:border-none">
              <h4 className="font-semibold"> {str(tc("review"))} </h4>
              <div className="block md:hidden"> {submissionsSorter(filter)} </div>
            </div>
            <div className="px-4">
              <div className="flex pt-3 md:border-b border-gray-300">
                <div
                  role="tablist"
                  ariaLabel="Status tabs"
                  className="flex flex-1 md:flex-none p-1 md:p-0 space-x-1 md:space-x-0 text-center rounded-lg justify-between md:justify-start bg-gray-300 md:bg-transparent ">
                  <div role="tab" ariaSelected={filter.tab === None} className="flex-1">
                    <Link
                      href={"/courses/" ++
                      courseId ++
                      "/review?" ++
                      Filter.toQueryString({...filter, tab: None, sortCriterion: #SubmittedAt})}
                      className={shortCutClasses(filter.tab === None)}>
                      <p> {I18n.ts("all")->str} </p>
                    </Link>
                  </div>
                  <div role="tab" ariaSelected={filter.tab === Some(#Pending)} className="flex-1">
                    <Link
                      href={"/courses/" ++
                      courseId ++
                      "/review?" ++
                      Filter.toQueryString({
                        ...filter,
                        tab: Some(#Pending),
                        sortCriterion: #SubmittedAt,
                        sortDirection: #Ascending,
                      })}
                      className={shortCutClasses(filter.tab === Some(#Pending))}>
                      <p> {str(tc("pending"))} </p>
                    </Link>
                  </div>
                  <div role="tab"  ariaSelected={filter.tab === Some(#Reviewed)} className="flex-1">
                    <Link
                      href={"/courses/" ++
                      courseId ++
                      "/review?" ++
                      Filter.toQueryString({
                        ...filter,
                        tab: Some(#Reviewed),
                        sortCriterion: #EvaluatedAt,
                        sortDirection: #Descending,
                      })}
                      className={shortCutClasses(filter.tab === Some(#Reviewed))}>
                      <p> {str(tc("reviewed"))} </p>
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="md:sticky md:top-0 bg-gray-100">
          <div className="max-w-4xl 2xl:max-w-5xl mx-auto">
            <div role="form" className="md:flex w-full items-start pt-4 pb-3 px-4 md:pt-6">
              <div className="flex-1">
                <label htmlFor="filter" className="block text-tiny font-semibold uppercase">
                  {tc("filter_by")->str}
                </label>
                <Multiselect
                  id="filter"
                  unselected={unselected(state, currentCoachId, filter)}
                  selected={selected(state, filter, currentCoachId)}
                  onSelect={onSelectFilter(send, courseId, state, filter)}
                  onDeselect={onDeselectFilter(send, filter)}
                  value=state.filterInput
                  onChange={filterInput => send(UpdateFilterInput(filterInput))}
                  placeholder={filterPlaceholder(filter)}
                  loading={state.filterLoading}
                  defaultOptions={defaultOptions(state, filter)}
                  hint={tc("filter_hint")}
                />
              </div>
              <div className="hidden md:block"> {submissionsSorter(filter)} </div>
            </div>
          </div>
        </div>
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
          <div>
            {switch state.submissions {
            | Unloaded =>
              <div> {SkeletonLoading.multiple(~count=6, ~element=SkeletonLoading.card())} </div>
            | PartiallyLoaded(submissions, cursor) =>
              <div>
                {submissionsList(submissions, state, filter)}
                {switch state.loading {
                | LoadingMore =>
                  <div> {SkeletonLoading.multiple(~count=1, ~element=SkeletonLoading.card())} </div>
                | Reloading(times) =>
                  ReactUtils.nullUnless(
                    <div className="pb-6">
                      <button
                        className="btn btn-primary-ghost cursor-pointer w-full"
                        onClick={_ => {
                          send(BeginLoadingMore)
                          getSubmissions(send, courseId, Some(cursor), filter)
                        }}>
                        {tc("button_load_more")->str}
                      </button>
                    </div>,
                    ArrayUtils.isEmpty(times),
                  )
                }}
              </div>
            | FullyLoaded(submissions) => <div> {submissionsList(submissions, state, filter)} </div>
            }}
          </div>
          {switch state.submissions {
          | Unloaded => React.null
          | _ =>
            let loading = switch state.loading {
            | Reloading(times) => ArrayUtils.isNotEmpty(times)
            | LoadingMore => false
            }
            <LoadingSpinner loading />
          }}
        </div>
      </div>
      // Footer spacer
      <div className="md:hidden h-16" />
    </div>
  </>
}
