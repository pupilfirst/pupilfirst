open TeamsEditor__Types

let str = React.string

let pageLinks = studentId => [
  School__PageHeader.makeLink(
    ~href={`/school/teams/${studentId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/teams/${studentId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=false,
  ),
]

type baseData = {
  courseId: string,
  team: Team.t,
}

type state = Unloaded | Loading | Loaded(baseData)

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
  setState(_ => Loading)
  TeamDetailsDataQuery.fetch({
    id: id,
  })
  |> Js.Promise.then_((response: TeamDetailsDataQuery.t) => {
    setState(_ => Loaded({
      team: response.team->Team.makeFromFragment,
      courseId: response.teamInfo.cohort.courseId,
    }))
    setCourseId(response.teamInfo.cohort.courseId)
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~studentId) => {
  let (state, setState) = React.useState(() => Unloaded)
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadData(studentId, setState, courseContext.setCourseId)
    None
  }, [studentId])

  {
    switch state {
    | Unloaded => str("Should Load data")
    | Loading => SkeletonLoading.coursePage()
    | Loaded(baseData) =>
      <div>
        <School__PageHeader
          exitUrl={`/school/courses/${baseData.courseId}/teams`}
          title={`Edit ${Team.name(baseData.team)}`}
          description={"Edit team details"}
          links={pageLinks(studentId)}
        />
        <AdminCoursesShared__TeamEditor courseId={baseData.courseId} team={baseData.team} />
      </div>
    }
  }
}
