open TeamsEditor__Types

let str = React.string

let cohortDetailsSkeleton = () => {
  <div className="max-w-5xl mx-auto px-2 mt-8">
    {SkeletonLoading.input()}
    {SkeletonLoading.input()}
    {SkeletonLoading.input()}
    {SkeletonLoading.button()}
  </div>
}

let pageLinks = (courseId, studentId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/teams/${studentId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/teams/${studentId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=false,
  ),
]
type state = Unloaded | Loading | Loaded(Team.t)

module TeamFragment = Team.Fragment

module TeamDetailsDataQuery = %graphql(`
  query TeamDetailsDataQuery($id: ID!) {
    team(id: $id) {
      ...TeamFragment
    }
  }
`)

let loadData = (id, setState) => {
  setState(_ => Loading)
  TeamDetailsDataQuery.fetch({
    id: id,
  })
  |> Js.Promise.then_((response: TeamDetailsDataQuery.t) => {
    setState(_ => Loaded(response.team->Team.makeFromFragment))
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~courseId, ~studentId) => {
  let (state, setState) = React.useState(() => Unloaded)

  React.useEffect1(() => {
    loadData(studentId, setState)
    None
  }, [studentId])

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Edit Team"
      description={"Edit team details"}
      links={pageLinks(courseId, studentId)}
    />
    {switch state {
    | Unloaded => str("Should Load data")
    | Loading => cohortDetailsSkeleton()
    | Loaded(team) => <AdminCoursesShared__TeamEditor courseId team />
    }}
  </div>
}
