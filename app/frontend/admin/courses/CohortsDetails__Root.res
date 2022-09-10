let str = React.string

let cohortDetailsSkeleton = () => {
  <div className="max-w-5xl mx-auto px-2 mt-8">
    {SkeletonLoading.input()}
    {SkeletonLoading.input()}
    {SkeletonLoading.input()}
    {SkeletonLoading.button()}
  </div>
}

let pageLinks = cohortId => [
  School__PageHeader.makeLink(
    ~href={`/school/cohorts/${cohortId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/cohorts/${cohortId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=false,
  ),
]

type state = Unloaded | Loading | Loaded(Cohort.t) | Errored

module CohortFragment = Cohort.Fragment

module CohortDetailsDataQuery = %graphql(`
  query CohortDetailsDataQuery($id: ID!) {
    cohort(id: $id) {
      ...CohortFragment
    }
  }
`)

let loadData = (id, setState, setCourseId) => {
  setState(_ => Loading)
  CohortDetailsDataQuery.fetch(
    ~notifyOnNotFound=false,
    {
      id: id,
    },
  )
  |> Js.Promise.then_((response: CohortDetailsDataQuery.t) => {
    setState(_ => Loaded(response.cohort->Cohort.makeFromFragment))
    setCourseId(response.cohort.courseId)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    setState(_ => Errored)
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~cohortId) => {
  let (state, setState) = React.useState(() => Unloaded)
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadData(cohortId, setState, courseContext.setCourseId)
    None
  }, [cohortId])

  {
    switch state {
    | Unloaded
    | Loading =>
      SkeletonLoading.coursePage()
    | Loaded(cohort) =>
      let courseId = Cohort.courseId(cohort)
      <div>
        <School__PageHeader
          exitUrl={`/school/courses/${courseId}/cohorts`}
          title={`Edit ${Cohort.name(cohort)}`}
          description={"Update cohort details"}
          links={pageLinks(cohortId)}
        />
        <AdminCoursesShared__CohortsEditor courseId cohort />
      </div>
    | Errored => <ErrorState />
    }
  }
}
