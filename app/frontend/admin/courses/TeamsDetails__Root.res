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

type state = Unloaded | Loading | Loaded(Team.t) | Errored

module TeamFragment = Team.Fragment

module TeamDetailsDataQuery = %graphql(`
  query TeamDetailsDataQuery($id: ID!) {
    team(id: $id) {
      ...TeamFragment
    }
  }
`)

let loadData = (id, setState, setCourseId) => {
  setState(_ => Loading)
  TeamDetailsDataQuery.fetch(
    ~notifyOnNotFound=false,
    {
      id: id,
    },
  )
  |> Js.Promise.then_((response: TeamDetailsDataQuery.t) => {
    setState(_ => Loaded(response.team->Team.makeFromFragment))
    setCourseId(response.team.cohort.courseId)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    setState(_ => Errored)
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
    | Unloaded
    | Loading =>
      SkeletonLoading.coursePage()
    | Loaded(team) =>
      let courseId = Team.cohort(team)->Cohort.courseId
      <div>
        <School__PageHeader
          exitUrl={`/school/courses/${courseId}/teams`}
          title={`Edit ${Team.name(team)}`}
          description={"Edit team details"}
          links={pageLinks(studentId)}
        />
        <AdminCoursesShared__TeamEditor courseId={courseId} team={team} />
      </div>
    | Errored => <ErrorState />
    }
  }
}
