let str = React.string

open CoursesReview__Types

let tc = I18n.t(~scope="components.CoursesReview__Root")

type selectedTab = [#Reviewed | #Pending]

module Item = {
  type t = IndexSubmission.t
}

module Pagination = Pagination.Make(Item)

type filter = {
  nameOrEmail: option<string>,
  selectedLevel: option<Level.t>,
  selectedCoach: option<Coach.t>,
  tags: Belt.Set.String.t,
  sortBy: SubmissionsSorting.t,
  selectedTab: selectedTab,
  loading: bool,
}

type state = {
  loading: Loading.t,
  submissions: Pagination.t,
  filter: filter,
  filterString: string,
  totalEntriesCount: int,
}

type action =
  | SetSearchString(string)
  | UnsetSearchString
  | UpdateFilterString(string)
  | LoadSubmissions(option<string>, bool, array<IndexSubmission.t>, int)
  | BeginLoadingMore
  | BeginReloading
  | ShowPending
  | ShowReviewed
  | SelectCoach(Coach.t)
  | DeselectCoach
  | SelectLevel(Level.t)
  | DeselectLevel
  | SetFilterLoading
  | ClearFilterLoading

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
    | LoadingMore => Js.Array.concat(Pagination.toArray(state.submissions), newTopics)
    | Reloading => newTopics
    | NotLoading => newTopics
    }

    {
      ...state,
      submissions: Pagination.make(updatedTopics, hasNextPage, endCursor),
      loading: NotLoading,
      totalEntriesCount: totalEntriesCount,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | ShowPending => {...state, filter: {...state.filter, selectedTab: #Pending}}
  | ShowReviewed => {...state, filter: {...state.filter, selectedTab: #Reviewed}}
  | SelectLevel(level) => {
      ...state,
      filter: {...state.filter, selectedLevel: Some(level)},
      filterString: "",
    }
  | DeselectLevel => {...state, filter: {...state.filter, selectedLevel: None}}
  | SelectCoach(coach) => {
      ...state,
      filter: {
        ...state.filter,
        selectedCoach: Some(coach),
      },
      filterString: "",
    }
  | DeselectCoach => {...state, filter: {...state.filter, selectedCoach: None}}
  | SetFilterLoading => {...state, filter: {...state.filter, loading: true}}
  | ClearFilterLoading => {...state, filter: {...state.filter, loading: false}}
  }

module SubmissionsQuery = %graphql(
  `
    query SubmissionsQuery($courseId: ID!, $status: SubmissionStatus!, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $coachId: ID, $after: String) {
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

let getSubmissions = (send, courseId, cursor, filter) => {
  SubmissionsQuery.make(
    ~courseId,
    ~status=filter.selectedTab,
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

module Selectable = {
  type t =
    | Level(Level.t)
    | AssignedToCoach(Coach.t, string)
    | LoadLevels

  let label = t =>
    switch t {
    | Level(level) => Some(LevelLabel.format(level |> Level.number |> string_of_int))
    | AssignedToCoach(_) => Some(tc("assigned_to"))
    | LoadLevels => Some("load_levels")
    }

  let value = t =>
    switch t {
    | Level(level) => level |> Level.name
    | AssignedToCoach(coach, currentCoachId) =>
      coach |> Coach.id == currentCoachId ? tc("me") : coach |> Coach.name
    | LoadLevels => ""
    }

  let searchString = t =>
    switch t {
    | Level(level) =>
      LevelLabel.searchString(level |> Level.number |> string_of_int, level |> Level.name)
    | AssignedToCoach(coach, currentCoachId) =>
      if coach |> Coach.id == currentCoachId {
        (coach |> Coach.name) ++ tc("assigned_to_me")
      } else {
        tc("assigned_to_coach") ++ (coach |> Coach.name)
      }
    | LoadLevels => "Level"
    }

  let color = _t => "gray"
  let level = level => Level(level)
  let assignedToCoach = (coach, currentCoachId) => AssignedToCoach(coach, currentCoachId)
  let makeLevels = () => LoadLevels
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unselected = (levels, coaches, currentCoachId, filter) => {
  let unselectedLevels =
    levels
    |> Js.Array.filter(level =>
      filter.selectedLevel |> OptionUtils.mapWithDefault(
        selectedLevel => level |> Level.id != (selectedLevel |> Level.id),
        true,
      )
    )
    |> Array.map(Selectable.level)

  let unselectedCoaches =
    coaches
    |> Js.Array.filter(coach =>
      filter.selectedCoach |> OptionUtils.mapWithDefault(
        selectedCoach => coach |> Coach.id != Coach.id(selectedCoach),
        true,
      )
    )
    |> Array.map(coach => Selectable.assignedToCoach(coach, currentCoachId))

  unselectedLevels |> Array.append(unselectedCoaches)
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

  selectedLevel |> Array.append(selectedCoach)
}

let onSelectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(coach, _currentCoachId) => send(SelectCoach(coach))
  | Level(level) => send(SelectLevel(level))
  | LoadLevels => ()
  }

let onDeselectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.AssignedToCoach(_) => send(DeselectCoach)
  | Level(_) => send(DeselectLevel)
  | LoadLevels => ()
  }

let defaultOptions = () => [Selectable.makeLevels()]

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
  filterString: "",
  filter: {
    nameOrEmail: None,
    selectedLevel: None,
    selectedCoach: None,
    tags: Belt.Set.String.empty,
    sortBy: SubmissionsSorting.default(),
    selectedTab: #Pending,
    loading: false,
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

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  React.useEffect1(() => {
    reloadSubmissions(courseId, state, send)
    None
  }, [state.filter])

  let url = RescriptReactRouter.useUrl()

  <div className="max-w-3xl mx-auto">
    <div className="md:flex w-full items-start pb-4">
      <div className="flex-1">
        <label className="block text-tiny font-semibold uppercase">
          {tc("filter_by") |> str}
        </label>
        <Multiselect
          id="filter"
          unselected={unselected([], [], "1", state.filter)}
          selected={selected(state.filter, "1")}
          onSelect={onSelectFilter(send)}
          onDeselect={onDeselectFilter(send)}
          value=state.filterString
          onChange={filterString => send(UpdateFilterString(filterString))}
          placeholder={filterPlaceholder(state.filter)}
          loading={state.filter.loading}
          defaultOptions={defaultOptions()}
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
