let str = React.string

type cohortDetails = {
  id: string,
  name: string,
  description: option<string>,
  endsAt: option<Js.Date.t>,
  studentsCount: int,
  coachesCount: int,
}

module Item = {
  type t = cohortDetails
}

module PagedCohorts = Pagination.Make(Item)

type state = {
  loading: LoadingV2.t,
  cohorts: PagedCohorts.t,
  filterInput: string,
  totalEntriesCount: int,
  filterLoading: bool,
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | LoadCohorts(option<string>, bool, array<cohortDetails>, int)
  | BeginLoadingMore
  | BeginReloading

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  | LoadCohorts(endCursor, hasNextPage, students, totalEntriesCount) =>
    let updatedStudent = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedCohorts.toArray(state.cohorts), students)
    | Reloading(_) => students
    }

    {
      ...state,
      cohorts: PagedCohorts.make(updatedStudent, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount: totalEntriesCount,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  }

module CourseCohortsQuery = %graphql(`
    query CourseCohortsQuery($courseId: ID!, $filterString: String, $after: String) {
      cohorts(courseId: $courseId, filterString: $filterString, first: 20, after: $after) {
        nodes {
          id
          name
          description
          endsAt
          studentsCount
          coachesCount
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
    }
  `)

let getCohorts = (send, courseId, cursor, params) => {
  let filterString = Webapi.Url.URLSearchParams.toString(params)
  CourseCohortsQuery.makeVariables(~courseId, ~after=?cursor, ~filterString=?Some(filterString), ())
  |> CourseCohortsQuery.fetch
  |> Js.Promise.then_((response: CourseCohortsQuery.t) => {
    send(
      LoadCohorts(
        response.cohorts.pageInfo.endCursor,
        response.cohorts.pageInfo.hasNextPage,
        response.cohorts.nodes->Js.Array2.map(c => {
          id: c.id,
          name: c.name,
          description: c.description,
          endsAt: c.endsAt->Belt.Option.map(DateFns.decodeISO),
          studentsCount: c.studentsCount,
          coachesCount: c.coachesCount,
        }),
        response.cohorts.totalCount,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let computeInitialState = () => {
  loading: LoadingV2.empty(),
  cohorts: Unloaded,
  filterLoading: false,
  filterInput: "",
  totalEntriesCount: 0,
}

let reloadStudents = (courseId, send, params) => {
  send(BeginReloading)
  getCohorts(send, courseId, None, params)
}

let makeFilters = () => {
  [
    CourseResourcesFilter.makeFilter(
      "include_inactive_cohorts",
      "Include",
      Custom("Inactive Cohorts"),
      "orange",
    ),
    CourseResourcesFilter.makeFilter("name", "Search by Name", Search, "gray"),
  ]
}

let cohortsList = cohorts => {
  <div className="space-y-4">
    {cohorts
    ->Js.Array2.map(cohort =>
      <Spread props={"data-cohort-name": cohort.name}>
        <div key={cohort.id} className="cohorts-container p-6 bg-white rounded-lg shadow">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-semibold"> {cohort.name->str} </h2>
              {switch cohort.description {
              | Some(description) => <p className="text-sm text-gray-500"> {description->str} </p>
              | None => React.null
              }}
            </div>
            <div>
              <Link
                href={`/school/cohorts/${cohort.id}/details`}
                className="block px-3 py-2 bg-grey-50 text-sm text-grey-600 border rounded border-gray-300 hover:bg-primary-100 hover:text-primary-500 hover:border-primary-500 focus:outline-none focus:bg-primary-100 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500">
                <span className="inline-block pr-2"> <i className="fas fa-edit" /> </span>
                <span> {"Edit"->str} </span>
              </Link>
            </div>
          </div>
          <div className="flex gap-6 flex-wrap mt-6">
            <div>
              <p className="pr-6 text-sm text-gray-500 font-medium"> {"Students"->str} </p>
              <p className="pr-3 mt-2 border-r-2 border-gray-200 font-semibold">
                {cohort.studentsCount->string_of_int->str}
              </p>
            </div>
            <div>
              <p className="pr-6 text-sm text-gray-500 font-medium"> {"Coaches"->str} </p>
              <p className="pr-3 mt-2 border-r-2 border-gray-200 font-semibold">
                {cohort.coachesCount->string_of_int->str}
              </p>
            </div>
            {cohort.endsAt->Belt.Option.mapWithDefault(React.null, endsAt =>
              <div>
                <p className="pr-6 text-sm text-gray-500 font-medium"> {"Cohort end date"->str} </p>
                <p className="pr-3 mt-2 border-r-2 border-gray-200 font-semibold">
                  {endsAt->DateFns.format("MMMM d, yyyy")->str}
                </p>
              </div>
            )}
          </div>
        </div>
      </Spread>
    )
    ->React.array}
  </div>
}

let renderLoadMore = (send, courseId, params, cursor) => {
  <div className="pb-6">
    <button
      className="btn btn-primary-ghost cursor-pointer w-full"
      onClick={_ => {
        send(BeginLoadingMore)
        getCohorts(send, courseId, Some(cursor), params)
      }}>
      {"Load More"->str}
    </button>
  </div>
}

@react.component
let make = (~courseId, ~search) => {
  let params = Webapi.Url.URLSearchParams.make(search)
  let (state, send) = React.useReducer(reducer, computeInitialState())
  React.useEffect1(() => {
    reloadStudents(courseId, send, params)
    None
  }, [search])

  <>
    <Helmet> <title> {str("Cohorts Index")} </title> </Helmet>
    <div className="bg-gray-50 h-full pt-8">
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
        <div className="flex gap-2 items-end justify-between">
          <p className="font-semibold pl-1"> {"Cohorts"->str} </p>
          <Link className="btn btn-primary" href={`/school/courses/${courseId}/cohorts/new`}>
            <PfIcon className="if i-plus-circle-light if-fw" />
            <span className="inline-block pl-2"> {str("Add new cohort")} </span>
          </Link>
        </div>
        <div className="sticky top-0 my-6">
          <div className="border rounded-lg mx-auto bg-white ">
            <div>
              <div className="flex w-full items-start p-4">
                <CourseResourcesFilter
                  courseId
                  filters={makeFilters()}
                  search={search}
                  sorter={CourseResourcesFilter.makeSorter(
                    "sort_by",
                    ["Name", "First Created", "Last Created", "Last Ending"],
                    "Last Created",
                  )}
                />
              </div>
            </div>
          </div>
        </div>
        {PagedCohorts.renderView(
          ~pagedItems=state.cohorts,
          ~loading=state.loading,
          ~entriesView=cohortsList,
          ~totalEntriesCount=state.totalEntriesCount,
          ~loadMore=renderLoadMore(send, courseId, params),
          ~resourceName="Cohorts",
          ~emptyMessage="No Cohorts Found",
        )}
      </div>
    </div>
  </>
}
