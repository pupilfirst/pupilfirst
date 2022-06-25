let str = React.string

module Editor = {
  module Selectable = {
    type t = Cohort.t
    let id = t => Cohort.id(t)
    let name = t => Cohort.name(t)
  }

  module Dropdown = Select.Make(Selectable)

  type state = {
    mergeIntoCohort: option<Cohort.t>,
    saving: bool,
  }

  type action =
    | UpdateMergeIntoCohort(Cohort.t)
    | SetSaving
    | ClearSaving

  let reducer = (state: state, action) =>
    switch action {
    | UpdateMergeIntoCohort(cohort) => {...state, mergeIntoCohort: Some(cohort)}
    | SetSaving => {...state, saving: true}
    | ClearSaving => {...state, saving: false}
    }

  module MergeCohortQuery = %graphql(`
    mutation MergeCohortQuery($deleteCohortId: ID!, $mergeIntoCohortId: ID!) {
      mergeCohort(deleteCohortId: $deleteCohortId, mergeIntoCohortId: $mergeIntoCohortId) {
        success
      }
    }
  `)

  let mergeCohort = (courseId, cohort, send, mergeIntoCohort) => {
    send(SetSaving)
    let variables = MergeCohortQuery.makeVariables(
      ~deleteCohortId=Cohort.id(cohort),
      ~mergeIntoCohortId=Cohort.id(mergeIntoCohort),
      (),
    )

    MergeCohortQuery.fetch(variables)
    |> Js.Promise.then_((result: MergeCohortQuery.t) => {
      result.mergeCohort.success
        ? RescriptReactRouter.push(`/school/courses/${courseId}/cohorts`)
        : send(ClearSaving)
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      send(ClearSaving)
      Js.Promise.resolve()
    })
    |> ignore
  }

  @react.component
  let make = (~courseId, ~cohort, ~cohorts) => {
    let (state, send) = React.useReducer(reducer, {mergeIntoCohort: None, saving: false})
    <div>
      <div className="max-w-5xl mx-auto px-2">
        <h2 className="text-lg font-semibold mt-8">
          {`Merge ${Cohort.name(cohort)} cohort into`->str}
        </h2>
        <p className="text-sm text-gray-500">
          {"Merge will add students, coaches, and calendars from this cohort to the targeted cohort and delete this cohort."->str}
        </p>
        <div className="mt-4">
          <Dropdown
            placeholder={"Pick a Cohort"}
            selectables={cohorts->Js.Array2.filter(c => c != cohort)}
            selected={state.mergeIntoCohort}
            onSelect={u => send(UpdateMergeIntoCohort(u))}
          />
        </div>
        <button
          onClick={_e =>
            Belt.Option.mapWithDefault(
              state.mergeIntoCohort,
              (),
              mergeCohort(courseId, cohort, send),
            )}
          disabled={state.saving || Belt.Option.isNone(state.mergeIntoCohort)}
          className="btn btn-danger mt-4">
          {"Merge and delete"->str}
        </button>
      </div>
    </div>
  }
}

let pageLinks = (courseId, cohortId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/cohorts/${cohortId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/cohorts/${cohortId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=true,
  ),
]

type data = {
  cohort: Cohort.t,
  cohorts: array<Cohort.t>,
}

type state = Unloaded | Loading | Loaded(data)

module CohortFragment = Cohort.Fragment

module CohortDetailsDataQuery = %graphql(`
  query CohortDetailsDataQuery($id: ID!, $courseId: ID!) {
    cohort(id: $id) {
      ...CohortFragment
    }
    course(id: $courseId) {
      cohorts {
        ...CohortFragment
      }
    }
  }
`)

let loadData = (id, courseId, setState) => {
  setState(_ => Loading)
  CohortDetailsDataQuery.fetch({
    id: id,
    courseId: courseId,
  })
  |> Js.Promise.then_((response: CohortDetailsDataQuery.t) => {
    setState(_ => Loaded({
      cohort: response.cohort->Cohort.makeFromFragment,
      cohorts: response.course.cohorts->Js.Array2.map(Cohort.makeFromFragment),
    }))
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~courseId, ~cohortId) => {
  let (state, setState) = React.useState(() => Unloaded)

  React.useEffect1(() => {
    loadData(cohortId, courseId, setState)
    None
  }, [cohortId])

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Edit Cohort"
      description={"Actions for the cohort."}
      links={pageLinks(courseId, cohortId)}
    />
    {switch state {
    | Unloaded => str("Should Load data")
    | Loading => str("Loading data")
    | Loaded(data) => <Editor cohorts=data.cohorts cohort=data.cohort courseId />
    }}
  </div>
}
