let str = React.string

open CoursesReview__Types

let t = I18n.t(~scope="components.CoursesReview__Root")

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
          levelId,
          createdAt,
          targetId,
          coachIds,
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
  },
  totalEntriesCount: 0,
}

let reloadSubmissions = (courseId, state, send) => {
  send(BeginReloading)
  getSubmissions(send, courseId, None, state.filter)
}

let submissionsList = (submissions, selectedTab) =>
<CoursesReviewV2__SubmissionCard submissions selectedTab/>



let entriesLoadedData = (totoalNotificationsCount, loadedNotificaionsCount) =>
  <div className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {str(
      totoalNotificationsCount == loadedNotificaionsCount
        ? t(
            ~variables=[("total_notifications", string_of_int(totoalNotificationsCount))],
            "notifications_fully_loaded_text",
          )
        : t(
            ~variables=[
              ("total_notifications", string_of_int(totoalNotificationsCount)),
              ("loaded_notifications_count", string_of_int(loadedNotificaionsCount)),
            ],
            "notifications_partially_loaded_text",
          ),
    )}
  </div>

@react.component
let make = (~courseId) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  React.useEffect1(() => {
    reloadSubmissions(courseId, state, send)
    None
  }, [state.filter])

  let url = RescriptReactRouter.useUrl()

  <div>
    <div id="submissions" className="mt-4">
      {switch state.submissions {
      | Unloaded =>
        <div className="px-2 lg:px-8">
          {SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())}
        </div>
      | PartiallyLoaded(submissions, cursor) =>
        <div>
          {submissionsList(submissions, state.filter.selectedTab)}
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
                {t("button_load_more") |> str}
              </button>
            </div>
          | Reloading => React.null
          }}
        </div>
      | FullyLoaded(submissions) => <div> {submissionsList(submissions, state.filter.selectedTab)} </div>
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
