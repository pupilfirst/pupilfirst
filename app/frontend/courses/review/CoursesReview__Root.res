let str = React.string
%%raw(`import "./CoursesReview__Root.css"`)

open CoursesReview__Types

let tc = I18n.t(~scope="components.CoursesReview__Root")

module Item = {
  type t = IndexSubmission.t
}

module PagedSubmission = Pagination.Make(Item)

type coachFilter = Assigned | Personal | ReviewedBy
type filterLoader = ShowCoaches(coachFilter) | ShowTargets

type loading = Unloaded | Loading | Loaded

type state = {
  loading: LoadingV2.t,
  submissions: PagedSubmission.t,
  coaches: array<Coach.t>,
  targets: array<TargetInfo.t>,
  filterInput: string,
  totalEntriesCount: int,
  filterLoading: bool,
  filterLoader: option<filterLoader>,
  targetsLoaded: loading,
  coachesLoaded: loading,
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | LoadSubmissions(
      option<string>,
      bool,
      array<IndexSubmission.t>,
      int,
      option<TargetInfo.t>,
      array<Coach.t>,
    )
  | LoadCoaches(array<Coach.t>)
  | LoadTargets(array<TargetInfo.t>)
  | BeginLoadingMore
  | BeginReloading
  | SetTargetLoading
  | SetCoachLoading
  | SetLoader(filterLoader)
  | ClearLoader

let coachFilterTranslationKey = coachFilter => {
  switch coachFilter {
  | Assigned => "assigned_to"
  | Personal => "personal_coach"
  | ReviewedBy => "reviewed_by"
  }
}

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput}
  | LoadSubmissions(endCursor, hasNextPage, newTopics, totalEntriesCount, target, coaches) =>
    let updatedTopics = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedSubmission.toArray(state.submissions), newTopics)
    | Reloading(_) => newTopics
    }

    {
      ...state,
      submissions: PagedSubmission.make(updatedTopics, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount,
      targets: ArrayUtils.isEmpty(state.targets)
        ? Belt.Option.mapWithDefault(target, [], t => [t])
        : state.targets,
      coaches: ArrayUtils.isEmpty(state.coaches) ? coaches : state.coaches,
    }
  | LoadCoaches(coaches) => {
      ...state,
      coaches,
      filterLoading: false,
      coachesLoaded: Loaded,
    }
  | LoadTargets(targets) => {
      ...state,
      targets,
      filterLoading: false,
      targetsLoaded: Loaded,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  | SetTargetLoading => {...state, filterLoading: true, targetsLoaded: Loading}
  | SetCoachLoading => {...state, filterLoading: true, coachesLoaded: Loading}
  | SetLoader(loader) => {
      ...state,
      filterInput: switch loader {
      | ShowCoaches(key) => tc(`filter_input.${coachFilterTranslationKey(key)}`)
      | ShowTargets => tc("filter_input.target")
      },
    }
  | ClearLoader => {...state, filterLoader: None}
  }

let updateParams = filter => RescriptReactRouter.push("?" ++ Filter.toQueryString(filter))

module UserProxyFragment = UserProxy.Fragment

module SubmissionsQuery = %graphql(`
    query SubmissionsQuery($courseId: ID!, $search: String, $targetId: ID, $status: SubmissionStatus, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $personalCoachId: ID, $assignedCoachId: ID, $reviewingCoachId: ID, $includeInactive: Boolean, $coachIds: [ID!] $after: String) {
      submissions(courseId: $courseId, search: $search, targetId: $targetId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, personalCoachId: $personalCoachId, assignedCoachId: $assignedCoachId, reviewingCoachId: $reviewingCoachId,  includeInactive: $includeInactive, first: 20, after: $after) {
        nodes {
          id,
          title,
          milestoneNumber,
          userNames,
          evaluatedAt,
          passedAt,
          feedbackSent,
          createdAt,
          teamName,
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
      coaches(coachIds: $coachIds, courseId: $courseId) {
        ...UserProxyFragment
      }
      targetInfo(targetId: $targetId, courseId: $courseId) {
        id
        title
        milestoneNumber
      }
    }
  `)

module CoachesQuery = %graphql(`
    query CoachesQuery($courseId: ID!) {
      coaches(courseId: $courseId) {
        ...UserProxyFragment
      }
    }
  `)

module ReviewedTargetsInfoQuery = %graphql(`
    query ReviewedTargetsInfoQuery($courseId: ID!) {
      reviewedTargetsInfo(courseId: $courseId) {
        id
        title
        milestoneNumber
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

  let variables = SubmissionsQuery.makeVariables(
    ~courseId,
    ~status=?Filter.tab(filter),
    ~sortDirection=Filter.defaultDirection(filter),
    ~sortCriterion=Filter.sortCriterion(filter),
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

  SubmissionsQuery.make(variables)
  |> Js.Promise.then_(response => {
    let target = OptionUtils.map(TargetInfo.makeFromJs, response["targetInfo"])
    let coaches = Js.Array2.map(response["coaches"], Coach.makeFromJs)
    send(
      LoadSubmissions(
        response["submissions"]["pageInfo"]["endCursor"],
        response["submissions"]["pageInfo"]["hasNextPage"],
        Js.Array.map(IndexSubmission.makeFromJS, response["submissions"]["nodes"]),
        response["submissions"]["totalCount"],
        target,
        coaches,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let getCoaches = (send, courseId, state) => {
  if state.coachesLoaded == Unloaded {
    send(SetCoachLoading)

    CoachesQuery.make({courseId: courseId})
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

    ReviewedTargetsInfoQuery.make({courseId: courseId})
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

  <div ariaLabel="Change submissions sorting" className="shrink-0 md:ms-2">
    <label className="hidden md:block text-tiny font-semibold uppercase pb-1">
      {tc("sort_by")->str}
    </label>
    <SubmissionsSorter
      criteria
      selectedCriterion={filter.sortCriterion}
      direction={Filter.defaultDirection(filter)}
      onDirectionChange={direction => {
        updateParams({...filter, sortDirection: Some(direction)})
      }}
      onCriterionChange={sortCriterion => updateParams({...filter, sortCriterion})}
    />
  </div>
}

module Selectable = {
  type t =
    | AssignedToCoach(Coach.t, string)
    | PersonalCoach(Coach.t, string)
    | ReviewedBy(Coach.t, string)
    | Loader(filterLoader)
    | Target(TargetInfo.t)
    | Status(Filter.selectedTab)
    | NameOrEmail(string)
    | IncludeInactive

  let label = t =>
    switch t {
    | AssignedToCoach(_) => Some(tc("assigned_to"))
    | PersonalCoach(_) => Some(tc("personal_coach"))
    | ReviewedBy(_) => Some(tc("reviewed_by"))
    | Target(_) => Some(tc("target"))
    | Loader(l) =>
      switch l {
      | ShowCoaches(key) => Some(tc(coachFilterTranslationKey(key)))
      | ShowTargets => Some(tc("target"))
      }
    | Status(_) => Some(tc("status"))
    | NameOrEmail(_) => Some(tc("name_or_email"))
    | IncludeInactive => Some(tc("include"))
    }

  let value = t =>
    switch t {
    | AssignedToCoach(coach, currentCoachId)
    | ReviewedBy(coach, currentCoachId)
    | PersonalCoach(coach, currentCoachId) =>
      Coach.id(coach) == currentCoachId ? tc("me") : Coach.name(coach)
    | Target(t) => TargetInfo.title(t)
    | Loader(l) =>
      switch l {
      | ShowCoaches(key) => tc(`coach_filter_by.${coachFilterTranslationKey(key)}`)
      | ShowTargets => tc("filter_by_target")
      }
    | Status(t) =>
      switch t {
      | #Pending => tc("pending")
      | #Reviewed => tc("reviewed")
      }
    | NameOrEmail(search) => search
    | IncludeInactive => tc("inactive_students")
    }

  let searchString = t =>
    switch t {
    | AssignedToCoach(coach, currentCoachId) =>
      tc("search.assigned_to") ++
      " " ++ (Coach.id(coach) == currentCoachId ? tc("me") : Coach.name(coach))
    | PersonalCoach(coach, currentCoachId) =>
      tc("search.personal_coach") ++
      " " ++ (Coach.id(coach) == currentCoachId ? tc("me") : Coach.name(coach))
    | ReviewedBy(coach, currentCoachId) =>
      tc("search.reviewed_by") ++
      " " ++ (Coach.id(coach) == currentCoachId ? tc("me") : Coach.name(coach))
    | Target(t) => tc("search.target") ++ " " ++ TargetInfo.title(t)
    | Loader(ShowCoaches(key)) => tc(`search.${coachFilterTranslationKey(key)}`)
    | Loader(ShowTargets) => tc("search.target")
    | Status(#Pending) => tc("search.status") ++ tc("pending")
    | Status(#Reviewed) => tc("search.status") ++ tc("reviewed")
    | NameOrEmail(search) => search
    | IncludeInactive => `${tc("include")}: ${tc("inactive_students")}`
    }

  let color = t =>
    switch t {
    | AssignedToCoach(_) => "purple"
    | PersonalCoach(_) => "green"
    | ReviewedBy(_) => "orange"
    | Target(_) => "red"
    | Loader(ShowCoaches(Assigned)) => "purple"
    | Loader(ShowCoaches(Personal)) => "green"
    | Loader(ShowCoaches(ReviewedBy)) => "orange"
    | Loader(ShowTargets) => "red"
    | Status(#Pending) => "yellow"
    | Status(#Reviewed) => "green"
    | NameOrEmail(_) => "gray"
    | IncludeInactive => "gray"
    }
  let assignedToCoach = (coach, currentCoachId) => AssignedToCoach(coach, currentCoachId)
  let personalCoach = (coach, currentCoachId) => PersonalCoach(coach, currentCoachId)
  let reviewedBy = (coach, currentCoachId) => ReviewedBy(coach, currentCoachId)
  let makeLoader = l => Loader(l)
  let makecoachLoader = key => Loader(ShowCoaches(key))
  let target = target => Target(target)
  let status = status => Status(status)
  let nameOrEmail = search => NameOrEmail(search)
  let includeInactive = () => IncludeInactive
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unSelectedStatus = filter =>
  switch Filter.tab(filter) {
  | Some(s) =>
    switch s {
    | #Pending => [Selectable.status(#Reviewed)]
    | #Reviewed => [Selectable.status(#Pending)]
    }
  | None => [Selectable.status(#Pending), Selectable.status(#Reviewed)]
  }

let nameOrEmailFilter = state => {
  let input = state.filterInput->String.trim
  let firstWord = Js.String2.split(input, " ")[0]
  input == "" || firstWord == tc("search.target") || firstWord == tc("search.assigned_to")
    ? []
    : [Selectable.nameOrEmail(input)]
}

let unselected = (state, currentCoachId, filter) => {
  let unselectedTargets =
    state.targets
    ->Js.Array2.filter(target =>
      OptionUtils.mapWithDefault(
        selectedTarget => TargetInfo.id(target) != selectedTarget,
        true,
        Filter.targetId(filter),
      )
    )
    ->Js.Array2.map(Selectable.target)

  let unselectedCoaches = (getCoachId, getSelectable) =>
    state.coaches
    ->Js.Array2.filter(coach =>
      Belt.Option.mapWithDefault(getCoachId(filter), true, selectedCoach =>
        Coach.id(coach) != selectedCoach
      )
    )
    ->Js.Array2.map(coach => getSelectable(coach, currentCoachId))

  let unselectedAssignedCoaches = unselectedCoaches(
    filter => filter.assignedCoachId,
    Selectable.assignedToCoach,
  )

  let unselectedPersonalCoaches = unselectedCoaches(
    filter => filter.personalCoachId,
    Selectable.personalCoach,
  )

  let unselectedReviewers = unselectedCoaches(
    filter => filter.reviewingCoachId,
    Selectable.reviewedBy,
  )

  ArrayUtils.flattenV2([
    unSelectedStatus(filter),
    unselectedAssignedCoaches,
    unselectedPersonalCoaches,
    unselectedReviewers,
    unselectedTargets,
    state.coachesLoaded == Loaded
      ? []
      : [
          Selectable.makecoachLoader(Assigned),
          Selectable.makecoachLoader(Personal),
          Selectable.makecoachLoader(ReviewedBy),
        ],
    state.targetsLoaded == Loaded ? [] : [Selectable.makeLoader(ShowTargets)],
    nameOrEmailFilter(state),
    Filter.includeInactive(filter) ? [] : [Selectable.includeInactive()],
  ])
}

let selected = (state, filter, currentCoachId) => {
  let selectedTarget = Belt.Option.mapWithDefault(Filter.targetId(filter), [], targetId =>
    Belt.Option.mapWithDefault(
      Js.Array.find(t => TargetInfo.id(t) == targetId, state.targets),
      [],
      t => [Selectable.target(t)],
    )
  )

  let selectedCoaches = (getCoachId, getSelectable) =>
    Belt.Option.mapWithDefault(getCoachId(filter), [], coachId =>
      Belt.Option.mapWithDefault(
        Js.Array.find(c => Coach.id(c) == coachId, state.coaches),
        [],
        c => [getSelectable(c, currentCoachId)],
      )
    )

  let selectedAssiginedCoach = selectedCoaches(
    filter => filter.assignedCoachId,
    Selectable.assignedToCoach,
  )

  let selectedPersonalCoach = selectedCoaches(
    filter => filter.personalCoachId,
    Selectable.personalCoach,
  )

  let selectedReviewer = selectedCoaches(filter => filter.reviewingCoachId, Selectable.reviewedBy)

  let selectedStatus = OptionUtils.mapWithDefault(t => [Selectable.status(t)], [], filter.tab)

  let selectedSearchString = OptionUtils.mapWithDefault(
    nameOrEmail => [Selectable.nameOrEmail(nameOrEmail)],
    [],
    filter.nameOrEmail,
  )

  ArrayUtils.flattenV2([
    selectedStatus,
    selectedAssiginedCoach,
    selectedPersonalCoach,
    selectedReviewer,
    selectedTarget,
    selectedSearchString,
    Filter.includeInactive(filter) ? [Selectable.includeInactive()] : [],
  ])
}

let onSelectFilter = (send, courseId, state, filter, selectable) => {
  switch selectable {
  | Selectable.Loader(_) => ()
  | _ => send(UnsetSearchString)
  }

  switch selectable {
  | Selectable.AssignedToCoach(coach, _currentCoachId) =>
    let tab = switch Filter.tab(filter) {
    | Some(#Reviewed) => Some(#Pending)
    | otherTab => otherTab
    }

    updateParams({
      ...filter,
      assignedCoachId: Some(Coach.id(coach)),
      tab,
      reviewingCoachId: None,
    })
  | PersonalCoach(coach, _currentCoachId) =>
    updateParams({...filter, personalCoachId: Some(Coach.id(coach))})
  | ReviewedBy(coach, _currentCoachId) =>
    updateParams({
      ...filter,
      reviewingCoachId: Some(Coach.id(coach)),
      tab: Some(#Reviewed),
      assignedCoachId: None,
    })
  | Loader(l) => {
      send(SetLoader(l))
      switch l {
      | ShowCoaches(_) => getCoaches(send, courseId, state)
      | ShowTargets => getTargets(send, courseId, state)
      }
    }
  | Target(target) => updateParams({...filter, targetId: Some(TargetInfo.id(target))})
  | Status(status) =>
    switch status {
    | #Pending =>
      updateParams({
        ...filter,
        tab: Some(#Pending),
        sortCriterion: #SubmittedAt,
        reviewingCoachId: None,
      })
    | #Reviewed =>
      updateParams({
        ...filter,
        tab: Some(#Reviewed),
        sortCriterion: #EvaluatedAt,
        assignedCoachId: None,
      })
    }
  | NameOrEmail(nameOrEmail) => updateParams({...filter, nameOrEmail: Some(nameOrEmail)})
  | IncludeInactive => updateParams({...filter, includeInactive: true})
  }
}

let onDeselectFilter = (send, filter, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(_) => updateParams({...filter, assignedCoachId: None})
  | PersonalCoach(_) => updateParams({...filter, personalCoachId: None})
  | ReviewedBy(_) => updateParams({...filter, reviewingCoachId: None})
  | Loader(_) => send(ClearLoader)
  | Target(_) => updateParams({...filter, targetId: None})
  | Status(_) => updateParams({...filter, tab: None, sortCriterion: #SubmittedAt})
  | NameOrEmail(_) => updateParams({...filter, nameOrEmail: None})
  | IncludeInactive => updateParams({...filter, includeInactive: false})
  }

let defaultOptions = (state, filter) => {
  ArrayUtils.flattenV2([
    nameOrEmailFilter(state),
    [
      Selectable.makecoachLoader(Assigned),
      Selectable.makecoachLoader(Personal),
      Selectable.makecoachLoader(ReviewedBy),
      Selectable.makeLoader(ShowTargets),
      Selectable.includeInactive(),
    ],
    unSelectedStatus(filter),
  ])
}

let reloadSubmissions = (courseId, filter, send) => {
  send(BeginReloading)
  getSubmissions(send, courseId, None, filter)
}

let submissionsLoadedData = (totalSubmissionsCount, loadedSubmissionsCount) =>
  <p
    tabIndex=0
    className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
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
  switch Filter.assignedCoachId(filter) {
  | Some(_) => tc("filter_by_submissions_assigned")
  | None => tc("filter_by_submissions_assigned")
  }

let loadFilters = (send, courseId, state) => {
  if StringUtils.isPresent(state.filterInput) {
    let input = String.lowercase_ascii(state.filterInput)
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
  "cursor-pointer flex justify-center md:flex-auto rounded-md p-1.5 md:border-b-3 md:rounded-b-none md:border-transparent md:px-4 md:hover:bg-gray-50 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-50 focus:outline-none focus:ring-inset focus:ring-2 focus:bg-gray-50 focus:ring-focusColor-500 md:focus:border-b-none md:focus:rounded-t-md " ++ (
    selected
      ? "bg-white shadow md:shadow-none rounded-md md:rounded-none md:bg-transparent md:border-b-3 hover:bg-white md:hover:bg-transparent text-primary-500 md:border-primary-500"
      : ""
  )

let computeInitialState = () => {
  loading: LoadingV2.empty(),
  submissions: Unloaded,
  coaches: [],
  targets: [],
  filterLoading: false,
  filterLoader: None,
  filterInput: "",
  targetsLoaded: Unloaded,
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
    <Helmet>
      <title> {str(pageTitle(courses, courseId))} </title>
    </Helmet>
    <div role="main" ariaLabel="Review" className="flex-1 flex flex-col md:pt-18 pb-20 md:pb-4">
      // <div className="hidden md:block h-18" />
      <div className="course-review-root__submissions-list-container">
        <div className="bg-gray-50">
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
                      Filter.toQueryString({
                        ...filter,
                        tab: None,
                        sortCriterion: #SubmittedAt,
                        sortDirection: Filter.sortDirection(filter),
                      })}
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
                        sortDirection: Filter.sortDirection(filter),
                      })}
                      className={shortCutClasses(filter.tab === Some(#Pending))}>
                      <p> {str(tc("pending"))} </p>
                    </Link>
                  </div>
                  <div role="tab" ariaSelected={filter.tab === Some(#Reviewed)} className="flex-1">
                    <Link
                      href={"/courses/" ++
                      courseId ++
                      "/review?" ++
                      Filter.toQueryString({
                        ...filter,
                        tab: Some(#Reviewed),
                        sortCriterion: #EvaluatedAt,
                        sortDirection: Filter.sortDirection(filter),
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
        <div className="md:sticky md:top-0 bg-gray-50">
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
    </div>
  </>
}
