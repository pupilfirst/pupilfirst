let str = React.string

let t = I18n.t(~scope="components.CohortsActions__Root")

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
    <div className="bg-white">
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
        <h2
          className="text-lg font-semibold mt-8"
          dangerouslySetInnerHTML={
            "__html": t("merge_heading_html", ~variables=[("cohort_name", Cohort.name(cohort))]),
          }
        />
        <p className="text-sm text-gray-500"> {t("merge_help")->str} </p>
        <div className="mt-4">
          <Dropdown
            placeholder={t("pick_a_cohort")}
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
          {t("button_text")->str}
        </button>
      </div>
    </div>
  }
}

let cohortActionSkeleton = () => {
  <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
    {SkeletonLoading.heading()}
    <div className="w-1/4"> {SkeletonLoading.input()} {SkeletonLoading.button()} </div>
  </div>
}

let pageLinks = cohortId => [
  School__PageHeader.makeLink(
    ~href={`/school/cohorts/${cohortId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/cohorts/${cohortId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=true,
  ),
]

type data = {
  cohort: Cohort.t,
  cohorts: array<Cohort.t>,
}

type state = Unloaded | Loading | Loaded(data) | Errored

module CohortFragment = Cohort.Fragment

module CohortDetailsDataQuery = %graphql(`
  query CohortDetailsDataQuery($id: ID!) {
    cohort(id: $id) {
      id
      name
      description
      endsAt
      courseId
      course {
        cohorts {
          ...CohortFragment
        }
      }
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
    setState(_ => Loaded({
      cohort: Cohort.make(
        ~id=response.cohort.id,
        ~name=response.cohort.name,
        ~description=response.cohort.description,
        ~endsAt=response.cohort.endsAt->Belt.Option.map(DateFns.decodeISO),
        ~courseId=response.cohort.courseId,
      ),
      cohorts: response.cohort.course.cohorts->Js.Array2.map(Cohort.makeFromFragment),
    }))
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
    | Loaded(data) =>
      <div>
        <School__PageHeader
          exitUrl={`/school/courses/${Cohort.courseId(data.cohort)}/cohorts`}
          title={`${t("edit")} ${Cohort.name(data.cohort)}`}
          description={t("page_description")}
          links={pageLinks(cohortId)}
        />
        <Editor cohorts=data.cohorts cohort=data.cohort courseId={Cohort.courseId(data.cohort)} />
      </div>
    | Errored => <ErrorState />
    }
  }
}
