let str = React.string
%bs.raw(`require("./CoursesReview__Root.css")`)

open CoursesReview__Types

let tc = I18n.t(~scope="components.CoursesReview__Root")

module Item = {
  type t = IndexSubmission.t
}

module PagedSubmission = Pagination.Make(Item)

type filterLoader = ShowLevels | ShowCoaches | ShowTargets

type loading = Unloaded | Loading | Loaded

type state = {
  loading: LoadingV2.t,
  submissions: PagedSubmission.t,
  levels: array<Level.t>,
  coaches: array<Coach.t>,
  targets: array<TargetInfo.t>,
  filterInput: string,
  totalEntriesCount: int,
  filterLoading: bool,
  filterLoader: option<filterLoader>,
  targetsLoaded: loading,
  levelsLoaded: loading,
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
      option<Level.t>,
      option<Coach.t>,
    )
  | LoadLevels(array<Level.t>)
  | LoadCoaches(array<Coach.t>)
  | LoadTargets(array<TargetInfo.t>)
  | BeginLoadingMore
  | BeginReloading
  | SetLevelLoading
  | SetTargetLoading
  | SetCoachLoading
  | SetLoader(filterLoader)
  | ClearLoader

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  | LoadSubmissions(endCursor, hasNextPage, newTopics, totalEntriesCount, target, level, coach) =>
    let updatedTopics = switch state.loading {
    | LoadingMore => Js.Array.concat(PagedSubmission.toArray(state.submissions), newTopics)
    | Reloading(_) => newTopics
    }

    {
      ...state,
      submissions: PagedSubmission.make(updatedTopics, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount: totalEntriesCount,
      targets: ArrayUtils.isEmpty(state.targets)
        ? Belt.Option.mapWithDefault(target, [], t => [t])
        : state.targets,
      levels: ArrayUtils.isEmpty(state.levels)
        ? Belt.Option.mapWithDefault(level, [], t => [t])
        : state.levels,
      coaches: ArrayUtils.isEmpty(state.coaches)
        ? Belt.Option.mapWithDefault(coach, [], t => [t])
        : state.coaches,
    }
  | LoadLevels(levels) => {
      ...state,
      levels: levels,
      filterLoading: false,
      levelsLoaded: Loaded,
    }
  | LoadCoaches(coaches) => {
      ...state,
      coaches: coaches,
      filterLoading: false,
      coachesLoaded: Loaded,
    }
  | LoadTargets(targets) => {
      ...state,
      targets: targets,
      filterLoading: false,
      targetsLoaded: Loaded,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  | SetLevelLoading => {...state, filterLoading: true, levelsLoaded: Loading}
  | SetTargetLoading => {...state, filterLoading: true, targetsLoaded: Loading}
  | SetCoachLoading => {...state, filterLoading: true, coachesLoaded: Loading}
  | SetLoader(loader) => {
      ...state,
      filterInput: switch loader {
      | ShowLevels => "Level: "
      | ShowCoaches => "Assigned to: "
      | ShowTargets => "Target: "
      },
    }
  | ClearLoader => {...state, filterLoader: None}
  }

let updateParams = filter => RescriptReactRouter.push("?" ++ Filter.toQueryString(filter))

module SubmissionsQuery = %graphql(
  `
    query SubmissionsQuery($courseId: ID!, $search: String, $targetId: ID, $status: SubmissionStatus, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $coachId: ID, $after: String) {
      submissions(courseId: $courseId, search: $search, targetId: $targetId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, levelId: $levelId, coachId: $coachId, first: 20, after: $after) {
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
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
      level(levelId: $levelId) {
        id
        name
        number
      }
      coach(coachId: $coachId) {
        ...UserProxy.Fragments.AllFields
      }
      targetInfo(targetId: $targetId) {
        id
        title
      }
    }
  `
)

module LevelsQuery = %graphql(
  `
    query LevelsQuery($courseId: ID!) {
      levels(courseId: $courseId) {
        id
        name
        number
      }
    }
  `
)

module TeamCoachesQuery = %graphql(
  `
    query TeamCoachesQuery($courseId: ID!) {
      teamCoaches(courseId: $courseId) {
        ...UserProxy.Fragments.AllFields
      }
    }
  `
)

module ReviewedTargetsInfoQuery = %graphql(
  `
    query ReviewedTargetsInfoQuery($courseId: ID!) {
      reviewedTargetsInfo(courseId: $courseId) {
        id
        title
      }
    }
  `
)

let getSubmissions = (send, courseId, cursor, filter) => {
  SubmissionsQuery.make(
    ~courseId,
    ~status=?Filter.tab(filter),
    ~sortDirection=Filter.sortDirection(filter),
    ~sortCriterion=Filter.sortCriterion(filter),
    ~levelId=?Filter.levelId(filter),
    ~coachId=?Filter.coachId(filter),
    ~targetId=?Filter.targetId(filter),
    ~search=?Filter.nameOrEmail(filter),
    ~after=?cursor,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let target = OptionUtils.map(TargetInfo.makeFromJs, response["targetInfo"])
    let coach = OptionUtils.map(Coach.makeFromJs, response["coach"])
    let level = OptionUtils.map(Level.makeFromJs, response["level"])
    send(
      LoadSubmissions(
        response["submissions"]["pageInfo"]["endCursor"],
        response["submissions"]["pageInfo"]["hasNextPage"],
        Js.Array.map(IndexSubmission.makeFromJS, response["submissions"]["nodes"]),
        response["submissions"]["totalCount"],
        target,
        level,
        coach,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let getLevels = (send, courseId, state) => {
  if state.levelsLoaded == Unloaded {
    send(SetLevelLoading)

    LevelsQuery.make(~courseId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      send(LoadLevels(Js.Array.map(Level.makeFromJs, response["levels"])))
      Js.Promise.resolve()
    }) |> ignore
  }
}

let getCoaches = (send, courseId, state) => {
  if state.coachesLoaded == Unloaded {
    send(SetCoachLoading)

    TeamCoachesQuery.make(~courseId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      send(LoadCoaches(Js.Array.map(Coach.makeFromJs, response["teamCoaches"])))
      Js.Promise.resolve()
    }) |> ignore
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

module Selectable = {
  type t =
    | Level(Level.t)
    | AssignedToCoach(Coach.t, string)
    | Loader(filterLoader)
    | Target(TargetInfo.t)
    | Status(Filter.selectedTab)
    | NameOrEmail(string)

  let label = t =>
    switch t {
    | Level(_) => Some(tc("level"))
    | AssignedToCoach(_) => Some(tc("assigned_to"))
    | Target(_) => Some(tc("target"))
    | Loader(l) =>
      switch l {
      | ShowLevels => Some(tc("level"))
      | ShowCoaches => Some(tc("assigned_to"))
      | ShowTargets => Some(tc("target"))
      }
    | Status(_) => Some(tc("status"))
    | NameOrEmail(_) => Some(tc("name_or_email"))
    }

  let value = t =>
    switch t {
    | Level(level) => string_of_int(Level.number(level)) ++ ", " ++ Level.name(level)
    | AssignedToCoach(coach, currentCoachId) =>
      Coach.id(coach) == currentCoachId ? tc("me") : Coach.name(coach)
    | Target(t) => TargetInfo.title(t)
    | Loader(l) =>
      switch l {
      | ShowLevels => tc("filter_by_level")
      | ShowCoaches => tc("filter_by_assigned_to")
      | ShowTargets => tc("filter_by_target")
      }
    | Status(t) =>
      switch t {
      | #Pending => tc("pending")
      | #Reviewed => tc("reviewed")
      }
    | NameOrEmail(search) => search
    }

  let searchString = t =>
    switch t {
    | Level(level) =>
      tc("search.level") ++ " " ++ string_of_int(Level.number(level)) ++ ", " ++ Level.name(level)
    | AssignedToCoach(coach, currentCoachId) =>
      tc("search.assigned_to") ++
      " " ++ (Coach.id(coach) == currentCoachId ? tc("me") : Coach.name(coach))
    | Target(t) => tc("search.target") ++ " " ++ TargetInfo.title(t)
    | Loader(l) =>
      switch l {
      | ShowLevels => tc("search.level")
      | ShowCoaches => tc("search.assigned_to")
      | ShowTargets => tc("search.target")
      }
    | Status(t) =>
      tc("search.status") ++
      switch t {
      | #Pending => tc("pending")
      | #Reviewed => tc("reviewed")
      }
    | NameOrEmail(search) => search
    }

  let color = t =>
    switch t {
    | Level(_) => "blue"
    | AssignedToCoach(_) => "purple"
    | Target(_) => "red"
    | Loader(l) =>
      switch l {
      | ShowLevels => "blue"
      | ShowCoaches => "purple"
      | ShowTargets => "red"
      }
    | Status(t) =>
      switch t {
      | #Pending => "yellow"
      | #Reviewed => "green"
      }
    | NameOrEmail(_) => "gray"
    }
  let level = level => Level(level)
  let assignedToCoach = (coach, currentCoachId) => AssignedToCoach(coach, currentCoachId)
  let makeLoader = l => Loader(l)
  let target = target => Target(target)
  let status = status => Status(status)
  let nameOrEmail = search => NameOrEmail(search)
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

  input == "" ||
  firstWord == tc("search.level") ||
  firstWord == tc("search.target") ||
  firstWord == tc("search.assigned_to")
    ? []
    : [Selectable.nameOrEmail(input)]
}

let unselected = (state, currentCoachId, filter) => {
  let unselectedLevels =
    state.levels
    ->Js.Array2.filter(level =>
      OptionUtils.mapWithDefault(
        selectedLevel => Level.id(level) != selectedLevel,
        true,
        Filter.levelId(filter),
      )
    )
    ->Js.Array2.map(Selectable.level)

  let unselectedTargets =
    state.targets
    ->Js.Array2.filter(target =>
      OptionUtils.mapWithDefault(
        selectedTarget => TargetInfo.id(target) != selectedTarget,
        true,
        filter.targetId,
      )
    )
    ->Js.Array2.map(Selectable.target)

  let unselectedCoaches =
    state.coaches
    ->Js.Array2.filter(coach =>
      OptionUtils.mapWithDefault(
        selectedCoach => Coach.id(coach) != selectedCoach,
        true,
        filter.coachId,
      )
    )
    ->Js.Array2.map(coach => Selectable.assignedToCoach(coach, currentCoachId))

  ArrayUtils.flattenV2([
    unSelectedStatus(filter),
    unselectedLevels,
    unselectedCoaches,
    unselectedTargets,
    state.levelsLoaded == Loaded ? [] : [Selectable.makeLoader(ShowLevels)],
    state.coachesLoaded == Loaded ? [] : [Selectable.makeLoader(ShowCoaches)],
    state.targetsLoaded == Loaded ? [] : [Selectable.makeLoader(ShowTargets)],
    nameOrEmailFilter(state),
  ])
}

let selected = (state, filter, currentCoachId) => {
  let selectedLevel = Belt.Option.mapWithDefault(Filter.levelId(filter), [], levelId =>
    Belt.Option.mapWithDefault(Js.Array.find(l => Level.id(l) == levelId, state.levels), [], l => [
      Selectable.level(l),
    ])
  )

  let selectedTarget = Belt.Option.mapWithDefault(filter.targetId, [], targetId =>
    Belt.Option.mapWithDefault(
      Js.Array.find(t => TargetInfo.id(t) == targetId, state.targets),
      [],
      t => [Selectable.target(t)],
    )
  )
  let selectedCoach = Belt.Option.mapWithDefault(filter.coachId, [], coachId =>
    Belt.Option.mapWithDefault(Js.Array.find(c => Coach.id(c) == coachId, state.coaches), [], c => [
      Selectable.assignedToCoach(c, currentCoachId),
    ])
  )

  let selectedStatus = OptionUtils.mapWithDefault(t => [Selectable.status(t)], [], filter.tab)

  let selectedSearchString = OptionUtils.mapWithDefault(
    nameOrEmail => [Selectable.nameOrEmail(nameOrEmail)],
    [],
    filter.nameOrEmail,
  )

  ArrayUtils.flattenV2([
    selectedStatus,
    selectedLevel,
    selectedCoach,
    selectedTarget,
    selectedSearchString,
  ])
}

let onSelectFilter = (send, courseId, state, filter, selectable) => {
  switch selectable {
  | Selectable.Loader(_) => ()
  | _ => send(UnsetSearchString)
  }
  switch selectable {
  | Selectable.AssignedToCoach(coach, _currentCoachId) =>
    updateParams({...filter, coachId: Some(Coach.id(coach))})
  | Level(level) => updateParams({...filter, levelId: Some(Level.id(level))})
  | Loader(l) => {
      send(SetLoader(l))
      switch l {
      | ShowLevels => getLevels(send, courseId, state)
      | ShowCoaches => getCoaches(send, courseId, state)
      | ShowTargets => getTargets(send, courseId, state)
      }
    }
  | Target(target) => updateParams({...filter, targetId: Some(TargetInfo.id(target))})
  | Status(status) =>
    switch status {
    | #Pending => updateParams({...filter, tab: Some(#Pending), sortCriterion: #SubmittedAt})
    | #Reviewed => updateParams({...filter, tab: Some(#Reviewed), sortCriterion: #EvaluatedAt})
    }
  | NameOrEmail(nameOrEmail) => updateParams({...filter, nameOrEmail: Some(nameOrEmail)})
  }
}

let onDeselectFilter = (send, filter, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(_) => updateParams({...filter, coachId: None})
  | Level(_) => updateParams({...filter, levelId: None})
  | Loader(_) => send(ClearLoader)
  | Target(_) => updateParams({...filter, targetId: None})
  | Status(_) => updateParams({...filter, tab: None, sortCriterion: #SubmittedAt})
  | NameOrEmail(_) => updateParams({...filter, nameOrEmail: None})
  }

let defaultOptions = (state, filter) => {
  ArrayUtils.flattenV2([
    nameOrEmailFilter(state),
    [
      Selectable.makeLoader(ShowLevels),
      Selectable.makeLoader(ShowCoaches),
      Selectable.makeLoader(ShowTargets),
    ],
    unSelectedStatus(filter),
  ])
}

let reloadSubmissions = (courseId, filter, send) => {
  send(BeginReloading)
  getSubmissions(send, courseId, None, filter)
}

let submissionsLoadedData = (totalSubmissionsCount, loadedSubmissionsCount) =>
  <div className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
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
  </div>

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
  switch (Filter.levelId(filter), Filter.coachId(filter)) {
  | (None, Some(_)) => tc("filter_by_level")
  | (None, None) => tc("filter_by_level_or_submissions_assigned")
  | (Some(_), Some(_)) => tc("filter_by_another_level")
  | (Some(_), None) => tc("filter_by_another_level_or_submissions_assigned")
  }

let loadFilters = (send, courseId, state) => {
  if StringUtils.isPresent(state.filterInput) {
    if StringUtils.test(tc("search.level"), String.lowercase_ascii(state.filterInput)) {
      getLevels(send, courseId, state)
    }
    if StringUtils.test(tc("search.assigned_to"), String.lowercase_ascii(state.filterInput)) {
      getCoaches(send, courseId, state)
    }
    if StringUtils.test(tc("search.target"), String.lowercase_ascii(state.filterInput)) {
      getTargets(send, courseId, state)
    }
  }
}

let shortCutClasses = selected =>
  "cursor-pointer flex-1 md:flex-auto rounded-md md:rounded-t-md p-1.5 md:px-4 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-400 md:hover:bg-gray-200 " ++ (
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
  filterLoader: None,
  filterInput: "",
  targetsLoaded: Unloaded,
  levelsLoaded: Unloaded,
  coachesLoaded: Unloaded,
  totalEntriesCount: 0,
}

@react.component
let make = (~courseId, ~currentCoachId) => {
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

  <div className="flex-1 flex flex-col">
    <div className="hidden md:block h-16" />
    <div className="course-review-root__submissions-list-container">
      <div className="bg-gray-100">
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto">
          <div
            className="flex items-center justify-between bg-white md:bg-transparent px-4 py-2 md:pt-4 border-b md:border-none">
            <p className="font-semibold"> {str(tc("review"))} </p>
            <div className="block md:hidden"> {submissionsSorter(filter)} </div>
          </div>
          <div className="px-4">
            <div className="flex pt-3 md:border-b border-gray-300">
              <div
                className="flex flex-1 md:flex-none p-1 md:p-0 space-x-1 md:space-x-0 text-center rounded-lg justify-between md:justify-start bg-gray-300 md:bg-transparent ">
                <Link
                  href={"/courses/" ++
                  courseId ++
                  "/review?" ++
                  Filter.toQueryString({...filter, tab: None, sortCriterion: #SubmittedAt})}
                  className={shortCutClasses(filter.tab === None)}>
                  <div> {str("All")} </div>
                </Link>
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
                  <div> {str(tc("pending"))} </div>
                </Link>
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
                  <div> {str(tc("reviewed"))} </div>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="md:sticky md:top-0 bg-gray-100">
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto">
          <div className="md:flex w-full items-start pt-4 px-4 md:pt-6">
            <div className="flex-1">
              <label className="block text-tiny font-semibold uppercase">
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
        <div className="mt-4">
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
}
