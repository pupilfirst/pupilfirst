open CourseEditor__Types

let str = ReasonReact.string

type progressionBehavior = [#Limited | #Unlimited | #Strict]

type state = {
  name: string,
  description: string,
  endsAt: option<Js.Date.t>,
  hasNameError: bool,
  hasDescriptionError: bool,
  hasDateError: bool,
  about: string,
  publicSignup: bool,
  dirty: bool,
  saving: bool,
  featured: bool,
  progressionBehavior: progressionBehavior,
  progressionLimit: int,
}

type action =
  | UpdateName(string, bool)
  | UpdateDescription(string, bool)
  | UpdateEndsAt(option<Js.Date.t>)
  | StartSaving
  | FailSaving
  | UpdateAbout(string)
  | UpdatePublicSignup(bool)
  | UpdateFeatured(bool)
  | UpdateProgressionBehavior(progressionBehavior)
  | UpdateProgressionLimit(int)

let reducer = (state, action) =>
  switch action {
  | StartSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | UpdateName(name, hasNameError) => {
      ...state,
      name: name,
      hasNameError: hasNameError,
      dirty: true,
    }
  | UpdateDescription(description, hasDescriptionError) => {
      ...state,
      description: description,
      hasDescriptionError: hasDescriptionError,
      dirty: true,
    }
  | UpdateEndsAt(date) => {...state, endsAt: date, dirty: true}
  | UpdatePublicSignup(publicSignup) => {...state, publicSignup: publicSignup, dirty: true}
  | UpdateAbout(about) => {...state, about: about, dirty: true}
  | UpdateFeatured(featured) => {...state, featured: featured, dirty: true}
  | UpdateProgressionBehavior(progressionBehavior) => {
      ...state,
      progressionBehavior: progressionBehavior,
      dirty: true,
    }
  | UpdateProgressionLimit(progressionLimit) => {
      ...state,
      progressionBehavior: #Limited,
      progressionLimit: progressionLimit,
      dirty: true,
    }
  }

module CreateCourseQuery = %graphql(
  `
    mutation CreateCourseMutation($name: String!, $description: String!, $endsAt: ISO8601DateTime, $about: String!, $publicSignup: Boolean!, $featured: Boolean!, $progressionBehavior: ProgressionBehavior!, $progressionLimit: Int) {
      createCourse(name: $name, description: $description, endsAt: $endsAt, about: $about, publicSignup: $publicSignup, featured: $featured, progressionBehavior: $progressionBehavior, progressionLimit: $progressionLimit) {
        course {
          ...Course.Fragments.AllFields
        }
      }
    }
  `
)

module UpdateCourseQuery = %graphql(
  `
    mutation UpdateCourseMutation($id: ID!, $name: String!, $description: String!, $endsAt: ISO8601DateTime, $about: String!, $publicSignup: Boolean!, $featured: Boolean!, $progressionBehavior: ProgressionBehavior!, $progressionLimit: Int) {
      updateCourse(id: $id, name: $name, description: $description, endsAt: $endsAt, about: $about, publicSignup: $publicSignup, featured: $featured, progressionBehavior: $progressionBehavior, progressionLimit: $progressionLimit) {
        course {
          ...Course.Fragments.AllFields
        }
      }
    }
  `
)

let updateName = (send, name) => {
  let hasError = name |> String.trim |> String.length < 2
  send(UpdateName(name, hasError))
}

let updateDescription = (send, description) => {
  let lengthOfDescription = description |> String.trim |> String.length
  let hasError = lengthOfDescription < 2 || lengthOfDescription >= 150
  send(UpdateDescription(description, hasError))
}

let saveDisabled = state =>
  state.hasDateError ||
  (state.hasDescriptionError ||
  (state.description == "" ||
    (state.hasNameError ||
    (state.name == "" || (!state.dirty || state.saving)))))

let formClasses = value =>
  value ? "drawer-right-form w-full opacity-50" : "drawer-right-form w-full"

let progressionLimitForQuery = state =>
  switch state.progressionBehavior {
  | #Unlimited
  | #Strict =>
    None
  | #Limited => Some(state.progressionLimit)
  }

let createCourse = (state, send, updateCourseCB) => {
  send(StartSaving)

  let createCourseQuery = CreateCourseQuery.make(
    ~name=state.name,
    ~description=state.description,
    ~endsAt=?state.endsAt->Belt.Option.map(DateFns.encodeISO),
    ~about=state.about,
    ~publicSignup=state.publicSignup,
    ~featured=state.featured,
    ~progressionBehavior=state.progressionBehavior,
    ~progressionLimit=?progressionLimitForQuery(state),
    (),
  )

  createCourseQuery |> GraphqlQuery.sendQuery |> Js.Promise.then_(result => {
    switch result["createCourse"]["course"] {
    | Some(course) => Course.makeFromJs(course) |> updateCourseCB
    | None => send(FailSaving)
    }

    Js.Promise.resolve()
  }) |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  }) |> ignore
}

let updateCourse = (state, send, updateCourseCB, course) => {
  send(StartSaving)

  let updateCourseQuery = UpdateCourseQuery.make(
    ~id=course |> Course.id,
    ~name=state.name,
    ~description=state.description,
    ~endsAt=?state.endsAt->Belt.Option.map(DateFns.encodeISO),
    ~about=state.about,
    ~publicSignup=state.publicSignup,
    ~featured=state.featured,
    ~progressionBehavior=state.progressionBehavior,
    ~progressionLimit=?progressionLimitForQuery(state),
    (),
  )

  updateCourseQuery |> GraphqlQuery.sendQuery |> Js.Promise.then_(result => {
    switch result["updateCourse"]["course"] {
    | Some(course) => Course.makeFromJs(course) |> updateCourseCB
    | None => send(FailSaving)
    }

    Js.Promise.resolve()
  }) |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  }) |> ignore
}

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button"
  classes ++ (bool ? " toggle-button__button--active" : "")
}

let enablePublicSignupButton = (publicSignup, send) =>
  <div className="flex items-center mt-5">
    <label className="block tracking-wide text-xs font-semibold mr-6" htmlFor="public-signup">
      {"Enable public signup for this course?" |> str}
    </label>
    <div id="public-signup" className="flex toggle-button__group flex-shrink-0 rounded-lg">
      <button
        className={booleanButtonClasses(publicSignup)}
        onClick={_ => send(UpdatePublicSignup(true))}>
        {"Yes" |> str}
      </button>
      <button
        className={booleanButtonClasses(!publicSignup)}
        onClick={_ => send(UpdatePublicSignup(false))}>
        {"No" |> str}
      </button>
    </div>
  </div>

let featuredButton = (featured, send) =>
  <div className="flex items-center mt-5">
    <label className="block tracking-wide text-xs font-semibold mr-6" htmlFor="featured">
      {"Feature course in school homepage?" |> str}
    </label>
    <div id="featured" className="flex toggle-button__group flex-shrink-0 rounded-lg">
      <button className={booleanButtonClasses(featured)} onClick={_ => send(UpdateFeatured(true))}>
        {"Yes" |> str}
      </button>
      <button
        className={booleanButtonClasses(!featured)} onClick={_ => send(UpdateFeatured(false))}>
        {"No" |> str}
      </button>
    </div>
  </div>

let about = course =>
  switch course |> Course.about {
  | Some(about) => about
  | None => ""
  }

let updateAboutCB = (send, about) => send(UpdateAbout(about))

let computeInitialState = course =>
  switch course {
  | Some(course) => {
      name: course |> Course.name,
      description: course |> Course.description,
      endsAt: course |> Course.endsAt,
      hasNameError: false,
      hasDateError: false,
      hasDescriptionError: false,
      dirty: false,
      saving: false,
      about: about(course),
      publicSignup: course |> Course.publicSignup,
      featured: course |> Course.featured,
      progressionBehavior: course |> Course.progressionBehavior,
      progressionLimit: Course.progressionLimit(course)->Belt.Option.getWithDefault(1),
    }
  | None => {
      name: "",
      description: "",
      endsAt: None,
      hasNameError: false,
      hasDateError: false,
      hasDescriptionError: false,
      dirty: false,
      saving: false,
      about: "",
      publicSignup: false,
      featured: true,
      progressionBehavior: #Limited,
      progressionLimit: 1,
    }
  }

let handleSelectProgressionLimit = (send, event) => {
  let target = event |> ReactEvent.Form.target

  switch target["value"] {
  | "1"
  | "2"
  | "3" =>
    send(UpdateProgressionLimit(target["value"] |> int_of_string))
  | otherValue => Rollbar.error("Unexpected progression limit was selected: " ++ otherValue)
  }
}

let progressionBehaviorButtonClasses = (state, progressionBehavior, additionalClasses) => {
  let selected = state.progressionBehavior == progressionBehavior
  let defaultClasses =
    additionalClasses ++ " w-1/3 relative border font-semibold focus:outline-none rounded px-5 py-4 md:px-8 md:py-5 items-center cursor-pointer text-center bg-gray-200 hover:bg-gray-300"
  defaultClasses ++ (selected ? " text-primary-500 border-primary-500" : "")
}

@react.component
let make = (~course, ~hideEditorActionCB, ~updateCourseCB) => {
  let (state, send) = React.useReducerWithMapState(reducer, course, computeInitialState)
  <div>
    <div className="blanket" />
    <div className="drawer-right">
      <div className="drawer-right__close absolute">
        <button
          title="close"
          onClick={_ => hideEditorActionCB()}
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div className={formClasses(state.saving)}>
        <div className="w-full">
          <div className="mx-auto bg-white">
            <div className="max-w-2xl p-6 mx-auto">
              <h5 className="uppercase text-center border-b border-gray-400 pb-2">
                {(course == None ? "Add New Course" : "Edit Course Details") |> str}
              </h5>
              <div className="mt-5">
                <label className="inline-block tracking-wide text-xs font-semibold " htmlFor="name">
                  {"Course name" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  id="name"
                  type_="text"
                  placeholder="Type course name here"
                  maxLength=50
                  value=state.name
                  onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
                />
                <School__InputGroupError
                  message="A name is required (2-50 characters)" active=state.hasNameError
                />
              </div>
              <div className="mt-5">
                <label
                  className="inline-block tracking-wide text-xs font-semibold"
                  htmlFor="description">
                  {"Course description" |> str}
                </label>
                <input
                  className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  id="description"
                  type_="text"
                  placeholder="Short description for this course"
                  value=state.description
                  maxLength=150
                  onChange={event =>
                    updateDescription(send, ReactEvent.Form.target(event)["value"])}
                />
              </div>
              <School__InputGroupError
                message="A description is required (2-150 characters)"
                active=state.hasDescriptionError
              />
              <div className="mt-5">
                <label
                  className="tracking-wide text-xs font-semibold" htmlFor="course-ends-at-input">
                  {"Course end date" |> str}
                </label>
                <span className="ml-1 text-xs"> {"(optional)" |> str} </span>
                <HelpIcon className="ml-2" link="https://docs.pupilfirst.com/#/courses">
                  {"If specified, course will appear as closed to students on this date. Students will not be able to make any more submissions." |> str}
                </HelpIcon>
                <DatePicker
                  onChange={date => send(UpdateEndsAt(date))}
                  selected=?state.endsAt
                  id="course-ends-at-input"
                />
              </div>
              <School__InputGroupError message="Enter a valid date" active=state.hasDateError />
              <div className="mt-5">
                <label className="tracking-wide text-xs font-semibold" htmlFor="course-about">
                  {"About" |> str}
                </label>
                <div className="mt-2">
                  <MarkdownEditor
                    textareaId="course-about"
                    onChange={updateAboutCB(send)}
                    value=state.about
                    placeholder="Add more details about the course."
                    profile=Markdown.Permissive
                    maxLength=10000
                  />
                </div>
              </div>
              <div className="mt-5">
                <label className="tracking-wide text-xs font-semibold">
                  {"Progression Behavior" |> str}
                </label>
                <HelpIcon
                  className="ml-2"
                  link="https://docs.pupilfirst.com/#/courses?id=progression-behaviour">
                  {"This only applies if your course has milestone targets that requires students to submit their work for review by coaches." |> str}
                </HelpIcon>
                <div className="flex mt-2">
                  <button
                    onClick={_ => send(UpdateProgressionBehavior(#Limited))}
                    className={progressionBehaviorButtonClasses(state, #Limited, "mr-1")}>
                    <div className="font-bold text-xl"> {"Limited" |> str} </div>
                    <div className="text-xs mt-2">
                      <div> {"Students can level up" |> str} </div>
                      <select
                        id="progression-limit"
                        onChange={handleSelectProgressionLimit(send)}
                        className="my-1 cursor-pointer inline-block appearance-none bg-white border-b-2 text-xl font-semibold border-blue-500 hover:border-gray-500 p-1 leading-tight rounded-none focus:outline-none"
                        style={ReactDOMRe.Style.make(~textAlignLast="center", ())}
                        value={string_of_int(state.progressionLimit)}>
                        <option value="1"> {"once" |> str} </option>
                        <option value="2"> {"twice" |> str} </option>
                        <option value="3"> {"thrice" |> str} </option>
                      </select>
                      <div> {" without getting submissions reviewed." |> str} </div>
                    </div>
                  </button>
                  <button
                    onClick={_ => send(UpdateProgressionBehavior(#Unlimited))}
                    className={progressionBehaviorButtonClasses(state, #Unlimited, "mx-1")}>
                    <div className="font-bold text-xl"> {"Unlimited" |> str} </div>
                    <span className="text-xs">
                      {"Students can level up till the end of the course, without getting submissions reviewed." |> str}
                    </span>
                  </button>
                  <button
                    onClick={_ => send(UpdateProgressionBehavior(#Strict))}
                    className={progressionBehaviorButtonClasses(state, #Strict, "ml-1")}>
                    <div className="font-bold text-xl"> {"Strict" |> str} </div>
                    <span className="text-xs">
                      {"Students can level up only after getting submissions reviewed, and passing." |> str}
                    </span>
                  </button>
                </div>
              </div>
              {featuredButton(state.featured, send)}
              {enablePublicSignupButton(state.publicSignup, send)}
            </div>
          </div>
          <div className="mx-auto">
            <div className="max-w-2xl p-6 mx-auto">
              <div className="flex">
                {switch course {
                | Some(course) =>
                  <button
                    disabled={saveDisabled(state)}
                    onClick={_ => updateCourse(state, send, updateCourseCB, course)}
                    className="w-full btn btn-large btn-primary mt-3">
                    {"Update Course" |> str}
                  </button>

                | None =>
                  <button
                    disabled={saveDisabled(state)}
                    onClick={_ => createCourse(state, send, updateCourseCB)}
                    className="w-full btn btn-large btn-primary mt-3">
                    {"Create Course" |> str}
                  </button>
                }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
}
