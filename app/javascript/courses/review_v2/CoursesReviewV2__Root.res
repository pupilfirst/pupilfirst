let str = React.string

open CoursesReview__Types

let tc = I18n.t(~scope="components.CoursesReview__Root")

type selectedTab = [#Reviewed | #Pending]

module Item = {
  type t = IndexSubmission.t
}

module PagedSubmission = Pagination.Make(Item)

type filterLoader = ShowLevels | ShowCoaches | ShowTargets

type filter = {
  nameOrEmail: option<string>,
  selectedLevel: option<Level.t>,
  selectedCoach: option<Coach.t>,
  target: option<TargetInfo.t>,
  sortBy: SubmissionsSorting.t,
  selectedTab: option<selectedTab>,
}

type state = {
  loading: Loading.t,
  submissions: PagedSubmission.t,
  levels: option<array<Level.t>>,
  coaches: option<array<Coach.t>>,
  targets: option<array<TargetInfo.t>>,
  filter: filter,
  filterString: string,
  totalEntriesCount: int,
  filterLoading: bool,
  filterLoader: option<filterLoader>,
}

type action =
  | SetSearchString(string)
  | UnsetSearchString
  | UpdateFilterString(string)
  | LoadSubmissions(option<string>, bool, array<IndexSubmission.t>, int)
  | LoadLevels(array<Level.t>)
  | LoadCoaches(array<Coach.t>)
  | LoadTargets(array<TargetInfo.t>)
  | BeginLoadingMore
  | BeginReloading
  | ShowPending
  | ShowReviewed
  | ClearStatus
  | SelectCoach(Coach.t)
  | DeselectCoach
  | SelectLevel(Level.t)
  | SelectTarget(TargetInfo.t)
  | DeselectTarget
  | DeselectLevel
  | SetFilterLoading
  | ClearFilterLoading
  | SetLoader(filterLoader)
  | ClearLoader

let reducer = (state, action) =>
  switch action {
  | SetSearchString(string) => {
      ...state,
      filter: {
        ...state.filter,
        nameOrEmail: Some(string),
      },
      filterString: "",
    }
  | UnsetSearchString => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        nameOrEmail: None,
      },
    }
  | UpdateFilterString(filterString) => {...state, filterString: filterString}
  | LoadSubmissions(endCursor, hasNextPage, newTopics, totalEntriesCount) =>
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
    }
  | LoadLevels(levels) => {
      ...state,
      levels: Some(levels),
      filterLoading: false,
    }
  | LoadCoaches(coaches) => {
      ...state,
      coaches: Some(coaches),
      filterLoading: false,
    }
  | LoadTargets(targets) => {
      ...state,
      targets: Some(targets),
      filterLoading: false,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | ShowPending => {
      ...state,
      filter: {...state.filter, selectedTab: Some(#Pending)},
      filterString: "",
    }
  | ShowReviewed => {
      ...state,
      filter: {...state.filter, selectedTab: Some(#Reviewed)},
      filterString: "",
    }
  | SelectLevel(level) => {
      ...state,
      filter: {...state.filter, selectedLevel: Some(level)},
      filterString: "",
    }
  | DeselectLevel => {...state, filter: {...state.filter, selectedLevel: None}}
  | ClearStatus => {...state, filter: {...state.filter, selectedTab: None}}
  | SelectCoach(coach) => {
      ...state,
      filter: {
        ...state.filter,
        selectedCoach: Some(coach),
      },
      filterString: "",
    }
  | DeselectCoach => {...state, filter: {...state.filter, selectedCoach: None}}
  | SelectTarget(target) => {...state, filter: {...state.filter, target: Some(target)}}
  | DeselectTarget => {...state, filter: {...state.filter, target: None}}
  | SetFilterLoading => {...state, filterLoading: true}
  | ClearFilterLoading => {...state, filterLoading: false}
  | SetLoader(loader) => {
      ...state,
      filterString: switch loader {
      | ShowLevels => "Level: "
      | ShowCoaches => "Assigned to: "
      | ShowTargets => "Target: "
      },
    }
  | ClearLoader => {...state, filterLoader: None}
  }

module SubmissionsQuery = %graphql(
  `
    query SubmissionsQuery($courseId: ID!, $status: SubmissionStatus, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $coachId: ID, $after: String) {
      submissions(courseId: $courseId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, levelId: $levelId, coachId: $coachId, first: 20, after: $after) {
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
        id
        name
        userId
        title
        avatarUrl
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
    ~status=?filter.selectedTab,
    ~sortDirection=SubmissionsSorting.sortDirection(filter.sortBy),
    ~sortCriterion=SubmissionsSorting.sortCriterion(filter.sortBy),
    ~levelId=?OptionUtils.map(Level.id, filter.selectedLevel),
    ~coachId=?OptionUtils.map(Coach.id, filter.selectedCoach),
    ~after=?cursor,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    send(
      LoadSubmissions(
        response["submissions"]["pageInfo"]["endCursor"],
        response["submissions"]["pageInfo"]["hasNextPage"],
        Js.Array.map(IndexSubmission.makeFromJS, response["submissions"]["nodes"]),
        response["submissions"]["totalCount"],
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let getLevels = (send, courseId, state) => {
  if Belt.Option.isNone(state.levels) {
    send(SetFilterLoading)

    LevelsQuery.make(~courseId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      send(LoadLevels(Js.Array.map(Level.makeFromJs, response["levels"])))
      Js.Promise.resolve()
    }) |> ignore
  }
}

let getCoaches = (send, courseId, state) => {
  if Belt.Option.isNone(state.coaches) {
    send(SetFilterLoading)

    TeamCoachesQuery.make(~courseId, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
      send(LoadCoaches(Js.Array.map(Coach.makeFromJs, response["teamCoaches"])))
      Js.Promise.resolve()
    }) |> ignore
  }
}

let getTargets = (send, courseId, state) => {
  if Belt.Option.isNone(state.targets) {
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

module Selectable = {
  type t =
    | Level(Level.t)
    | AssignedToCoach(Coach.t, string)
    | Loader(filterLoader)
    | Target(TargetInfo.t)
    | Status(selectedTab)

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
    | Status(t) => Some("Status")
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
      | #Pending => "Filter pending submission"
      | #Reviewed => "Filter reviewed Submission"
      }
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
    }
  let level = level => Level(level)
  let assignedToCoach = (coach, currentCoachId) => AssignedToCoach(coach, currentCoachId)
  let makeLoader = l => Loader(l)
  let target = target => Target(target)
  let status = status => Status(status)
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unSelectedStatus = state =>
  switch state.filter.selectedTab {
  | Some(s) =>
    switch s {
    | #Pending => [Selectable.status(#Reviewed)]
    | #Reviewed => [Selectable.status(#Pending)]
    }
  | None => [Selectable.status(#Pending), Selectable.status(#Reviewed)]
  }

let unselected = (state, currentCoachId, filter) => {
  let unselectedLevels =
    Belt.Option.getWithDefault(state.levels, [])
    |> Js.Array.filter(level =>
      filter.selectedLevel |> OptionUtils.mapWithDefault(
        selectedLevel => level |> Level.id != (selectedLevel |> Level.id),
        true,
      )
    )
    |> Array.map(Selectable.level)

  let unselectedTargets =
    Belt.Option.getWithDefault(state.targets, [])
    |> Js.Array.filter(target =>
      filter.target |> OptionUtils.mapWithDefault(
        selectedTarget => TargetInfo.id(target) != TargetInfo.id(selectedTarget),
        true,
      )
    )
    |> Array.map(Selectable.target)

  let unselectedCoaches =
    Belt.Option.getWithDefault(state.coaches, [])
    |> Js.Array.filter(coach =>
      filter.selectedCoach |> OptionUtils.mapWithDefault(
        selectedCoach => coach |> Coach.id != Coach.id(selectedCoach),
        true,
      )
    )
    |> Array.map(coach => Selectable.assignedToCoach(coach, currentCoachId))

  ArrayUtils.flattenV2([
    unSelectedStatus(state),
    unselectedLevels,
    unselectedCoaches,
    unselectedTargets,
  ])
}

let selected = (filter, currentCoachId) => {
  let selectedLevel =
    filter.selectedLevel |> OptionUtils.mapWithDefault(
      selectedLevel => [Selectable.level(selectedLevel)],
      [],
    )

  let selectedCoach =
    filter.selectedCoach |> OptionUtils.mapWithDefault(
      selectedCoach => [Selectable.assignedToCoach(selectedCoach, currentCoachId)],
      [],
    )

  let selectedTarget = OptionUtils.mapWithDefault(t => [Selectable.target(t)], [], filter.target)

  let selectedStatus = OptionUtils.mapWithDefault(
    t => [Selectable.status(t)],
    [],
    filter.selectedTab,
  )

  ArrayUtils.flattenV2([selectedStatus, selectedLevel, selectedCoach, selectedTarget])
}

let onSelectFilter = (send, courseId, state, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(coach, _currentCoachId) => send(SelectCoach(coach))
  | Level(level) => send(SelectLevel(level))
  | Loader(l) => {
      send(SetLoader(l))
      switch l {
      | ShowLevels => getLevels(send, courseId, state)
      | ShowCoaches => getCoaches(send, courseId, state)
      | ShowTargets => getTargets(send, courseId, state)
      }
    }
  | Target(target) => send(SelectTarget(target))
  | Status(status) =>
    switch status {
    | #Pending => send(ShowPending)
    | #Reviewed => send(ShowReviewed)
    }
  }

let onDeselectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(_) => send(DeselectCoach)
  | Level(_) => send(DeselectLevel)
  | Loader(_) => send(ClearLoader)
  | Target(_) => send(DeselectTarget)
  | Status(_) => send(ClearStatus)
  }

let defaultOptions = state =>
  Js.Array.concat(
    [
      Selectable.makeLoader(ShowLevels),
      Selectable.makeLoader(ShowCoaches),
      Selectable.makeLoader(ShowTargets),
    ],
    unSelectedStatus(state),
  )

let filterPlaceholder = state =>
  switch (state.selectedLevel, state.selectedCoach) {
  | (None, Some(_)) => tc("filter_by_level")
  | (None, None) => tc("filter_by_level_or_submissions_assigned")
  | (Some(_), Some(_)) => tc("filter_by_another_level")
  | (Some(_), None) => tc("filter_by_another_level_or_submissions_assigned")
  }

let computeInitialState = () => {
  loading: NotLoading,
  submissions: Unloaded,
  levels: None,
  coaches: None,
  targets: None,
  filterLoading: false,
  filterLoader: None,
  filterString: "",
  filter: {
    nameOrEmail: None,
    selectedLevel: None,
    selectedCoach: None,
    target: None,
    sortBy: SubmissionsSorting.default(),
    selectedTab: Some(#Pending),
  },
  totalEntriesCount: 0,
}

let reloadSubmissions = (courseId, state, send) => {
  send(BeginReloading)
  getSubmissions(send, courseId, None, state.filter)
}

let submissionsLoadedData = (totoalNotificationsCount, loadedNotificaionsCount) =>
  <div className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {str(
      totoalNotificationsCount == loadedNotificaionsCount
        ? tc(
            ~variables=[("total_notifications", string_of_int(totoalNotificationsCount))],
            "notifications_fully_loaded_text",
          )
        : tc(
            ~variables=[
              ("total_notifications", string_of_int(totoalNotificationsCount)),
              ("loaded_notifications_count", string_of_int(loadedNotificaionsCount)),
            ],
            "notifications_partially_loaded_text",
          ),
    )}
  </div>

let submissionsList = (submissions, state) =>
  <div>
    <CoursesReviewV2__SubmissionCard submissions selectedTab=state.filter.selectedTab />
    {ReactUtils.nullIf(
      <div className="text-center pb-4">
        {submissionsLoadedData(state.totalEntriesCount, Array.length(submissions))}
      </div>,
      ArrayUtils.isEmpty(submissions),
    )}
  </div>

let filterPlaceholder = filter =>
  switch (filter.selectedLevel, filter.selectedCoach) {
  | (None, Some(_)) => tc("filter_by_level")
  | (None, None) => tc("filter_by_level_or_submissions_assigned")
  | (Some(_), Some(_)) => tc("filter_by_another_level")
  | (Some(_), None) => tc("filter_by_another_level_or_submissions_assigned")
  }

let loadFilters = (send, courseId, state) => {
  if StringUtils.isPresent(state.filterString) {
    if StringUtils.test("level:", String.lowercase_ascii(state.filterString)) {
      getLevels(send, courseId, state)
    }
    if StringUtils.test("assigned to:", String.lowercase_ascii(state.filterString)) {
      getCoaches(send, courseId, state)
    }
    if StringUtils.test("target:", String.lowercase_ascii(state.filterString)) {
      getTargets(send, courseId, state)
    }
  }
}

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  React.useEffect1(() => {
    reloadSubmissions(courseId, state, send)
    None
  }, [state.filter])

  React.useEffect1(() => {
    loadFilters(send, courseId, state)
    None
  }, [state.filterString])

  let url = RescriptReactRouter.useUrl()

  <div className="max-w-3xl mx-auto">
    <div className="md:flex w-full items-start pb-4">
      <div className="flex-1">
        <label className="block text-tiny font-semibold uppercase">
          {tc("filter_by") |> str}
        </label>
        <Multiselect
          id="filter"
          unselected={unselected(state, "1", state.filter)}
          selected={selected(state.filter, "1")}
          onSelect={onSelectFilter(send, courseId, state)}
          onDeselect={onDeselectFilter(send)}
          value=state.filterString
          onChange={filterString => send(UpdateFilterString(filterString))}
          placeholder={filterPlaceholder(state.filter)}
          loading={state.filterLoading}
          defaultOptions={defaultOptions(state)}
        />
      </div>
      // {submissionsSorter(state, send)}
    </div>
    <div>
      <div className="btn btn-default" onClick={_ => send(ShowPending)}> {str("Pending")} </div>
      <div className="btn btn-default" onClick={_ => send(ShowReviewed)}> {str("Reviewed")} </div>
    </div>
    <div id="submissions" className="mt-4">
      {switch state.submissions {
      | Unloaded =>
        <div className="px-2 lg:px-8">
          {SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())}
        </div>
      | PartiallyLoaded(submissions, cursor) =>
        <div>
          {submissionsList(submissions, state)}
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
                  getSubmissions(send, courseId, Some(cursor), state.filter)
                }}>
                {tc("button_load_more") |> str}
              </button>
            </div>
          | Reloading => React.null
          }}
        </div>
      | FullyLoaded(submissions) => <div> {submissionsList(submissions, state)} </div>
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
}
