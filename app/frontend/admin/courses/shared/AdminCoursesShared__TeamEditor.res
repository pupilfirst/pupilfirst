let str = React.string

open TeamsEditor__Types

type state = {
  name: string,
  cohorts: array<Cohort.t>,
  selectedCohort: option<Cohort.t>,
  selectedStudent: array<UserProxy.t>,
  loading: bool,
  saving: bool,
  hasNameError: bool,
  dirty: bool,
}

type action =
  | UpdateName(string)
  | SetBaseData(array<Cohort.t>)
  | SetSelectedCohort(Cohort.t)
  | SetSaving
  | ClearSaving
  | SetLoading
  | ClearLoading
  | SelectedStudent(UserProxy.t)
  | DeSelectStudent(UserProxy.t)

let reducer = (state, action) =>
  switch action {
  | UpdateName(name) => {
      ...state,
      name,
      hasNameError: !StringUtils.lengthBetween(name, 1, 50),
      dirty: true,
    }
  | SetBaseData(cohorts) => {...state, cohorts, loading: false}

  | SetSaving => {...state, saving: true}
  | ClearSaving => {...state, saving: false}
  | SetLoading => {...state, loading: true}
  | ClearLoading => {...state, loading: false}
  | SetSelectedCohort(cohort) => {...state, selectedCohort: Some(cohort), dirty: true}
  | DeSelectStudent(student) => {
      ...state,
      selectedStudent: state.selectedStudent->Js.Array2.filter(s =>
        UserProxy.id(s) != UserProxy.id(student)
      ),
      dirty: true,
    }
  | SelectedStudent(student) => {
      ...state,
      selectedStudent: state.selectedStudent->Js.Array2.concat([student]),
      dirty: true,
    }
  }

// let createCohort = (state, send, courseId) => {
//   send(SetSaving)

//   let variables = CreateCohortsQuery.makeVariables(
//     ~name=state.name,
//     ~description=state.description,
//     ~endsAt=?state.endsAt->Belt.Option.map(DateFns.encodeISO),
//     ~courseId,
//     (),
//   )

//   CreateCohortsQuery.fetch(variables)
//   |> Js.Promise.then_((result: CreateCohortsQuery.t) => {
//     switch result.createCohort.cohort {
//     | Some(_cohort) => {
//         send(ClearSaving)
//         RescriptReactRouter.push(`/school/courses/${courseId}/cohorts`)
//       }

//     | None => send(ClearSaving)
//     }

//     Js.Promise.resolve()
//   })
//   |> Js.Promise.catch(error => {
//     Js.log(error)
//     send(ClearSaving)
//     Js.Promise.resolve()
//   })
//   |> ignore
// }

// let updateCohort = (state, send, cohortId) => {
//   send(SetSaving)

//   let variables = UpdateCohortsQuery.makeVariables(
//     ~name=state.name,
//     ~description=state.description,
//     ~endsAt=?state.endsAt->Belt.Option.map(DateFns.encodeISO),
//     ~cohortId,
//     (),
//   )

//   UpdateCohortsQuery.fetch(variables)
//   |> Js.Promise.then_((result: UpdateCohortsQuery.t) => {
//     switch result.updateCohort.cohort {
//     | Some(_cohort) => send(ClearSaving)
//     | None => send(ClearSaving)
//     }

//     Js.Promise.resolve()
//   })
//   |> Js.Promise.catch(error => {
//     Js.log(error)
//     send(ClearSaving)
//     Js.Promise.resolve()
//   })
//   |> ignore
// }

let computeInitialState = team =>
  switch team {
  | Some(team) => {
      name: Team.name(team),
      hasNameError: false,
      saving: false,
      loading: false,
      cohorts: [],
      selectedCohort: Some(Team.cohort(team)),
      selectedStudent: Team.students(team),
      dirty: false,
    }
  | None => {
      name: "",
      hasNameError: false,
      saving: false,
      loading: false,
      cohorts: [],
      selectedCohort: None,
      selectedStudent: [],
      dirty: false,
    }
  }

let disabled = state => {
  state.hasNameError || state.saving || !state.dirty
}

module Selectable = {
  type t = Cohort.t
  let id = t => Cohort.id(t)
  let name = t => Cohort.name(t)
}

module Dropdown = Select.Make(Selectable)

let findSelectedCohort = (cohorts, selectedCohort) => {
  Belt.Option.flatMap(selectedCohort, c =>
    Js.Array2.find(cohorts, u => Cohort.id(c) == Cohort.id(u))
  )
}

module CohortFragment = Cohort.Fragment
module TeamsEditorBaseDataQuery = %graphql(`
  query TeamsEditorBaseDataQuery($courseId: ID!) {
    course(id: $courseId) {
      cohorts {
        ...CohortFragment
      }
    }
  }
  `)

let loadCohortsData = (courseId, send) => {
  send(SetLoading)
  TeamsEditorBaseDataQuery.fetch(TeamsEditorBaseDataQuery.makeVariables(~courseId, ()))
  |> Js.Promise.then_((response: TeamsEditorBaseDataQuery.t) => {
    send(SetBaseData(response.course.cohorts->Js.Array2.map(Cohort.makeFromFragment)))
    Js.Promise.resolve()
  })
  |> ignore
}

let selectedStudent = (send, student) => {
  send(SelectedStudent(student))
}

let deSelectStudent = (send, student) => {
  send(DeSelectStudent(student))
}

@react.component
let make = (~courseId, ~team=?) => {
  let (state, send) = React.useReducer(reducer, computeInitialState(team))
  React.useEffect1(() => {
    loadCohortsData(courseId, send)
    None
  }, [courseId])

  <DisablingCover disabled={state.saving}>
    <div className="max-w-5xl mx-auto">
      <div className="max-w-5xl mx-auto px-2">
        <div className="mt-8">
          <label className="block text-sm font-semibold mb-2" htmlFor="teamName">
            {"Team name" |> str}
          </label>
          <input
            value={state.name}
            onChange={event => send(UpdateName(ReactEvent.Form.target(event)["value"]))}
            className="appearance-none block w-full text-sm bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
            id="teamName"
            type_="text"
            placeholder="eg, Batch 1"
          />
          <School__InputGroupError message="Enter a valid team name" active=state.hasNameError />
        </div>
        <div className="mt-5 flex flex-col">
          <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="email">
            {"Select a cohort"->str}
          </label>
          <Dropdown
            placeholder={"Pick a Cohort"}
            selectables={state.cohorts}
            selected={findSelectedCohort(state.cohorts, state.selectedCohort)}
            onSelect={u => send(SetSelectedCohort(u))}
            disabled={state.selectedStudent->ArrayUtils.isNotEmpty}
            loading={state.loading}
          />
        </div>
        {switch state.selectedCohort {
        | Some(cohort) =>
          <div className="mt-5 flex flex-col">
            <AdminCoursesShared__StudentsPicker
              courseId
              selectedStudents=state.selectedStudent
              cohort
              onSelect={selectedStudent(send)}
              onDeselect={deSelectStudent(send)}
            />
          </div>
        | None => React.null
        }}
        // {switch team {
        // | Some(team) =>
        //   <button
        //     className="btn btn-primary btn-large w-full mt-6"
        //     disabled={disabled(state)}
        //     onClick={_e => updateCohort(state, send, Cohort.id(cohort))}>
        //     {"Update cohort"->str}
        //   </button>
        // | None =>
        //   <button
        //     className="btn btn-primary btn-large w-full mt-6"
        //     type_="submit"
        //     disabled={disabled(state)}
        //     onClick={_e => createCohort(state, send, courseId)}>
        //     {"Add new cohort"->str}
        //   </button>
        // }}
      </div>
    </div>
  </DisablingCover>
}
