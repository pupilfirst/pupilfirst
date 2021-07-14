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
  levels: array<Level.t>,
  coaches: array<Coach.t>,
  targets: array<TargetInfo.t>,
  filter: filter,
  filterString: string,
  totalEntriesCount: int,
  filterLoading: bool,
  filterLoader: option<filterLoader>,
  targetsLoaded: bool,
  levelsLoaded: bool,
  coachesLoaded: bool,
}

type action =
  | SetSearchString(string)
  | UnsetSearchString
  | UpdateFilterString(string)
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
  | ShowPending
  | ShowReviewed
  | ClearStatus
  | SelectCoach(Coach.t)
  | DeselectCoach
  | SelectLevel(Level.t)
  | SelectTarget(TargetInfo.t)
  | SetNameOrEmail(string)
  | UnsetNameOrEmail
  | DeselectTarget
  | DeselectLevel
  | SetFilterLoading
  | ClearFilterLoading
  | SetLoader(filterLoader)
  | ClearLoader
  | UpdateSortDirection(SubmissionsSorting.sortDirection)
  | UpdateSortCriterion(SubmissionsSorting.sortCriterion)
  | ShowAll

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
  | SelectTarget(target) => {
      ...state,
      filter: {...state.filter, target: Some(target)},
      filterString: "",
    }
  | DeselectTarget => {...state, filter: {...state.filter, target: None}}
  | SetFilterLoading => {...state, filterLoading: true}
  | ClearFilterLoading => {...state, filterLoading: false}
  | SetNameOrEmail(search) => {
      ...state,
      filter: {
        ...state.filter,
        nameOrEmail: Some(search),
      },
      filterString: "",
    }
  | UnsetNameOrEmail => {
      ...state,
      filter: {
        ...state.filter,
        nameOrEmail: None,
      },
    }
  | SetLoader(loader) => {
      ...state,
      filterString: switch loader {
      | ShowLevels => "Level: "
      | ShowCoaches => "Assigned to: "
      | ShowTargets => "Target: "
      },
    }
  | ClearLoader => {...state, filterLoader: None}
  | UpdateSortDirection(sortDirection) => {
      ...state,
      filter: {
        ...state.filter,
        sortBy: SubmissionsSorting.updateDirection(sortDirection, state.filter.sortBy),
      },
    }
  | UpdateSortCriterion(updateCriterion) => {
      ...state,
      filter: {
        ...state.filter,
        sortBy: SubmissionsSorting.updateCriterion(updateCriterion, state.filter.sortBy),
      },
    }
  | ShowAll => {...state, filter: {...state.filter, selectedTab: None}}
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
    ~status=?filter.selectedTab,
    ~sortDirection=SubmissionsSorting.sortDirection(filter.sortBy),
    ~sortCriterion=SubmissionsSorting.sortCriterion(filter.sortBy),
    ~levelId=?OptionUtils.map(Level.id, filter.selectedLevel),
    ~coachId=?OptionUtils.map(Coach.id, filter.selectedCoach),
    ~targetId=?OptionUtils.map(TargetInfo.id, filter.target),
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

let submissionsSorter = (filter, send) => {
  let criteria = switch filter.selectedTab {
  | Some(c) =>
    switch c {
    | #Pending => [#SubmittedAt]
    | #Reviewed => [#SubmittedAt, #EvaluatedAt]
    }
  | None => [#SubmittedAt]
  }

  let selectedCriterion = switch filter.selectedTab {
  | Some(c) =>
    switch c {
    | #Pending => #SubmittedAt
    | #Reviewed => #EvaluatedAt
    }
  | None => #SubmittedAt
  }

  <div ariaLabel="Change submissions sorting" className="flex-shrink-0 mt-3 md:mt-0 md:ml-2">
    <label className="block text-tiny font-semibold uppercase"> {tc("sort_by") |> str} </label>
    <SubmissionsSorter
      criteria
      selectedCriterion
      direction={SubmissionsSorting.sortDirection(filter.sortBy)}
      onDirectionChange={sortDirection => send(UpdateSortDirection(sortDirection))}
      onCriterionChange={sortCriterion => send(UpdateSortCriterion(sortCriterion))}
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
      | #Pending => "Filter pending submission"
      | #Reviewed => "Filter reviewed Submission"
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
    state.levels
    |> Js.Array.filter(level =>
      filter.selectedLevel |> OptionUtils.mapWithDefault(
        selectedLevel => level |> Level.id != (selectedLevel |> Level.id),
        true,
      )
    )
    |> Array.map(Selectable.level)

  let unselectedTargets =
    state.targets
    |> Js.Array.filter(target =>
      filter.target |> OptionUtils.mapWithDefault(
        selectedTarget => TargetInfo.id(target) != TargetInfo.id(selectedTarget),
        true,
      )
    )
    |> Array.map(Selectable.target)

  let unselectedCoaches =
    state.coaches
    |> Js.Array.filter(coach =>
      filter.selectedCoach |> OptionUtils.mapWithDefault(
        selectedCoach => coach |> Coach.id != Coach.id(selectedCoach),
        true,
      )
    )
    |> Array.map(coach => Selectable.assignedToCoach(coach, currentCoachId))

  let trimmedFilterString = state.filterString |> String.trim
  let nameOrEmail = trimmedFilterString == "" ? [] : [Selectable.nameOrEmail(trimmedFilterString)]

  ArrayUtils.flattenV2([
    unSelectedStatus(state),
    unselectedLevels,
    unselectedCoaches,
    unselectedTargets,
    nameOrEmail,
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
  | NameOrEmail(nameOrEmail) => send(SetNameOrEmail(nameOrEmail))
  }

let onDeselectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(_) => send(DeselectCoach)
  | Level(_) => send(DeselectLevel)
  | Loader(_) => send(ClearLoader)
  | Target(_) => send(DeselectTarget)
  | Status(_) => send(ClearStatus)
  | NameOrEmail(_) => send(UnsetNameOrEmail)
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
  levels: [],
  coaches: [],
  targets: [],
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
  targetsLoaded: false,
  levelsLoaded: false,
  coachesLoaded: false,
  totalEntriesCount: 0,
}

let reloadSubmissions = (courseId, state, send) => {
  send(BeginReloading)
  getSubmissions(send, courseId, None, state.filter)
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

let shortCutClasses = selected =>
  "cursor-pointer px-2 text primary-500 " ++ (
    selected ? "border-b-3 border-primary-500 font-semibold" : ""
  )

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
  <div className="flex-1 overflow-y-auto">
    <div className="max-w-3xl mx-auto">
      <div className="md:flex w-full items-start py-4">
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
        {submissionsSorter(state.filter, send)}
      </div>
      <div className="flex space-x-4 border-b-3">
        <div
          className={shortCutClasses(state.filter.selectedTab === None)}
          onClick={_ => send(ShowAll)}>
          {str("All")}
        </div>
        <div
          className={shortCutClasses(state.filter.selectedTab === Some(#Pending))}
          onClick={_ => send(ShowPending)}>
          {str("Pending")}
        </div>
        <div
          className={shortCutClasses(state.filter.selectedTab === Some(#Reviewed))}
          onClick={_ => send(ShowReviewed)}>
          {str("Reviewed")}
        </div>
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
  </div>
}
