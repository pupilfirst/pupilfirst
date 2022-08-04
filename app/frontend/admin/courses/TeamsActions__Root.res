open TeamsEditor__Types

let str = React.string

let pageLinks = studentId => [
  School__PageHeader.makeLink(
    ~href={`/school/teams/${studentId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/teams/${studentId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=true,
  ),
]

type baseData = {
  courseId: string,
  team: Team.t,
}

type pageData = Unloaded | Loading | Loaded(baseData)

type state = {
  pageData: pageData,
  saving: bool,
}

module TeamFragment = Team.Fragment

module TeamDetailsDataQuery = %graphql(`
  query TeamDetailsDataQuery($id: ID!) {
    team(id: $id) {
      ...TeamFragment
    }
    teamInfo: team(id: $id) {
      cohort {
        courseId
      }
    }
  }
`)

let loadData = (id, setState, setCourseId) => {
  setState(state => {...state, pageData: Loading})
  TeamDetailsDataQuery.fetch({
    id: id,
  })
  |> Js.Promise.then_((response: TeamDetailsDataQuery.t) => {
    setState(state => {
      ...state,
      pageData: Loaded({
        team: response.team->Team.makeFromFragment,
        courseId: response.teamInfo.cohort.courseId,
      }),
    })
    setCourseId(response.teamInfo.cohort.courseId)
    Js.Promise.resolve()
  })
  |> ignore
}

module DestroyTeamQuery = %graphql(`
    mutation DestroyTeamQuery($teamId: ID!) {
      destroyTeam(teamId: $teamId) {
        success
      }
    }
  `)

let destroyTeam = (setState, courseId, teamId) => {
  setState(state => {...state, saving: true})

  DestroyTeamQuery.fetch(DestroyTeamQuery.makeVariables(~teamId, ()))
  |> Js.Promise.then_((result: DestroyTeamQuery.t) => {
    result.destroyTeam.success
      ? RescriptReactRouter.push(`/school/courses/${courseId}/teams`)
      : setState(state => {...state, saving: false})
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    setState(state => {...state, saving: false})
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~studentId) => {
  let (state, setState) = React.useState(() => {pageData: Unloaded, saving: false})
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadData(studentId, setState, courseContext.setCourseId)
    None
  }, [studentId])

  <div>
    {switch state.pageData {
    | Unloaded
    | Loading =>
      SkeletonLoading.coursePage()
    | Loaded(baseData) =>
      <div>
        <School__PageHeader
          exitUrl={`/school/courses/${baseData.courseId}/teams`}
          title={`Edit ${Team.name(baseData.team)}`}
          description={"Team actions"}
          links={pageLinks(studentId)}
        />
        <div className="max-w-5xl mx-auto px-2">
          <h2 className="text-lg font-semibold mt-8">
            {`Delete ${Team.name(baseData.team)}`->str}
          </h2>
          <p className="text-sm text-gray-500">
            {"Delete will remove all the students from the team and delete the team"->str}
          </p>
          <button
            onClick={_ => destroyTeam(setState, baseData.courseId, Team.id(baseData.team))}
            className="btn btn-danger mt-4">
            {"Delete team"->str}
          </button>
        </div>
      </div>
    }}
  </div>
}
