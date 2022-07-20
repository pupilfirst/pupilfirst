open TeamsEditor__Types

let str = React.string

let teamDetailsSkeleton = () => {
  <div className="max-w-5xl mx-auto px-2 mt-8"> {SkeletonLoading.button()} </div>
}

let pageLinks = (courseId, studentId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/teams/${studentId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/teams/${studentId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=true,
  ),
]

type teamData = Unloaded | Loading | Loaded(Team.t)
type state = {
  teamData: teamData,
  saving: bool,
}

module TeamFragment = Team.Fragment

module TeamDetailsDataQuery = %graphql(`
  query TeamDetailsDataQuery($id: ID!) {
    team(id: $id) {
      ...TeamFragment
    }
  }
`)

let loadData = (id, setState) => {
  setState(state => {...state, teamData: Loading})
  TeamDetailsDataQuery.fetch({
    id: id,
  })
  |> Js.Promise.then_((response: TeamDetailsDataQuery.t) => {
    setState(state => {...state, teamData: Loaded(response.team->Team.makeFromFragment)})
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
let make = (~courseId, ~studentId) => {
  let (state, setState) = React.useState(() => {teamData: Unloaded, saving: false})

  React.useEffect1(() => {
    loadData(studentId, setState)
    None
  }, [studentId])

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Edit Team"
      description={"Team actions"}
      links={pageLinks(courseId, studentId)}
    />
    {switch state.teamData {
    | Unloaded => str("Should Load data")
    | Loading => teamDetailsSkeleton()
    | Loaded(team) =>
      <div className="max-w-5xl mx-auto px-2">
        <h2 className="text-lg font-semibold mt-8"> {`Delete ${Team.name(team)}`->str} </h2>
        <p className="text-sm text-gray-500">
          {"Delete will remove all the students from the team and delete the team"->str}
        </p>
        <button
          onClick={_ => destroyTeam(setState, courseId, Team.id(team))}
          className="btn btn-danger mt-4">
          {"Delete team"->str}
        </button>
      </div>
    }}
  </div>
}
