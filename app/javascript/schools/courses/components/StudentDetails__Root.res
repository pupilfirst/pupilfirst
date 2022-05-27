let str = React.string

let t = I18n.t(~scope="components.StudentsEditor__UpdateDetailsForm")
let ts = I18n.ts

module Coach = UserProxy
module Cohort = Shared__Cohort

type rec teamCoachlist = (coachId, coachName, selected)
and coachId = string
and coachName = string
and selected = bool

type student = {
  name: string,
  taggings: array<string>,
  title: string,
  affiliation: string,
  accessEndsAt: option<Js.Date.t>,
  coachIds: array<string>,
  cohort: Cohort.t,
}

module Editor = {
  type state = {
    student: student,
    coachSearchInput: string,
    saving: bool,
    tagsToApply: array<string>,
  }

  type action =
    | UpdateName(string)
    | AddTag(string)
    | RemoveTag(string)
    | UpdateCoachesList(array<string>)
    | UpdateCoachSearchInput(string)
    | UpdateTitle(string)
    | UpdateAffiliation(string)
    | UpdateSaving(bool)
    | UpdateAccessEndsAt(option<Js.Date.t>)
    | UpdateCohort(Cohort.t)

  let stringInputInvalid = s => String.length(s) < 2

  let updateName = (send, name) => send(UpdateName(name))

  let updateTitle = (send, title) => send(UpdateTitle(title))

  let formInvalid = state =>
    state.student.name->stringInputInvalid || state.student.title->stringInputInvalid

  let handleErrorCB = (send, ()) => send(UpdateSaving(false))

  let successMessage = (accessEndsAt, isSingleFounder) =>
    switch accessEndsAt {
    | Some(date) =>
      switch (date->DateFns.isPast, isSingleFounder) {
      | (true, true) => t("student_updated_moved")
      | (true, false) => t("team_updated_moved")
      | (false, true)
      | (false, false) =>
        t("student_updated")
      }
    | None => t("student_updated")
    }

  let enrolledCoachIds = coaches =>
    coaches
    |> Js.Array.filter(((_, _, selected)) => selected == true)
    |> Array.map(((key, _, _)) => key)

  let handleResponseCB = (updateFormCB, state, student, oldTeam, _json) => {
    // let affiliation = switch state.affiliation |> String.trim {
    // | "" => None
    // | text => Some(text)
    // }
    // let newStudent = Student.update(~name=state.name, ~title=state.title, ~affiliation, ~student)
    // let newTeam = Team.update(
    //   ~name=state.teamName,
    //   ~avilableTags=state.tagsToApply,
    //   ~student=newStudent,
    //   ~coachIds=state.teamCoaches,
    //   ~accessEndsAt=state.accessEndsAt,
    //   ~team=oldTeam,
    // )

    // // Remove inactive teams from the list
    // let team = newTeam |> Team.active ? Some(newTeam) : None

    // updateFormCB(state.tagsToApply, team)
    Notification.success(ts("notifications.success"), "FOO")
  }

  let updateStudent = (student, state, send, responseCB) => {
    send(UpdateSaving(true))
    // let payload = Js.Dict.empty()

    // Js.Dict.set(payload, "authenticity_token", AuthenticityToken.fromHead() |> Js.Json.string)

    // let updatedStudent = Student.updateInfo(
    //   ~name=state.name,
    //   ~title=state.title,
    //   ~affiliation=Some(state.affiliation),
    //   ~student,
    // )
    // Js.Dict.set(payload, "founder", Student.encode(state.teamName, updatedStudent))
    // Js.Dict.set(
    //   payload,
    //   "tags",
    //   state.tagsToApply |> {
    //     open Json.Encode
    //     array(string)
    //   },
    // )
    // Js.Dict.set(
    //   payload,
    //   "coach_ids",
    //   state.teamCoaches |> {
    //     open Json.Encode
    //     array(string)
    //   },
    // )

    // Js.Dict.set(
    //   payload,
    //   "access_ends_at",
    //   state.accessEndsAt->Belt.Option.mapWithDefault(Json.Encode.string(""), DateFns.encodeISO),
    // )

    // let url = "/school/students/" ++ (student |> Student.id)
    // Api.update(url, payload, responseCB, handleErrorCB(send))
  }

  let boolBtnClasses = selected => {
    let classes = "toggle-button__button"
    classes ++ (selected ? " toggle-button__button--active" : "")
  }

  let handleTeamCoachList = (schoolCoaches, state) => {
    let selectedTeamCoachIds = state.coachIds
    schoolCoaches->Js.Array2.map(coach => {
      let coachId = Coach.id(coach)
      let selected =
        selectedTeamCoachIds->Js.Array2.findIndex(selectedCoachId =>
          coachId == selectedCoachId
        ) > -1

      (Coach.id(coach), Coach.name(coach), selected)
    })
  }

  module SelectablePrerequisiteTargets = {
    type t = Coach.t

    let value = t => t |> Coach.name
    let searchString = value

    let make = (coach): t => coach
  }

  let setCoachSearch = (send, value) => send(UpdateCoachSearchInput(value))

  let selectCoach = (send, state, coach) => {
    let updatedCoaches = state.coachIds->Js.Array2.concat([Coach.id(coach)])
    send(UpdateCoachesList(updatedCoaches))
  }

  let deSelectCoach = (send, state, coach) => {
    let updatedCoaches = state.coachIds->Js.Array2.filter(coachId => coachId != Coach.id(coach))
    send(UpdateCoachesList(updatedCoaches))
  }

  module MultiselectForTeamCoaches = MultiselectInline.Make(SelectablePrerequisiteTargets)

  let teamCoachesEditor = (courseCoaches, state: state, send) => {
    let selected =
      courseCoaches
      ->Js.Array2.filter(coach => state.student.coachIds |> Array.mem(Coach.id(coach)))
      ->Js.Array2.map(coach => SelectablePrerequisiteTargets.make(coach))

    let unselected =
      courseCoaches
      ->Js.Array2.filter(coach => !(state.student.coachIds |> Array.mem(Coach.id(coach))))
      ->Js.Array2.map(coach => SelectablePrerequisiteTargets.make(coach))
    <div className="mt-2">
      <MultiselectForTeamCoaches
        placeholder={t("search_coaches_placeholder")}
        emptySelectionMessage={t("search_coaches_empty")}
        allItemsSelectedMessage={t("search_coaches_all")}
        selected
        unselected
        onChange={setCoachSearch(send)}
        value=state.coachSearchInput
        onSelect={selectCoach(send, state.student)}
        onDeselect={deSelectCoach(send, state.student)}
      />
    </div>
  }

  let initialState = student => {
    student: student,
    coachSearchInput: "",
    saving: false,
    tagsToApply: [],
  }

  let reducer = (state: state, action) =>
    switch action {
    | UpdateName(name) => {...state, student: {...state.student, name: name}}
    | AddTag(tag) => {
        ...state,
        tagsToApply: state.tagsToApply->Js.Array2.concat([tag]),
      }
    | RemoveTag(tag) => {
        ...state,
        tagsToApply: state.tagsToApply->Js.Array2.filter(t => t !== tag),
      }
    | UpdateCoachesList(coachIds) => {
        ...state,
        student: {
          ...state.student,
          coachIds: coachIds,
        },
      }
    | UpdateCoachSearchInput(coachSearchInput) => {
        ...state,
        coachSearchInput: coachSearchInput,
      }
    | UpdateTitle(title) => {
        ...state,
        student: {
          ...state.student,
          title: title,
        },
      }
    | UpdateAffiliation(affiliation) => {
        ...state,
        student: {
          ...state.student,
          affiliation: affiliation,
        },
      }
    | UpdateSaving(bool) => {...state, saving: bool}
    | UpdateAccessEndsAt(accessEndsAt) => {
        ...state,
        student: {
          ...state.student,
          accessEndsAt: accessEndsAt,
        },
      }
    | UpdateCohort(cohort) => {
        ...state,
        student: {
          ...state.student,
          cohort: cohort,
        },
      }
    }

  module Selectable = {
    type t = Cohort.t
    let id = t => Cohort.id(t)
    let name = t => Cohort.name(t)
  }

  module Dropdown = Select.Make(Selectable)

  @react.component
  let make = (~student, ~avilableTags, ~courseCoaches, ~cohorts) => {
    let (state, send) = React.useReducer(reducer, initialState(student))

    <DisablingCover disabled=state.saving>
      <div>
        <div className="pt-5">
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
            htmlFor="name">
            {t("name") |> str}
          </label>
          <input
            autoFocus=true
            value=state.student.name
            onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
            id="name"
            type_="text"
            placeholder={t("student_name_placeholder")}
          />
          <School__InputGroupError
            message="Name must have at least two characters"
            active={state.student.name |> stringInputInvalid}
          />
        </div>
        <div className="mt-5">
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
            htmlFor="title">
            {t("title") |> str}
          </label>
          <input
            value=state.student.title
            onChange={event => updateTitle(send, ReactEvent.Form.target(event)["value"])}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
            id="title"
            type_="text"
            placeholder={t("title_placeholder")}
          />
          <School__InputGroupError
            message={t("title_error")} active={state.student.title |> stringInputInvalid}
          />
        </div>
        <div className="mt-5">
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
            htmlFor="affiliation">
            {t("affiliation") |> str}
          </label>
          <span className="text-xs ml-1"> {ts("optional_braces") |> str} </span>
          <input
            value=state.student.affiliation
            onChange={event => send(UpdateAffiliation(ReactEvent.Form.target(event)["value"]))}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
            id="affiliation"
            type_="text"
            placeholder={t("affiliation_placeholder")}
          />
        </div>
        <div className="mt-5 flex flex-col">
          <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="email">
            {"Select a cohort" |> str}
          </label>
          <Dropdown
            placeholder={"Pick a Cohort"}
            selectables={cohorts}
            selected={Some(state.student.cohort)}
            onSelect={u => send(UpdateCohort(u))}
          />
        </div>
        <div className="mt-5">
          <div className="border-b pb-4 mb-2 mt-5 ">
            <span className="inline-block mr-1 text-xs font-semibold">
              {t("personal_coaches") |> str}
            </span>
            {teamCoachesEditor(courseCoaches, state, send)}
          </div>
        </div>
        {state.student.taggings |> ArrayUtils.isNotEmpty
          ? <div className="mt-5">
              <div className="mb-2 text-xs font-semibold">
                {t("tags_applied_user") ++ ":" |> str}
              </div>
              <div className="flex flex-wrap">
                {state.student.taggings
                |> Js.Array.map(tag =>
                  <div
                    className="bg-blue-100 border border-blue-500 rounded-lg px-2 py-px mt-1 mr-1 text-xs text-gray-900"
                    key={tag}>
                    {str(tag)}
                  </div>
                )
                |> React.array}
              </div>
            </div>
          : React.null}
        <div className="mt-5">
          <div className="mb-2 text-xs font-semibold"> {t("tags_applied") ++ ":" |> str} </div>
          <School__SearchableTagList
            unselectedTags={avilableTags |> Js.Array.filter(tag =>
              !(state.tagsToApply |> Array.mem(tag))
            )}
            selectedTags=state.tagsToApply
            addTagCB={tag => send(AddTag(tag))}
            removeTagCB={tag => send(RemoveTag(tag))}
            allowNewTags=true
          />
        </div>
        <div className="mt-5">
          <label className="tracking-wide text-xs font-semibold" htmlFor="access-ends-at-input">
            {t("access_ends_at.label_student")->str}
          </label>
          <span className="ml-1 text-xs"> {ts("optional_braces") |> str} </span>
          <HelpIcon className="ml-2" link={t("access_ends_at.help_url")}>
            {t("access_ends_at.help") |> str}
          </HelpIcon>
          <DatePicker
            onChange={date => send(UpdateAccessEndsAt(date))}
            selected=?state.student.accessEndsAt
            id="access-ends-at-input"
          />
        </div>
      </div>
      <div className="my-5 w-auto">
        <button
          disabled={formInvalid(state)}
          onClick={_e => ()}
          className="w-full btn btn-large btn-primary">
          {t("update_student") |> str}
        </button>
      </div>
    </DisablingCover>
  }
}

type baseData = {
  student: student,
  cohorts: array<Cohort.t>,
  tags: array<String.t>,
  courseCoaches: array<Coach.t>,
}

type state = Unloaded | Loading | Loaded(baseData)

module UserProxyFragment = Coach.Fragments
module CohortFragment = Cohort.Fragments

module StudentDetailsDataQuery = %graphql(`
  query StudentDetailsDataQuery($courseId: ID!, $studentId: ID!) {
    student(studentId: $studentId) {
      taggings
      accessEndsAt
      cohort {
        ...CohortFragment
      }
      user {
        name
        title
        affiliation

      }
      personalCoaches{
        id
      }
    }
    cohorts(courseId: $courseId) {
      ...CohortFragment
    }
    coaches(courseId: $courseId) {
      ...UserProxyFragment
    }
    courseResourceInfo(courseId: $courseId, resources: [StudentTag]) {
      resource
      values
    }
  }
  `)

let loadData = (courseId, studentId, setState) => {
  setState(_ => Loading)
  StudentDetailsDataQuery.fetch({courseId: courseId, studentId: studentId})
  |> Js.Promise.then_((response: StudentDetailsDataQuery.t) => {
    setState(_ => Loaded({
      student: {
        name: response.student.user.name,
        taggings: response.student.taggings,
        title: response.student.user.title,
        affiliation: Belt.Option.getWithDefault(response.student.user.affiliation, ""),
        accessEndsAt: response.student.accessEndsAt->Belt.Option.map(DateFns.decodeISO),
        coachIds: response.student.personalCoaches->Js.Array2.map(c => c.id),
        cohort: response.student.cohort->Cohort.makeFromFagment,
      },
      cohorts: response.cohorts->Js.Array2.map(Cohort.makeFromFagment),
      tags: response.courseResourceInfo[0].values,
      courseCoaches: response.coaches->Js.Array2.map(Coach.makeFromFagment),
    }))
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~courseId, ~studentId) => {
  let (state, setState) = React.useState(() => Unloaded)

  React.useEffect1(() => {
    loadData(courseId, studentId, setState)
    None
  }, [studentId])

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/students`}
      title="Edit Student"
      description={"Update student details"}
    />
    <div className="max-w-5xl mx-auto">
      {switch state {
      | Unloaded => str("Should Load data")
      | Loading => str("Loading data")
      | Loaded(baseData) =>
        <Editor
          courseCoaches=baseData.courseCoaches
          avilableTags={baseData.tags}
          student={baseData.student}
          cohorts={baseData.cohorts}
        />
      }}
    </div>
  </div>
}
