let str = React.string

open TeamsEditor__Types

module Item = {
  type t = Team.t
}

module PagedTeams = Pagination.Make(Item)

type state = {
  loading: LoadingV2.t,
  teams: PagedTeams.t,
  totalEntriesCount: int,
}

type action =
  | LoadTeams(option<string>, bool, array<Team.t>, int)
  | BeginLoadingMore
  | BeginReloading

let reducer = (state, action) =>
  switch action {
  | LoadTeams(endCursor, hasNextPage, teams, totalEntriesCount) =>
    let updatedTeams = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedTeams.toArray(state.teams), teams)
    | Reloading(_) => teams
    }

    {
      teams: PagedTeams.make(updatedTeams, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  }

module CohortFragment = Cohort.Fragment
module CourseTeamsQuery = %graphql(`
    query CourseTeamsQuery($courseId: ID!, $after: String, $filterString: String) {
      teams(courseId: $courseId, filterString: $filterString, first: 20, after: $after) {
        nodes {
          id
          name
          students {
            id
            user {
              id
              name
              avatarUrl
              fullTitle
            }
          }
          cohort {
            ...CohortFragment
          }
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
    }
  `)

let makeFilters = () => {
  [
    CourseResourcesFilter.makeFilter("cohort", "Cohort", DataLoad(#Cohort), "green"),
    CourseResourcesFilter.makeFilter(
      "include_inactive_teams",
      "Include",
      Custom("Inactive Teams"),
      "orange",
    ),
    CourseResourcesFilter.makeFilter("name", "Search by Team Name", Search, "gray"),
    CourseResourcesFilter.makeFilter(
      "sort_by",
      "Sort By",
      Sort(["Name", "First Created", "Last Created"]),
      "gray",
    ),
  ]
}

let studentCard = student =>
  <div className="flex gap-4 items-center p-4 rounded-lg bg-white border border-gray-200 ">
    <div>
      <Avatar name={UserProxy.name(student)} className="w-10 h-10 rounded-full" />
    </div>
    <div>
      <p className="text-sm font-semibold"> {UserProxy.name(student)->str} </p>
      <div className="text-xs"> {UserProxy.fullTitle(student)->str} </div>
    </div>
  </div>

let getTeams = (send, courseId, cursor, params) => {
  let filterString = Webapi.Url.URLSearchParams.toString(params)

  CourseTeamsQuery.makeVariables(~courseId, ~after=?cursor, ~filterString=?Some(filterString), ())
  |> CourseTeamsQuery.fetch
  |> Js.Promise.then_((response: CourseTeamsQuery.t) => {
    send(
      LoadTeams(
        response.teams.pageInfo.endCursor,
        response.teams.pageInfo.hasNextPage,
        response.teams.nodes->Js.Array2.map(t =>
          Team.make(
            ~id=t.id,
            ~name=t.name,
            ~students=t.students->Js.Array2.map(
              s =>
                UserProxy.make(
                  ~id=s.id,
                  ~name=s.user.name,
                  ~avatarUrl=s.user.avatarUrl,
                  ~fullTitle=s.user.fullTitle,
                  ~userId=s.user.id,
                ),
            ),
            ~cohort=Cohort.makeFromFragment(t.cohort),
          )
        ),
        response.teams.totalCount,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let computeInitialState = () => {
  loading: LoadingV2.empty(),
  teams: Unloaded,
  totalEntriesCount: 0,
}

let reloadTeams = (courseId, send, params) => {
  send(BeginReloading)
  getTeams(send, courseId, None, params)
}

let showTeams = (state, courseId, teams) => {
  <div className="w-full">
    {ArrayUtils.isEmpty(teams)
      ? <div
          className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center">
          <FaIcon classes="fas fa-comments text-5xl text-gray-400" />
          <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
            {"Empty Teams message"->str}
          </h4>
        </div>
      : teams
        ->Js.Array2.map(team =>
          <div className="p-6 bg-white rounded-lg" key={Team.id(team)}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <p className="text-lg font-semibold"> {Team.name(team)->str} </p>
                <p className="px-3 py-2 text-xs bg-green-50 text-green-500 rounded-2xl ">
                  {team->Team.cohort->Cohort.name->str}
                </p>
              </div>
              <Link
                href={`/school/courses/${courseId}/teams/${Team.id(team)}/details`}
                className="block px-3 py-2 bg-grey-50 text-sm text-grey-600 border rounded border-gray-300 hover:bg-primary-100 hover:text-primary-500 hover:border-primary-500 focus:outline-none focus:bg-primary-100 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500">
                <span className="inline-block pr-2">
                  <i className="fas fa-edit" />
                </span>
                <span> {"Edit"->str} </span>
              </Link>
            </div>
            <div className="grid grid-cols-1 gap-4 mt-6 lg md:grid-cols-2">
              {Team.students(team)->Js.Array2.map(studentCard)->React.array}
            </div>
          </div>
        )
        ->React.array}
    {PagedTeams.showStats(state.totalEntriesCount, Array.length(teams), "Team")}
  </div>
}

@react.component
let make = (~courseId, ~search) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  let params = Webapi.Url.URLSearchParams.make(search)
  React.useEffect1(() => {
    reloadTeams(courseId, send, params)
    None
  }, [search])

  <>
    <Helmet>
      <title> {str("Teams Index")} </title>
    </Helmet>
    <div>
      <div>
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 mt-8">
          <div className="mt-2 flex gap-2 items-center justify-between">
            <ul className="flex font-semibold text-sm">
              <li
                className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
                {"Active Teams"->str}
              </li>
            </ul>
            <Link className="btn btn-primary" href={`/school/courses/${courseId}/teams/new`}>
              <PfIcon className="if i-plus-circle-light if-fw" />
              <span className="inline-block pl-2"> {str("Create Team")} </span>
            </Link>
          </div>
          <div className="sticky top-0 my-6">
            <div className="border rounded-lg mx-auto bg-white ">
              <div>
                <div className="flex w-full items-start p-4">
                  <CourseResourcesFilter courseId filters={makeFilters()} search={search} />
                </div>
              </div>
            </div>
          </div>
          <div>
            {switch state.teams {
            | Unloaded =>
              <div> {SkeletonLoading.multiple(~count=6, ~element=SkeletonLoading.card())} </div>
            | PartiallyLoaded(teams, cursor) =>
              <div>
                {showTeams(state, courseId, teams)}
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
                          getTeams(send, courseId, Some(cursor), params)
                        }}>
                        {"Load More"->str}
                      </button>
                    </div>,
                    ArrayUtils.isEmpty(times),
                  )
                }}
              </div>
            | FullyLoaded(teams) => <div> {showTeams(state, courseId, teams)} </div>
            }}
            {PagedTeams.showLoading(state.teams, state.loading)}
          </div>
        </div>
      </div>
    </div>
  </>
}
