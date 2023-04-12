let str = React.string

open TeamsEditor__Types

let t = I18n.t(~scope="components.TeamsIndex__Root")

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
      totalEntriesCount: totalEntriesCount,
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
      "status",
      "Status",
      CustomArray(["Active", "Inactive"]),
      "orange",
    ),
    CourseResourcesFilter.makeFilter("name", t("filter.search_by_team_name"), Search, "gray"),
  ]
}

let studentCard = student =>
  <div className="flex gap-4 items-center p-4 rounded-lg bg-white border border-gray-200 ">
    <div> <Avatar name={UserProxy.name(student)} className="w-10 h-10 rounded-full" /> </div>
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
            ~students=t.students->Js.Array2.map(s =>
              UserProxy.make(
                ~id=s.id,
                ~name=s.user.name,
                ~avatarUrl=s.user.avatarUrl,
                ~fullTitle=s.user.fullTitle,
                ~userId=s.user.id,
              )
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

let showTeams = teams => {
  <div className="w-full space-y-4">
    {teams
    ->Js.Array2.map(team =>
      <Spread props={"data-team-name": Team.name(team)}>
        <div className="teams-container p-6 bg-white rounded-lg shadow" key={Team.id(team)}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <p className="text-lg font-semibold"> {Team.name(team)->str} </p>
              <p
                className="rounded-lg py-px px-2 text-xs font-semibold bg-green-100 text-green-900 ">
                {team->Team.cohort->Cohort.name->str}
              </p>
            </div>
            <Link
              href={`/school/teams/${Team.id(team)}/details`}
              className="block px-3 py-2 bg-grey-50 text-sm text-grey-600 border rounded border-gray-300 hover:bg-primary-100 hover:text-primary-500 hover:border-primary-500 focus:outline-none focus:bg-primary-100 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500">
              <span className="inline-block pe-2"> <i className="fas fa-edit" /> </span>
              <span> {t("edit")->str} </span>
            </Link>
          </div>
          <div className="grid grid-cols-1 gap-4 mt-6 lg md:grid-cols-2">
            {Team.students(team)->Js.Array2.map(studentCard)->React.array}
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
        getTeams(send, courseId, Some(cursor), params)
      }}>
      {t("load_more")->str}
    </button>
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
    <Helmet> <title> {str(t("page_title"))} </title> </Helmet>
    <div className="bg-gray-50 pt-8 min-h-full">
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
        <div className="flex justify-between items-end gap-2">
          <p className="font-semibold ps-1 "> {t("page_title")->str} </p>
          <Link className="btn btn-primary" href={`/school/courses/${courseId}/teams/new`}>
            <PfIcon className="if i-plus-regular" />
            <span className="inline-block ps-2 "> {str(t("create_team"))} </span>
          </Link>
        </div>
        <div
          className="p-5 mt-6 bg-white rounded-md border border-gray-300 md:sticky md:top-0 z-10">
          <CourseResourcesFilter
            courseId
            filters={makeFilters()}
            search={search}
            sorter={CourseResourcesFilter.makeSorter(
              "sort_by",
              [t("sorter.name"), t("sorter.first_created"), t("sorter.last_created")],
              t("sorter.last_created"),
            )}
          />
        </div>
        {PagedTeams.renderView(
          ~pagedItems=state.teams,
          ~loading=state.loading,
          ~entriesView=showTeams,
          ~totalEntriesCount=state.totalEntriesCount,
          ~loadMore=renderLoadMore(send, courseId, params),
          ~singularResourceName=t("team"),
          ~pluralResourceName=t("teams"),
          ~emptyMessage=t("pagination.empty_message"),
        )}
      </div>
    </div>
  </>
}
