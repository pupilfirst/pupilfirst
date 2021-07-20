let str = React.string

open CoursesReview__Types

let tc = I18n.t(~scope="components.CoursesReview__Root")

type selectedTab = [#Reviewed | #Pending]
type sortDirection = [#Ascending | #Descending]
type sortCriterion = [#EvaluatedAt | #SubmittedAt]

module Item = {
  type t = IndexSubmission.t
}

module PagedSubmission = Pagination.Make(Item)

type filterLoader = ShowLevels | ShowCoaches | ShowTargets

type filter = {
  nameOrEmail: option<string>,
  levelId: option<string>,
  coachId: option<string>,
  targetId: option<string>,
  sortCriterion: sortCriterion,
  sortDirection: sortDirection,
  tab: option<selectedTab>,
}

type state = {
  loading: Loading.t,
  submissions: PagedSubmission.t,
  levels: array<Level.t>,
  coaches: array<Coach.t>,
  targets: array<TargetInfo.t>,
  filterInput: string,
  totalEntriesCount: int,
  filterLoading: bool,
  filterLoader: option<filterLoader>,
  targetsLoaded: bool,
  levelsLoaded: bool,
  coachesLoaded: bool,
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
  | SetFilterLoading
  | ClearFilterLoading
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
    | Reloading => newTopics
    | NotLoading => newTopics
    }

    {
      ...state,
      submissions: PagedSubmission.make(updatedTopics, hasNextPage, endCursor),
      loading: NotLoading,
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
      levelsLoaded: true,
    }
  | LoadCoaches(coaches) => {
      ...state,
      coaches: coaches,
      filterLoading: false,
      coachesLoaded: true,
    }
  | LoadTargets(targets) => {
      ...state,
      targets: targets,
      filterLoading: false,
      targetsLoaded: true,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | SetFilterLoading => {...state, filterLoading: true}
  | ClearFilterLoading => {...state, filterLoading: false}
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

let filterToQueryString = filter => {
  let sortCriterion = switch filter.sortCriterion {
  | #EvaluatedAt => "EvaluatedAt"
  | #SubmittedAt => "SubmittedAt"
  }

  let sortDirection = switch filter.sortDirection {
  | #Descending => "Descending"
  | #Ascending => "Ascending"
  }

  let filterDict = Js.Dict.fromArray([
    ("sortCriterion", sortCriterion),
    ("sortDirection", sortDirection),
  ])

  Belt.Option.forEach(filter.nameOrEmail, search => Js.Dict.set(filterDict, "search", search))
  Belt.Option.forEach(filter.targetId, targetId => Js.Dict.set(filterDict, "targetId", targetId))
  Belt.Option.forEach(filter.levelId, levelId => Js.Dict.set(filterDict, "levelId", levelId))
  Belt.Option.forEach(filter.coachId, coachId => Js.Dict.set(filterDict, "coachId", coachId))

  switch filter.tab {
  | Some(tab) =>
    switch tab {
    | #Pending => Js.Dict.set(filterDict, "tab", "Pending")
    | #Reviewed => Js.Dict.set(filterDict, "tab", "Reviewed")
    }
  | None => ()
  }

  open Webapi.Url
  URLSearchParams.makeWithDict(filterDict)->URLSearchParams.toString
}

let updateParams = filter => RescriptReactRouter.push("?" ++ filterToQueryString(filter))

let filterFromQueryParams = search => {
  let params = Webapi.Url.URLSearchParams.make(search)

  open Webapi.Url.URLSearchParams
  {
    nameOrEmail: get("search", params),
    levelId: get("levelId", params),
    coachId: get("coachId", params),
    targetId: get("targetId", params),
    tab: switch get("tab", params) {
    | Some(t) when t == "Pending" => Some(#Pending)
    | Some(t) when t == "Reviewed" => Some(#Reviewed)
    | _ => None
    },
    sortCriterion: switch get("sortCriterion", params) {
    | Some(criterion) when criterion == "EvaluatedAt" => #EvaluatedAt
    | Some(criterion) when criterion == "SubmittedAt" => #SubmittedAt
    | _ => #SubmittedAt
    },
    sortDirection: switch get("sortDirection", params) {
    | Some(direction) when direction == "Descending" => #Descending
    | Some(direction) when direction == "Ascending" => #Ascending
    | _ => #Descending
    },
  }
}

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
    query LevelsQuery($search: String, $courseId: ID!) {
      levels(search: $search, courseId: $courseId) {
        id
        name
        number
      }
    }
  `
)

module TeamCoachesQuery = %graphql(
  `
    query TeamCoachesQuery($search: String, $courseId: ID!) {
      teamCoaches(search: $search, courseId: $courseId) {
        ...UserProxy.Fragments.AllFields
      }
    }
  `
)

module ReviewedTargetsInfoQuery = %graphql(
  `
    query ReviewedTargetsInfoQuery($search: String, $courseId: ID!) {
      reviewedTargetsInfo(search: $search, courseId: $courseId) {
        id
        title
      }
    }
  `
)

let getSubmissions = (send, courseId, cursor, filter) => {
  SubmissionsQuery.make(
    ~courseId,
    ~status=?filter.tab,
    ~sortDirection=filter.sortDirection,
    ~sortCriterion=filter.sortCriterion,
    ~levelId=?filter.levelId,
    ~coachId=?filter.coachId,
    ~targetId=?filter.targetId,
    ~search=?filter.nameOrEmail,
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
  if !state.levelsLoaded {
    send(SetFilterLoading)

    LevelsQuery.make(~courseId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      send(LoadLevels(Js.Array.map(Level.makeFromJs, response["levels"])))
      Js.Promise.resolve()
    }) |> ignore
  }
}

let getCoaches = (send, courseId, state) => {
  if !state.coachesLoaded {
    send(SetFilterLoading)

    TeamCoachesQuery.make(~courseId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      send(LoadCoaches(Js.Array.map(Coach.makeFromJs, response["teamCoaches"])))
      Js.Promise.resolve()
    }) |> ignore
  }
}

let getTargets = (send, courseId, state) => {
  if !state.targetsLoaded {
    send(SetFilterLoading)

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
  let criteria = switch filter.tab {
  | Some(c) =>
    switch c {
    | #Pending => [#SubmittedAt]
    | #Reviewed => [#SubmittedAt, #EvaluatedAt]
    }
  | None => [#SubmittedAt]
  }

  <div ariaLabel="Change submissions sorting" className="flex-shrink-0 mt-3 md:mt-0 md:ml-2">
    <label className="block text-tiny font-semibold uppercase"> {tc("sort_by") |> str} </label>
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
    | Status(selectedTab)
    | NameOrEmail(string)

  let label = t =>
    switch t {
    | Level(_) => Some("Level")
    | AssignedToCoach(_) => Some(tc("assigned_to"))
    | Target(_) => Some("Target")
    | Loader(l) =>
      switch l {
      | ShowLevels => Some("Level")
      | ShowCoaches => Some("Assigned To")
      | ShowTargets => Some("Target")
      }
    | Status(_) => Some("Status")
    | NameOrEmail(_) => Some("Name or Email")
    }

  let value = t =>
    switch t {
    | Level(level) => string_of_int(Level.number(level)) ++ ", " ++ Level.name(level)
    | AssignedToCoach(coach, currentCoachId) =>
      coach |> Coach.id == currentCoachId ? tc("me") : coach |> Coach.name
    | Target(t) => TargetInfo.title(t)
    | Loader(l) =>
      switch l {
      | ShowLevels => "Filter by level"
      | ShowCoaches => "Fillter by assigned to"
      | ShowTargets => "Filter by target"
      }
    | Status(t) =>
      switch t {
      | #Pending => "Pending"
      | #Reviewed => "Reviewed"
      }
    | NameOrEmail(search) => search
    }

  let searchString = t =>
    switch t {
    | Level(level) => "level: " ++ string_of_int(Level.number(level)) ++ ", " ++ Level.name(level)
    | AssignedToCoach(coach, currentCoachId) =>
      if coach |> Coach.id == currentCoachId {
        "assigned to: " ++ tc("me")
      } else {
        "assigned to: " ++ (coach |> Coach.name)
      }
    | Target(t) => "target: " ++ TargetInfo.title(t)
    | Loader(_) => ""
    | Status(t) =>
      "status: " ++
      switch t {
      | #Pending => "Pending"
      | #Reviewed => "Reviewed"
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
  switch filter.tab {
  | Some(s) =>
    switch s {
    | #Pending => [Selectable.status(#Reviewed)]
    | #Reviewed => [Selectable.status(#Pending)]
    }
  | None => [Selectable.status(#Pending), Selectable.status(#Reviewed)]
  }

let unselected = (state, currentCoachId, filter) => {
  let unselectedLevels =
    state.levels
    |> Js.Array.filter(level =>
      filter.levelId |> OptionUtils.mapWithDefault(
        selectedLevel => level |> Level.id != selectedLevel,
        true,
      )
    )
    |> Array.map(Selectable.level)

  let unselectedTargets =
    state.targets
    |> Js.Array.filter(target =>
      filter.targetId |> OptionUtils.mapWithDefault(
        selectedTarget => TargetInfo.id(target) != selectedTarget,
        true,
      )
    )
    |> Array.map(Selectable.target)

  let unselectedCoaches =
    state.coaches
    |> Js.Array.filter(coach =>
      filter.coachId |> OptionUtils.mapWithDefault(
        selectedCoach => coach |> Coach.id != selectedCoach,
        true,
      )
    )
    |> Array.map(coach => Selectable.assignedToCoach(coach, currentCoachId))

  ArrayUtils.flattenV2([
    unSelectedStatus(filter),
    unselectedLevels,
    unselectedCoaches,
    unselectedTargets,
  ])
}

let selected = (state, filter, currentCoachId) => {
  let selectedLevel = Belt.Option.mapWithDefault(filter.levelId, [], levelId =>
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
  let trimmedFilterInput = state.filterInput->String.trim
  let nameOrEmail = trimmedFilterInput == "" ? [] : [Selectable.nameOrEmail(trimmedFilterInput)]

  ArrayUtils.flattenV2([
    nameOrEmail,
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

let submissionsLoadedData = (totoalSubmissionsCount, loadedSubmissionsCount) =>
  <div className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {str(
      totoalSubmissionsCount == loadedSubmissionsCount
        ? tc(
            ~variables=[("total_submissions", string_of_int(totoalSubmissionsCount))],
            "submissions_fully_loaded_text",
          )
        : tc(
            ~variables=[
              ("total_submissions", string_of_int(totoalSubmissionsCount)),
              ("loaded_submissions_count", string_of_int(loadedSubmissionsCount)),
            ],
            "submissions_partially_loaded_text",
          ),
    )}
  </div>

let submissionsList = (submissions, state, filter) =>
  <div>
    <CoursesReviewV2__SubmissionCard
      submissions selectedTab=filter.tab filterString={filterToQueryString(filter)}
    />
    {ReactUtils.nullIf(
      <div className="text-center pb-4">
        {submissionsLoadedData(state.totalEntriesCount, Array.length(submissions))}
      </div>,
      ArrayUtils.isEmpty(submissions),
    )}
  </div>

let filterPlaceholder = filter =>
  switch (filter.levelId, filter.coachId) {
  | (None, Some(_)) => tc("filter_by_level")
  | (None, None) => tc("filter_by_level_or_submissions_assigned")
  | (Some(_), Some(_)) => tc("filter_by_another_level")
  | (Some(_), None) => tc("filter_by_another_level_or_submissions_assigned")
  }

let loadFilters = (send, courseId, state) => {
  if StringUtils.isPresent(state.filterInput) {
    if StringUtils.test("level:", String.lowercase_ascii(state.filterInput)) {
      getLevels(send, courseId, state)
    }
    if StringUtils.test("assigned to:", String.lowercase_ascii(state.filterInput)) {
      getCoaches(send, courseId, state)
    }
    if StringUtils.test("target:", String.lowercase_ascii(state.filterInput)) {
      getTargets(send, courseId, state)
    }
  }
}

let shortCutClasses = selected =>
  "cursor-pointer rounded-t-md px-4 py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-200 " ++ (
    selected ? "border-b-3 text-primary-500 border-primary-500" : ""
  )

let computeInitialState = () => {
  loading: NotLoading,
  submissions: Unloaded,
  levels: [],
  coaches: [],
  targets: [],
  filterLoading: false,
  filterLoader: None,
  filterInput: "",
  targetsLoaded: false,
  levelsLoaded: false,
  coachesLoaded: false,
  totalEntriesCount: 0,
}

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  let url = RescriptReactRouter.useUrl()
  let filter = filterFromQueryParams(url.search)

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
    <div className="flex-1 md:overflow-y-auto">
      <div className="sticky top-0 z-20 md:static bg-gray-100">
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
          <div className="flex md:pt-3 border-b">
            <Link
              href={"/courses/" ++
              courseId ++
              "/review?" ++
              filterToQueryString({...filter, tab: None, sortCriterion: #SubmittedAt})}
              className={shortCutClasses(filter.tab === None)}>
              <div> {str("All")} </div>
            </Link>
            <Link
              href={"/courses/" ++
              courseId ++
              "/review?" ++
              filterToQueryString({...filter, tab: Some(#Pending), sortCriterion: #SubmittedAt})}
              className={shortCutClasses(filter.tab === Some(#Pending))}>
              <div> {str("Pending")} </div>
            </Link>
            <Link
              href={"/courses/" ++
              courseId ++
              "/review?" ++
              filterToQueryString({...filter, tab: Some(#Reviewed), sortCriterion: #EvaluatedAt})}
              className={shortCutClasses(filter.tab === Some(#Reviewed))}>
              <div> {str("Reviewed")} </div>
            </Link>
          </div>
        </div>
      </div>
      <div className="md:sticky md:top-0 bg-gray-100">
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto">
          <div className="md:flex w-full items-start py-3 px-4 md:py-4">
            <div className="flex-1">
              <label className="block text-tiny font-semibold uppercase">
                {tc("filter_by")->str}
              </label>
              <Multiselect
                id="filter"
                unselected={unselected(state, "1", filter)}
                selected={selected(state, filter, "1")}
                onSelect={onSelectFilter(send, courseId, state, filter)}
                onDeselect={onDeselectFilter(send, filter)}
                value=state.filterInput
                onChange={filterInput => send(UpdateFilterInput(filterInput))}
                placeholder={filterPlaceholder(filter)}
                loading={state.filterLoading}
                defaultOptions={defaultOptions(state, filter)}
              />
            </div>
            {submissionsSorter(filter)}
          </div>
        </div>
      </div>
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
        <div id="submissions" className="mt-4">
          {switch state.submissions {
          | Unloaded =>
            <div> {SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())} </div>
          | PartiallyLoaded(submissions, cursor) =>
            <div>
              {submissionsList(submissions, state, filter)}
              {switch state.loading {
              | LoadingMore =>
                <div> {SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())} </div>
              | NotLoading =>
                <div className="px-4 lg:px-8 pb-6">
                  <button
                    className="btn btn-primary-ghost cursor-pointer w-full"
                    onClick={_ => {
                      send(BeginLoadingMore)
                      getSubmissions(send, courseId, Some(cursor), filter)
                    }}>
                    {tc("button_load_more") |> str}
                  </button>
                </div>
              | Reloading => React.null
              }}
            </div>
          | FullyLoaded(submissions) => <div> {submissionsList(submissions, state, filter)} </div>
          }}
        </div>
        {switch state.submissions {
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
    // Footer spacer
    <div className="md:hidden h-16" />
  </div>
}
