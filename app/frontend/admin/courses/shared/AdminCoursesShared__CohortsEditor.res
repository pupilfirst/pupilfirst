let str = React.string

let t = I18n.t(~scope="components.AdminCoursesShared__CohortsEditor")
let ts = I18n.ts

type state = {
  name: string,
  description: string,
  endsAt: option<Js.Date.t>,
  saving: bool,
  hasNameError: bool,
  hasDescriptionError: bool,
  dirty: bool,
}

type action =
  | UpdateName(string)
  | UpdateDescription(string)
  | UpdateEndsAt(option<Js.Date.t>)
  | SetSaving
  | ClearSaving

let reducer = (state, action) =>
  switch action {
  | UpdateName(name) => {
      ...state,
      name: name,
      hasNameError: !StringUtils.lengthBetween(name, 1, 50),
      dirty: true,
    }
  | UpdateDescription(description) => {
      ...state,
      description: description,
      hasDescriptionError: !StringUtils.lengthBetween(~allowBlank=true, description, 2, 250),
      dirty: true,
    }
  | UpdateEndsAt(endsAt) => {...state, endsAt: endsAt, dirty: true}
  | SetSaving => {...state, saving: true}
  | ClearSaving => {...state, saving: false}
  }

module CohortFragment = Cohort.Fragment

module CreateCohortsQuery = %graphql(`
    mutation CreateCohortMutation($name: String!, $description: String!, $endsAt: ISO8601DateTime, $courseId: ID!) {
      createCohort(courseId: $courseId, name: $name, description: $description, endsAt: $endsAt) {
        cohort {
          ...CohortFragment
        }
      }
    }
  `)

module UpdateCohortsQuery = %graphql(`
    mutation UpdateCohortMutation($name: String!, $description: String!, $endsAt: ISO8601DateTime, $cohortId: ID!) {
      updateCohort(cohortId: $cohortId, name: $name, description: $description, endsAt: $endsAt) {
        cohort {
          ...CohortFragment
        }
      }
    }
  `)

let createCohort = (state, send, courseId) => {
  send(SetSaving)

  let variables = CreateCohortsQuery.makeVariables(
    ~name=state.name,
    ~description=state.description,
    ~endsAt=?state.endsAt->Belt.Option.map(DateFns.encodeISO),
    ~courseId,
    (),
  )

  CreateCohortsQuery.fetch(variables)
  |> Js.Promise.then_((result: CreateCohortsQuery.t) => {
    switch result.createCohort.cohort {
    | Some(_cohort) => {
        send(ClearSaving)
        RescriptReactRouter.push(`/school/courses/${courseId}/cohorts`)
      }
    | None => send(ClearSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(ClearSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let updateCohort = (state, send, cohortId) => {
  send(SetSaving)

  let variables = UpdateCohortsQuery.makeVariables(
    ~name=state.name,
    ~description=state.description,
    ~endsAt=?state.endsAt->Belt.Option.map(DateFns.encodeISO),
    ~cohortId,
    (),
  )

  UpdateCohortsQuery.fetch(variables)
  |> Js.Promise.then_((result: UpdateCohortsQuery.t) => {
    switch result.updateCohort.cohort {
    | Some(_cohort) => send(ClearSaving)
    | None => send(ClearSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(ClearSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let computeInitialState = cohort =>
  switch cohort {
  | Some(cohort) => {
      name: Cohort.name(cohort),
      description: Cohort.description(cohort)->Belt.Option.getWithDefault(""),
      endsAt: Cohort.endsAt(cohort),
      hasNameError: false,
      hasDescriptionError: false,
      saving: false,
      dirty: false,
    }
  | None => {
      name: "",
      description: "",
      endsAt: None,
      hasNameError: false,
      hasDescriptionError: false,
      saving: false,
      dirty: false,
    }
  }

let disabled = state => {
  state.hasNameError || state.hasDescriptionError || state.saving || !state.dirty
}

@react.component
let make = (~courseId, ~cohort=?) => {
  let (state, send) = React.useReducerWithMapState(reducer, cohort, computeInitialState)

  <DisablingCover disabled={state.saving}>
    <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
      <div className="pt-6">
        <label className="block text-sm font-medium" htmlFor="cohortName">
          {t("cohort.label")->str}
        </label>
        <input
          value={state.name}
          onChange={event => send(UpdateName(ReactEvent.Form.target(event)["value"]))}
          maxLength={100}
          className="appearance-none block w-full bg-white border border-gray-300 rounded py-2.5 px-3 mt-1 text-sm focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          id="cohortName"
          type_="text"
          placeholder={t("cohort.placeholder")}
        />
        <School__InputGroupError message={t("cohort.message")} active=state.hasNameError />
      </div>
      <div className="pt-6">
        <label className="block text-sm font-medium" htmlFor="cohortDescription">
          {t("cohort_description.label")->str}
        </label>
        <input
          value=state.description
          onChange={event => send(UpdateDescription(ReactEvent.Form.target(event)["value"]))}
          className="appearance-none block w-full bg-white border border-gray-300 rounded py-2.5 px-3 mt-1 text-sm focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          id="cohortDescription"
          maxLength={250}
          type_="text"
          placeholder={t("cohort_description.placeholder")}
        />
        <School__InputGroupError
          message={t("cohort_description.message")} active=state.hasDescriptionError
        />
      </div>
      <div className="pt-6">
        <div className="flex">
          <label className="block text-sm font-medium" htmlFor="cohortEndsAt">
            {t("cohort_ends_at.label")->str}
            <span className="text-xs ms-1 font-light"> {ts("optional_braces")->str} </span>
          </label>
          <HelpIcon className="ms-1 text-sm"> {t("cohort_ends_at.help")->str} </HelpIcon>
        </div>
        <div className="mt-1">
          <DatePicker
            onChange={date => send(UpdateEndsAt(date))} selected=?state.endsAt id="cohortEndsAt"
          />
        </div>
      </div>
      {switch cohort {
      | Some(cohort) =>
        <div className="pt-6">
          <button
            className="btn btn-primary btn-large w-full"
            disabled={disabled(state)}
            onClick={_e => updateCohort(state, send, Cohort.id(cohort))}>
            {t("update_cohort")->str}
          </button>
        </div>
      | None =>
        <div className="py-6">
          <button
            className="btn btn-primary btn-large w-full"
            type_="submit"
            disabled={disabled(state)}
            onClick={_e => createCohort(state, send, courseId)}>
            {t("add_new_cohort")->str}
          </button>
        </div>
      }}
    </div>
  </DisablingCover>
}
