open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor__Form")
let ts = I18n.ts

let str = React.string

type tabs =
  | DetailsTab
  | ImagesTab
  | ActionsTab

let selectedTabClasses = selected =>
  "flex items-center focus:outline-none justify-center w-1/3 p-3 font-semibold rounded-t-lg leading-relaxed border border-gray-300 text-gray-600 cursor-pointer hover:bg-gray-50 hover:text-gray-900 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 " ++ (
    selected ? "text-primary-500 bg-white border-b-transparent" : "bg-gray-50"
  )

let tabItemsClasses = selected => selected ? "" : "hidden"

type state = {
  name: string,
  description: string,
  hasNameError: bool,
  hasDescriptionError: bool,
  hasDateError: bool,
  about: string,
  publicSignup: bool,
  publicPreview: bool,
  dirty: bool,
  saving: bool,
  featured: bool,
  progressionBehavior: Course.progressionBehavior,
  highlights: array<Course.Highlight.t>,
  hasProcessingUrl: bool,
  processingUrl: string,
  defaultCohort: option<Cohort.t>,
  cohorts: array<Cohort.t>,
  loading: bool,
}

type action =
  | UpdateName(string, bool)
  | UpdateDescription(string, bool)
  | StartSaving
  | FailSaving
  | UpdateAbout(string)
  | UpdatePublicSignup(bool)
  | UpdatePublicPreview(bool)
  | UpdateFeatured(bool)
  | UpdateProgressionBehavior(Course.progressionBehavior)
  | UpdateHighlights(array<Course.Highlight.t>)
  | SetHasProcessingUrl
  | ClearHasProcessingUrl
  | UpdateProcessingUrl(string)
  | SetCohortsData(array<Cohort.t>)
  | SetDefaultCohort(Cohort.t)
  | SetLoading
  | ClearLoading

let reducer = (state, action) =>
  switch action {
  | StartSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | UpdateName(name, hasNameError) => {
      ...state,
      name,
      hasNameError,
      dirty: true,
    }
  | UpdateDescription(description, hasDescriptionError) => {
      ...state,
      description,
      hasDescriptionError,
      dirty: true,
    }
  | UpdatePublicSignup(publicSignup) => {...state, publicSignup, dirty: true}
  | UpdatePublicPreview(publicPreview) => {...state, publicPreview, dirty: true}
  | UpdateAbout(about) => {...state, about, dirty: true}
  | UpdateFeatured(featured) => {...state, featured, dirty: true}
  | UpdateProgressionBehavior(progressionBehavior) => {
      ...state,
      progressionBehavior,
      dirty: true,
    }
  | UpdateHighlights(highlights) => {...state, highlights, dirty: true}
  | SetHasProcessingUrl => {...state, hasProcessingUrl: true, dirty: true}
  | ClearHasProcessingUrl => {...state, hasProcessingUrl: false, dirty: true}
  | UpdateProcessingUrl(processingUrl) => {
      ...state,
      processingUrl,
      dirty: true,
    }
  | SetCohortsData(cohortsData) => {...state, cohorts: cohortsData, loading: false}
  | SetLoading => {...state, loading: true}
  | ClearLoading => {...state, loading: false}
  | SetDefaultCohort(defaultCohort) => {...state, defaultCohort: Some(defaultCohort), dirty: true}
  }

module CourseFragment = CourseEditor__Course.Fragment

module CreateCourseQuery = %graphql(`
    mutation CreateCourseMutation($name: String!, $description: String!, $about: String, $publicSignup: Boolean!, $publicPreview: Boolean!, $featured: Boolean!, $progressionLimit: Int!, $highlights: [CourseHighlightInput!], $processingUrl: String) {
      createCourse(name: $name, description: $description, about: $about, publicSignup: $publicSignup, publicPreview: $publicPreview, featured: $featured, progressionLimit: $progressionLimit, highlights: $highlights, processingUrl: $processingUrl) {
        course {
          ...CourseFragment
        }
      }
    }
  `)

module UpdateCourseQuery = %graphql(`
    mutation UpdateCourseMutation($id: ID!, $name: String!, $description: String!, $about: String, $publicSignup: Boolean!, $publicPreview: Boolean!, $featured: Boolean!, $progressionLimit: Int!, $highlights: [CourseHighlightInput!], $processingUrl: String, $defaultCohortId: ID!) {
      updateCourse(id: $id, name: $name, description: $description, about: $about, publicSignup: $publicSignup, publicPreview: $publicPreview, featured: $featured, progressionLimit: $progressionLimit, highlights: $highlights, processingUrl: $processingUrl, defaultCohortId: $defaultCohortId) {
        course {
          ...CourseFragment
        }
      }
    }
  `)

module ArciveCourseQuery = %graphql(`
  mutation ArchiveCourseMutation($id: ID!) {
    archiveCourse(id: $id)  {
      success
    }
  }
`)

module UnarchiveCourseQuery = %graphql(`
  mutation UnarchiveCourseMutation($id: ID!) {
    unarchiveCourse(id: $id)  {
      success
    }
  }
`)

module CloneCourseQuery = %graphql(`
  mutation CloneCourseMutation($id: ID!) {
    cloneCourse(id: $id)  {
      success
    }
  }
`)

module CohortFragment = Cohort.Fragment
module CourseEditorBaseDataQuery = %graphql(`
  query CourseEditorBaseDataQuery($courseId: ID!) {
    course(id: $courseId) {
      cohorts {
        ...CohortFragment
      }
    }
  }
  `)

let updateName = (send, name) => {
  let hasError = name->String.trim->String.length < 2
  send(UpdateName(name, hasError))
}

let updateDescription = (send, description) => {
  let lengthOfDescription = description->String.trim->String.length
  let hasError = lengthOfDescription < 2 || lengthOfDescription >= 150
  send(UpdateDescription(description, hasError))
}

let saveDisabled = (state, isNewCourse) =>
  state.hasDateError ||
  (state.hasDescriptionError ||
  (state.description == "" ||
  (state.hasNameError || (state.name == "" || (!state.dirty || state.saving))))) ||
  state.defaultCohort->Belt.Option.isNone && !isNewCourse ||
  UrlUtils.isInvalid(true, state.processingUrl) ||
  Course.Highlight.isInValidArray(state.highlights)

let processingUrl = state => {
  if state.hasProcessingUrl && state.publicSignup {
    Some(state.processingUrl)
  } else {
    None
  }
}

let createCourse = (state, send, reloadCoursesCB) => {
  send(StartSaving)

  let highlights = Js.Array.map(
    h =>
      CreateCourseQuery.makeInputObjectCourseHighlightInput(
        ~title=Course.Highlight.title(h),
        ~icon=Course.Highlight.icon(h),
        ~description=Course.Highlight.description(h),
        (),
      ),
    state.highlights,
  )

  let variables = CreateCourseQuery.makeVariables(
    ~name=state.name,
    ~description=state.description,
    ~about=?String.trim(state.about) === "" ? None : Some(state.about),
    ~publicSignup=state.publicSignup,
    ~publicPreview=state.publicPreview,
    ~featured=state.featured,
    ~progressionLimit=Course.progressionLimit(state.progressionBehavior),
    ~highlights,
    ~processingUrl=?processingUrl(state),
    (),
  )

  CreateCourseQuery.make(variables)
  |> Js.Promise.then_(result => {
    switch result["createCourse"]["course"] {
    | Some(_course) => reloadCoursesCB()
    | None => send(FailSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let updateCourse = (state, send, updateCourseCB, course) => {
  send(StartSaving)

  let highlights = Js.Array.map(
    h =>
      UpdateCourseQuery.makeInputObjectCourseHighlightInput(
        ~title=Course.Highlight.title(h),
        ~icon=Course.Highlight.icon(h),
        ~description=Course.Highlight.description(h),
        (),
      ),
    state.highlights,
  )

  let variables = UpdateCourseQuery.makeVariables(
    ~id=Course.id(course),
    ~name=state.name,
    ~description=state.description,
    ~about=?String.trim(state.about) === "" ? None : Some(state.about),
    ~publicSignup=state.publicSignup,
    ~publicPreview=state.publicPreview,
    ~featured=state.featured,
    ~progressionLimit=Course.progressionLimit(state.progressionBehavior),
    ~highlights,
    ~processingUrl=?processingUrl(state),
    ~defaultCohortId=state.defaultCohort->Belt.Option.mapWithDefault("", Cohort.id),
    (),
  )

  UpdateCourseQuery.fetch(variables)
  |> Js.Promise.then_((result: UpdateCourseQuery.t) => {
    switch result.updateCourse.course {
    | Some(course) => updateCourseCB(Course.makeFromFragment(course))
    | None => send(FailSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let archiveCourse = (send, reloadCoursesCB, course) => {
  send(StartSaving)

  ArciveCourseQuery.make({id: course |> Course.id})
  |> Js.Promise.then_(result => {
    result["archiveCourse"]["success"] ? reloadCoursesCB() : send(FailSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let unarchiveCourse = (send, reloadCoursesCB, course) => {
  send(StartSaving)

  UnarchiveCourseQuery.make({id: course |> Course.id})
  |> Js.Promise.then_(result => {
    result["unarchiveCourse"]["success"] ? reloadCoursesCB() : send(FailSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}
module Selectable = {
  type t = Cohort.t
  let id = t => Cohort.id(t)
  let name = t => Cohort.name(t)
}

module CohortsPicker = Select.Make(Selectable)

let findSelectedCohort = (cohorts, selectedCohort) => {
  Belt.Option.flatMap(selectedCohort, c =>
    Js.Array2.find(cohorts, u => Cohort.id(c) == Cohort.id(u))
  )
}

let cloneCourse = (send, reloadCoursesCB, course) => {
  send(StartSaving)

  CloneCourseQuery.make({id: course |> Course.id})
  |> Js.Promise.then_(result => {
    result["cloneCourse"]["success"] ? reloadCoursesCB() : send(FailSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button"
  classes ++ (bool ? " toggle-button__button--active" : "")
}

let publicSignupField = (publicSignup, send) =>
  <div className="flex items-center mt-5">
    <label className="block tracking-wide text-xs font-semibold me-6" htmlFor="public-signup">
      {t("enable_public_signup_label")->str}
    </label>
    <div id="public-signup" className="flex toggle-button__group shrink-0 rounded-lg">
      <button
        className={booleanButtonClasses(publicSignup)}
        onClick={_ => send(UpdatePublicSignup(true))}>
        {ts("_yes")->str}
      </button>
      <button
        className={booleanButtonClasses(!publicSignup)}
        onClick={_ => send(UpdatePublicSignup(false))}>
        {ts("_no")->str}
      </button>
    </div>
  </div>

let publicPreviewField = (publicPreview, send) =>
  <div className="flex items-center mt-5">
    <label className="block tracking-wide text-xs font-semibold me-6" htmlFor="public-preview">
      {t("enable_public_preview_label")->str}
    </label>
    <div id="public-preview" className="flex toggle-button__group shrink-0 rounded-lg">
      <button
        className={booleanButtonClasses(publicPreview)}
        onClick={_ => send(UpdatePublicPreview(true))}>
        {ts("_yes")->str}
      </button>
      <button
        className={booleanButtonClasses(!publicPreview)}
        onClick={_ => send(UpdatePublicPreview(false))}>
        {ts("_no")->str}
      </button>
    </div>
  </div>

let featuredButton = (featured, send) =>
  <div className="flex items-center mt-5">
    <label className="block tracking-wide text-xs font-semibold me-6" htmlFor="featured">
      {t("feature_course_in_homepage_label")->str}
    </label>
    <div id="featured" className="flex toggle-button__group shrink-0 rounded-lg">
      <button className={booleanButtonClasses(featured)} onClick={_ => send(UpdateFeatured(true))}>
        {ts("_yes")->str}
      </button>
      <button
        className={booleanButtonClasses(!featured)} onClick={_ => send(UpdateFeatured(false))}>
        {ts("_no")->str}
      </button>
    </div>
  </div>

let processingUrlInput = (state, send) => {
  <div>
    <div className="flex items-center mt-5">
      <label className="block tracking-wide text-xs font-semibold " htmlFor="featured">
        {t("processing_url.label")->str}
      </label>
      <HelpIcon className="ms-2 me-6" link={t("processing_url.help_url")}>
        {t("processing_url.help")->str}
      </HelpIcon>
      <div id="processing-url" className="flex toggle-button__group shrink-0 rounded-lg">
        <button
          className={booleanButtonClasses(state.hasProcessingUrl)}
          onClick={_ => send(SetHasProcessingUrl)}>
          {ts("_yes")->str}
        </button>
        <button
          className={booleanButtonClasses(!state.hasProcessingUrl)}
          onClick={_ => send(ClearHasProcessingUrl)}>
          {ts("_no")->str}
        </button>
      </div>
    </div>
    {ReactUtils.nullUnless(
      <div>
        <input
          className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
          id="processing_url"
          type_="text"
          placeholder="https://example.com/"
          value=state.processingUrl
          onChange={event => send(UpdateProcessingUrl(ReactEvent.Form.target(event)["value"]))}
        />
        <School__InputGroupError
          message={t("processing_url.error")} active={UrlUtils.isInvalid(true, state.processingUrl)}
        />
      </div>,
      state.hasProcessingUrl,
    )}
  </div>
}

let courseHighlights = (highlights, send) =>
  <div className="mt-5">
    <label className="tracking-wide text-xs font-semibold" htmlFor="highlights">
      {t("course_highlights.label")->str}
    </label>
    <div>
      <CourseEditor__HighlightsEditor
        highlights updateHighlightsCB={h => send(UpdateHighlights(h))}
      />
    </div>
  </div>

let about = course => Belt.Option.getWithDefault(Course.about(course), "")

let updateAboutCB = (send, about) => send(UpdateAbout(about))

let computeInitialState = course =>
  switch course {
  | Some(course) => {
      name: Course.name(course),
      description: Course.description(course),
      hasNameError: false,
      hasDateError: false,
      hasDescriptionError: false,
      dirty: false,
      saving: false,
      about: about(course),
      publicSignup: Course.publicSignup(course),
      publicPreview: Course.publicPreview(course),
      featured: Course.featured(course),
      progressionBehavior: Course.progressionBehavior(course),
      highlights: Course.highlights(course),
      processingUrl: Belt.Option.getWithDefault(Course.processingUrl(course), ""),
      hasProcessingUrl: Belt.Option.isSome(Course.processingUrl(course)),
      defaultCohort: Course.defaultCohort(course),
      cohorts: [],
      loading: false,
    }
  | None => {
      name: "",
      description: "",
      hasNameError: false,
      hasDateError: false,
      hasDescriptionError: false,
      dirty: false,
      saving: false,
      about: "",
      publicSignup: false,
      publicPreview: false,
      featured: true,
      progressionBehavior: Limited(1),
      highlights: [],
      processingUrl: "",
      hasProcessingUrl: false,
      defaultCohort: None,
      cohorts: [],
      loading: false,
    }
  }

let handleSelectProgressionLimit = (send, event) => {
  let target = ReactEvent.Form.target(event)

  switch target["value"] {
  | "1"
  | "2"
  | "3"
  | "4" =>
    send(UpdateProgressionBehavior(Limited(int_of_string(target["value"]))))
  | otherValue => Rollbar.error("Unexpected progression limit was selected: " ++ otherValue)
  }
}

let progressionBehaviorButtonClasses = (
  state,
  progressionBehavior: Course.progressionBehavior,
  additionalClasses,
) => {
  let selected = switch (state.progressionBehavior, progressionBehavior) {
  | (Limited(_), Limited(_)) => true
  | (Unlimited, Unlimited) => true
  | _ => false
  }

  let defaultClasses =
    additionalClasses ++ " w-1/3 relative border font-semibold focus:outline-none rounded px-5 py-4 md:px-8 md:py-5 items-center cursor-pointer text-center bg-gray-50 hover:bg-gray-300 focus:bg-gray-300 focus:ring-2 focus:ring-focusColor-500 "
  defaultClasses ++ (selected ? " text-primary-500 border-primary-500" : "")
}

let detailsTab = (state, send, course, updateCourseCB, reloadCoursesCB) => {
  <div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold " htmlFor="name">
        {t("course_name.label")->str}
      </label>
      <input
        autoFocus=true
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="name"
        type_="text"
        placeholder={t("course_name.placeholder")}
        maxLength=50
        value=state.name
        onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
      />
      <School__InputGroupError message={t("course_name.error_message")} active=state.hasNameError />
    </div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="description">
        {t("course_description.label")->str}
      </label>
      <input
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="description"
        type_="text"
        placeholder={t("course_description.placeholder")}
        value=state.description
        maxLength=150
        onChange={event => updateDescription(send, ReactEvent.Form.target(event)["value"])}
      />
    </div>
    <School__InputGroupError
      message={t("course_description.error_message")} active=state.hasDescriptionError
    />
    <School__InputGroupError message={t("enter_date")} active=state.hasDateError />
    <div className="mt-5">
      <label className="tracking-wide text-xs font-semibold" htmlFor="course-about">
        {t("course_about.label")->str}
      </label>
      <div className="mt-2">
        <MarkdownEditor
          textareaId="course-about"
          onChange={updateAboutCB(send)}
          value=state.about
          placeholder={t("course_about.placeholder")}
          profile=Markdown.Permissive
          maxLength=10000
        />
      </div>
    </div>
    <div className="mt-5">
      <label className="tracking-wide text-xs font-semibold">
        {t("progression_behavior.label")->str}
      </label>
      <HelpIcon className="ms-2" link={t("progression_behavior.help_url")}>
        {t("progression_behavior.help")->str}
      </HelpIcon>
      <div className="flex mt-2">
        <button className={progressionBehaviorButtonClasses(state, Limited(1), "me-1")}>
          <div className="font-bold text-xl"> {t("progression_behavior.limited.title")->str} </div>
          <div className="text-xs mt-2">
            <div> {t("progression_behavior.limited.description_start")->str} </div>
            <select
              id="progression-limit"
              onChange={handleSelectProgressionLimit(send)}
              className="my-1 cursor-pointer inline-block appearance-none bg-white border-b-2 text-xl font-semibold border-blue-500 hover:border-gray-500 p-1 leading-tight rounded-none focus:outline-none"
              style={ReactDOM.Style.make(~textAlignLast="center", ())}
              value={string_of_int(Course.progressionLimit(state.progressionBehavior))}>
              {ReactUtils.nullUnless(
                <option> {"-"->str} </option>,
                state.progressionBehavior == Unlimited,
              )}
              <option value="1"> {t("progression_behavior.limited.once")->str} </option>
              <option value="2"> {t("progression_behavior.limited.twice")->str} </option>
              <option value="3"> {t("progression_behavior.limited.thrice")->str} </option>
              <option value="4"> {t("progression_behavior.limited.four_times")->str} </option>
            </select>
            <div> {t("progression_behavior.limited.description_end")->str} </div>
          </div>
        </button>
        <button
          onClick={_ => send(UpdateProgressionBehavior(Unlimited))}
          className={progressionBehaviorButtonClasses(state, Unlimited, "mx-1")}>
          <div className="font-bold text-xl">
            {t("progression_behavior.unlimited.title")->str}
          </div>
          <span className="text-xs"> {t("progression_behavior.unlimited.description")->str} </span>
        </button>
      </div>
    </div>
    {featuredButton(state.featured, send)}
    {publicSignupField(state.publicSignup, send)}
    {publicPreviewField(state.publicPreview, send)}
    {ReactUtils.nullUnless({processingUrlInput(state, send)}, state.publicSignup)}
    {ReactUtils.nullUnless(
      <div className="pt-5 flex flex-col">
        <label className="block tracking-wide text-xs font-semibold me-6" htmlFor="email">
          {t("pick_default_cohort")->str}
        </label>
        <CohortsPicker
          placeholder={t("pick_a_cohort")}
          selectables={state.cohorts}
          selected={findSelectedCohort(state.cohorts, state.defaultCohort)}
          onSelect={u => send(SetDefaultCohort(u))}
          disabled={state.saving}
          loading={state.loading}
        />
      </div>,
      Belt.Option.isSome(course),
    )}
    {courseHighlights(state.highlights, send)}
    <div className="max-w-2xl py-6 mx-auto">
      <div className="flex justify-end">
        {switch course {
        | Some(course) =>
          <button
            disabled={saveDisabled(state, false)}
            onClick={_ => updateCourse(state, send, updateCourseCB, course)}
            className="w-full btn btn-large btn-primary mt-3">
            {t("update_course")->str}
          </button>

        | None =>
          <button
            disabled={saveDisabled(state, true)}
            onClick={_ => createCourse(state, send, reloadCoursesCB)}
            className="w-full btn btn-large btn-primary mt-3">
            {t("create_course")->str}
          </button>
        }}
      </div>
    </div>
  </div>
}

let cloneButtonIcons = saving => saving ? "fas fa-spinner fa-spin" : "fas fa-copy"
let submitButtonIcons = saving => saving ? "fas fa-spinner fa-spin" : "fa fa-exclamation-triangle"

let actionsTab = (state, send, reloadCoursesCB, course) => {
  <div>
    <div className="mt-2">
      <label className="tracking-wide text-xs font-semibold">
        {str(t("actions.clone_course.label"))}
      </label>
      <div>
        <button
          disabled=state.saving
          className="btn btn-primary-ghost btn-large mt-2"
          onClick={_ =>
            WindowUtils.confirm(t("alert.clone_course_message"), () =>
              cloneCourse(send, reloadCoursesCB, course)
            )}>
          <FaIcon classes={cloneButtonIcons(state.saving)} />
          <span className="ms-2"> {t("actions.clone_course.button_text")->str} </span>
        </button>
      </div>
    </div>
    {Belt.Option.isSome(Course.archivedAt(course))
      ? <div className="mt-2">
          <label className="tracking-wide text-xs font-semibold">
            {str(t("actions.unarchive_course.label"))}
          </label>
          <div>
            <button
              disabled=state.saving
              className="btn btn-success btn-large mt-2"
              onClick={_ =>
                WindowUtils.confirm(t("alert.unarchive_message"), () =>
                  unarchiveCourse(send, reloadCoursesCB, course)
                )}>
              <FaIcon classes={submitButtonIcons(state.saving)} />
              <span className="ms-2"> {t("actions.unarchive_course.button_text")->str} </span>
            </button>
          </div>
        </div>
      : <div className="mt-2">
          <label className="tracking-wide text-xs font-semibold">
            {str(t("actions.archive_course.label"))}
          </label>
          <div>
            <button
              disabled=state.saving
              className="btn btn-danger btn-large mt-2"
              onClick={_ =>
                WindowUtils.confirm(t("alert.archive_message"), () =>
                  archiveCourse(send, reloadCoursesCB, course)
                )}>
              <FaIcon classes={submitButtonIcons(state.saving)} />
              <span className="ms-2"> {t("actions.archive_course.button_text")->str} </span>
            </button>
          </div>
        </div>}
  </div>
}

let loadData = (courseId, send) => {
  send(SetLoading)
  CourseEditorBaseDataQuery.fetch(
    ~notifyOnNotFound=false,
    {
      courseId: courseId,
    },
  )
  |> Js.Promise.then_((response: CourseEditorBaseDataQuery.t) => {
    send(SetCohortsData(response.course.cohorts->Js.Array2.map(Cohort.makeFromFragment)))

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    send(ClearLoading)
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~course, ~updateCourseCB, ~reloadCoursesCB, ~selectedTab) => {
  let (state, send) = React.useReducerWithMapState(reducer, course, computeInitialState)
  React.useEffect1(() => {
    switch course {
    | Some(c) => loadData(Course.id(c), send)
    | None => ()
    }

    None
  }, [course])

  <DisablingCover disabled={state.saving}>
    <div className="mx-auto bg-white">
      <div className="border-b border-gray-300 bg-gray-50">
        <div className="max-w-2xl mx-auto">
          <h5 className="uppercase text-center p-6">
            {(course == None ? t("title.add_new_course") : t("title.edit_course_details"))->str}
          </h5>
          {ReactUtils.nullUnless(
            <div className="w-full">
              <div
                role="tablist"
                className="flex flex-wrap w-full max-w-3xl mx-auto text-sm px-3 -mb-px">
                <button
                  role="tab"
                  ariaSelected={selectedTab == DetailsTab}
                  className={selectedTabClasses(selectedTab == DetailsTab)}
                  onClick={_ => RescriptReactRouter.push("./details")}>
                  <i className="fa fa-edit" />
                  <span className="ms-2"> {t("tabs.details")->str} </span>
                </button>
                <button
                  role="tab"
                  ariaSelected={selectedTab == ImagesTab}
                  className={selectedTabClasses(selectedTab == ImagesTab)}
                  onClick={_ => RescriptReactRouter.push("./images")}>
                  <i className="fa fa-camera" />
                  <span className="ms-2"> {t("tabs.images")->str} </span>
                </button>
                <button
                  role="tab"
                  ariaSelected={selectedTab == ActionsTab}
                  className={"-ms-px " ++ selectedTabClasses(selectedTab == ActionsTab)}
                  onClick={_ => RescriptReactRouter.push("./actions")}>
                  <i className="fa fa-cog" />
                  <span className="ms-2"> {t("tabs.actions")->str} </span>
                </button>
              </div>
            </div>,
            Belt.Option.isSome(course),
          )}
        </div>
      </div>
      <div className="max-w-2xl mx-auto">
        <div className={tabItemsClasses(selectedTab == DetailsTab)}>
          {detailsTab(state, send, course, updateCourseCB, reloadCoursesCB)}
        </div>
        {switch course {
        | Some(c) =>
          [
            <div key="actions-tab" className={tabItemsClasses(selectedTab == ActionsTab)}>
              {actionsTab(state, send, reloadCoursesCB, c)}
            </div>,
            <div key="images-tab" className={tabItemsClasses(selectedTab == ImagesTab)}>
              <CourseEditor__ImagesForm course=c updateCourseCB />
            </div>,
          ]->React.array
        | None => React.null
        }}
      </div>
    </div>
  </DisablingCover>
}
