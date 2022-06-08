let str = React.string

let pageLinks = (courseId, cohortId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/cohorts/${cohortId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/cohorts/${cohortId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=false,
  ),
]

type state = Unloaded | Loading | Loaded(Cohort.t)

module CohortFragment = Cohort.Fragment

module CohortDetailsDataQuery = %graphql(`
  query CohortDetailsDataQuery($id: ID!) {
    cohort(id: $id) {
      ...CohortFragment
    }
  }
`)

let loadData = (id, setState) => {
  setState(_ => Loading)
  CohortDetailsDataQuery.fetch({
    id: id,
  })
  |> Js.Promise.then_((response: CohortDetailsDataQuery.t) => {
    setState(_ => Loaded(response.cohort->Cohort.makeFromFragment))
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~courseId, ~cohortId) => {
  let (state, setState) = React.useState(() => Unloaded)

  React.useEffect1(() => {
    loadData(cohortId, setState)
    None
  }, [cohortId])

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Edit Cohort"
      description={"{Cohort name}"}
      links={pageLinks(courseId, cohortId)}
    />
    {switch state {
    | Unloaded => str("Should Load data")
    | Loading => str("Loading data")
    | Loaded(cohort) => <Shared__CohortsEditor courseId cohort />
    }}
  </div>
}
